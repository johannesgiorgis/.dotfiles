#!/usr/bin/env python3

"""
Check asdf for plugin updates
Gets information on installed plugin's versions and subversions
"""

import logging
import os
import re
import subprocess
import time
from pprint import pprint
from typing import List, Tuple  # Python <3.11 compatiblility
from dataclasses import dataclass
import asyncio


# set logging
LOG_LEVEL = os.environ.get("LOG_LEVEL", "INFO").upper()

log = logging.getLogger(__name__)
log.setLevel(getattr(logging, LOG_LEVEL))

# create handler
c_handler = logging.StreamHandler()
c_handler.setLevel((getattr(logging, LOG_LEVEL)))

# Create formatters and add it to handlers
LOG_FORMAT = "[%(asctime)s - %(levelname)s - %(module)s:%(lineno)s ] %(message)s"
c_format = logging.Formatter(LOG_FORMAT)
c_handler.setFormatter(c_format)

# Add handlers to the logger
log.addHandler(c_handler)


@dataclass
class Plugin:
    name: str
    installed_latest_versions: dict[str, dict[str, str]]
    latest: str

    def display(self):
        print(
            f"""
    Plugin:{self.name}
    Latest: {self.latest}
    """
        )
        pprint(self.installed_latest_versions)


@dataclass
class Colors:
    default = "\033[39m"
    black = "\033[30m"
    red = "\033[0;31m"
    green = "\033[32m"
    yellow = "\033[33m"
    blue = "\033[34m"
    magenta = "\033[35m"
    cyan = "\033[36m"
    light_gray = "\033[37m"
    dark_gray = "\033[90m"
    light_red = "\033[91m"
    light_green = "\033[92m"
    light_yellow = "\033[93m"
    light_blue = "\033[94m"
    light_magenta = "\033[95m"
    light_cyan = "\033[96m"
    white = "\033[97m"


async def main():
    start = time.time()
    plugins = await get_plugins_info()

    asdf_current = plugins.pop()

    if LOG_LEVEL == "DEBUG":
        for plugin in plugins:
            plugin.display()

    display_report(asdf_current, plugins)
    run_time = time.time() - start
    log.info(f"Completed with {run_time:0.4f} seconds ({run_time/60:0.4f} mins)")


async def get_plugins_info() -> List[Plugin]:
    """
    For each plugin, get
        - Installed versions
        - All versions
        - Latest version
    A very expensive function
    Also decodes all bytes to strings
    """
    plugin_names = (await async_run("asdf plugin-list")).split()

    return await asyncio.gather(
        *[
            create_plugin_info(plugin_name)
            for plugin_name in plugin_names
            if plugin_name != "rust"
        ],
        async_run("asdf current"),
    )


async def create_plugin_info(plugin_name: str) -> Plugin:
    log.debug(f"Getting info for plugin {plugin_name}...")
    latest = await async_run(f"asdf latest {plugin_name}")

    all_plugins = (await async_run(f"asdf list-all {plugin_name}")).split("\n")

    # Remove unreleased versions - alpha, beta, rc, dev, 0a* (e.g. python 3.12.0a*)
    all_versions = list(filter(lambda x: not re.match(".+([a-zA-z])", x), all_plugins))

    installed_versions = await get_installed_versions(plugin_name=plugin_name)
    log.debug(f"{installed_versions=}")

    installed_latest_versions = get_installed_latest_versions(
        installed_versions, all_versions
    )
    log.debug(f"{installed_latest_versions=}")

    plugin = Plugin(
        name=plugin_name,
        installed_latest_versions=installed_latest_versions,
        latest=latest,
    )
    log.debug(plugin)
    return plugin


async def get_installed_versions(plugin_name: str) -> List[Plugin]:
    asdf_list = (await async_run(f"asdf list {plugin_name}")).split("\n")
    installed_versions = list(
        map(
            lambda x: x.replace(" ", "")
            # 2024-01-04: asdf includes a * to indicate current active plugin version, so we need to remove it
            # It was causing failures when extracting main and sub versions down stream
            .replace("*", ""),
            asdf_list,
        )
    )

    # https://github.com/NeoHsu/asdf-hugo
    # To install an extended Hugo version with Sass/SCSS support simply
    # prefix the version number in the asdf install command with extended_.
    if plugin_name == "gohugo":
        installed_versions = list(
            map(lambda x: x.strip("extended_"), installed_versions)
        )
    return installed_versions


def get_installed_latest_versions(
    installed_versions: list[str], all_versions: list[str]
) -> dict[dict[str, str]]:
    return {
        version: check_latest_version(version, all_versions)
        for version in installed_versions
    }


def check_latest_version(version: str, versions: list[str]) -> dict[str, str]:
    subversion_result = search_for_versions(version, versions, 2)
    version_result = search_for_versions(version, versions, 1)

    return {
        "latest_subversion": subversion_result[-1],
        "latest_version": version_result[-1],
    }


async def async_run(cmd: str) -> str:
    proc = await asyncio.create_subprocess_shell(
        cmd, stdout=asyncio.subprocess.PIPE, stderr=asyncio.subprocess.PIPE
    )

    stdout, stderr = await proc.communicate()

    if stderr:
        raise Exception("Error: " + stderr.decode())

    return stdout.decode().strip()


def search_for_versions(
    version: str, all_versions: List[str], num_chars: int = 2
) -> List:
    """
    Search for versions - either subversion or version
    num_chars:
        1: 3.18.1 -> 3     (version check)
        2: 3.18.1 -> 3.18  (subversion check)
    """
    log.debug("Checking for version")
    subversion_part = ".".join(version.split(".")[:num_chars])
    r = re.compile(subversion_part + r"\.*")
    result = list(filter(r.match, all_versions))
    log.debug(f"Matches for {r}:{result}")
    return result


# Report Generation


def display_report(asdf_current: str, plugins: List[Plugin]):
    log.debug("Generating report")
    status, commands = generate_status_and_update_commands(plugins)

    log.info(f"{Colors.light_blue}› Show 'asdf current' output:\n{asdf_current}{Colors.default}")

    log.info(f"{Colors.light_yellow}› asdf Update Summary:{Colors.default}")
    headers = ["PLUGIN", "INSTALLED", "LATEST", "VERSION", "SUBVERSION"]
    print(
        f"{headers[0]: <15}{headers[1]: <15}{headers[2]: <20}{headers[3]: <25}{headers[4]}"
    )
    # PLUGIN      INSTALLED      LATEST       VERSION                SUBVERSION
    # nodejs      14.20.1        19.3.0       14.20.1 -> 14.21.2     14.20.1 good
    # python      3.8.15         3.11.1       3.8.15 -> 3.11.1       3.8.15 -> 3.8.16
    for row in status:
        print(f"{row[0]: <15}{row[1]: <15}{row[2]: <20}{row[3]: <35}{row[4]}")

    print()
    print(f"{Colors.green}› asdf update software update command:")
    for command in commands:
        print(command)
    print(Colors.default)


def generate_status_and_update_commands(plugins: List[Plugin]) -> Tuple[List, List]:
    """
    Generate status and commands for each installed plugin version by
    comparing subversion and version against respective latest
    """
    log.debug("Generating status and update commands")
    commands, status = [], []

    for plugin in plugins:
        # Ignore terraform as different verions are required for work purposes
        if plugin.name == "terraform":
            continue

        for version, updates in plugin.installed_latest_versions.items():
            plugin_status = [plugin.name, version, f"{Colors.magenta}{plugin.latest}"]
            version_status, version_command = compare_versions(
                plugin.name, version, updates["latest_version"], Colors.cyan
            )
            plugin_status.append(version_status)
            if version_command:
                commands.append(version_command)

            subversion_status, subversion_command = compare_versions(
                plugin.name, version, updates["latest_subversion"], Colors.light_red
            )
            plugin_status.append(subversion_status)
            if subversion_command:
                commands.append(subversion_command)

            status.append(plugin_status)

    return status, commands


def compare_versions(
    plugin_name: str, installed: str, latest: str, status_color: str
) -> Tuple[str, str]:
    """
    Compare versions, captures status and creates update commands
    """
    status = f"{Colors.green}{installed} good{Colors.default}"
    update_command = ""
    if installed != latest:
        log.debug(
            f"{Colors.red}WARNING: Need to update {plugin_name} {installed} to "
            f"{latest}{Colors.default}"
        )
        status = f"{status_color}{installed} -> {latest}{Colors.default}"
        update_command = (
            f"{status_color}"
            f"asdf install {plugin_name} {latest} && asdf uninstall {plugin_name} {installed} "
            f"&& asdf reshim {plugin_name} {latest} && asdf global {plugin_name} {latest}"
            f"{Colors.default}"
        )

    return status, update_command


if __name__ == "__main__":
    asyncio.run(main())
