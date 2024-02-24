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
from collections import defaultdict
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
    installed: defaultdict(str)
    latest: str
    all_versions: List[str]

    def display(self):
        print(
            f"""
    Plugin:{self.name}
    Latest: {self.latest}
    """
        )
        pprint(dict(self.installed))


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

    # plugins = sync_get_plugins_info()
    check_latest_versions(plugins)

    # print("=" * 90)
    # if LOG_LEVEL == "DEBUG":
    #     for plugin in plugins:
    #         plugin.display()

    asyncio.get_event_loop().run_in_executor(None, display_report, plugins)
    run_time = time.time() - start
    log.info(f"Completed with {run_time:0.2f} seconds ({run_time/60:0.2f} mins)")


def sync_get_plugins_info() -> List[Plugin]:
    """
    For each plugin, get
        - Installed versions
        - All versions
        - Latest version
    A very expensive function
    Also decodes all bytes to strings
    """
    plugins = []
    for plugin_name in subprocess.check_output(["asdf", "plugin-list"]).split():
        plugin_name = plugin_name.decode()
        log.info(f"Getting info for plugin {plugin_name}...")
        latest = (
            subprocess.check_output(["asdf", "latest", plugin_name]).split()[0].decode()
        )

        all_plugins = subprocess.check_output(["asdf", "list-all", plugin_name])
        all = list(map(lambda x: x.decode(), all_plugins.split()))

        # Remove unreleased versions - alpha, beta, rc, dev, 0a* (e.g. python 3.12.0a*)
        all_versions = list(
            filter(lambda x: not re.match(".+(alpha|beta|rc|dev|0a\d)", x), all)
        )

        asdf_list = subprocess.check_output(["asdf", "list", plugin_name])
        installed_versions = list(
            map(
                lambda x: x.decode().replace(" ", "")
                # 2024-01-04: asdf includes a * to indicate current active plugin version, so we need to remove it
                # It was causing failures when extracting main and sub versions down stream
                .replace("*", ""),
                asdf_list.split(),
            )
        )

        plugin = Plugin(
            name=plugin_name,
            installed=defaultdict.fromkeys(installed_versions),
            latest=latest,
            all_versions=all_versions,
        )
        log.debug(plugin)
        plugins.append(plugin)

    return plugins


##############


async def get_plugins_info() -> List[Plugin]:
    """
    For each plugin, get
        - Installed versions
        - All versions
        - Latest version
    A very expensive function
    Also decodes all bytes to strings
    """
    plugin_names = subprocess.check_output(["asdf", "plugin-list"])
    plugin_names = list(map(lambda x: x.decode(), plugin_names.split()))

    return await asyncio.gather(
        *[create_plugin_info(plugin_name) for plugin_name in plugin_names]
    )


async def create_plugin_info(plugin_name: str) -> Plugin:
    log.info(f"Getting info for plugin {plugin_name}...")
    latest = await async_run(f"asdf list {plugin_name}")

    all_plugins = await async_run(f"asdf list-all {plugin_name}")

    # Remove unreleased versions - alpha, beta, rc, dev, 0a* (e.g. python 3.12.0a*)
    all_versions = list(
        filter(lambda x: not re.match(".+([a-zA-z])", x), all_plugins.split("\n"))
    )

    asdf_list = await async_run(f"asdf list {plugin_name}")
    # print(f"{asdf_list=}")
    installed_versions = list(
        map(
            lambda x: x.replace(" ", "")
            # 2024-01-04: asdf includes a * to indicate current active plugin version, so we need to remove it
            # It was causing failures when extracting main and sub versions down stream
            .replace("*", ""),
            asdf_list,
        )
    )

    plugin = Plugin(
        name=plugin_name,
        installed=defaultdict.fromkeys(installed_versions),
        latest=latest,
        all_versions=all_versions,
    )
    log.debug(plugin)
    return plugin


async def async_run(cmd: str) -> str:
    proc = await asyncio.create_subprocess_shell(
        cmd, stdout=asyncio.subprocess.PIPE, stderr=asyncio.subprocess.PIPE
    )

    stdout, stderr = await proc.communicate()

    if stderr:
        raise Exception("Error: " + stderr.decode())

    return stdout.decode().strip()


# Check Updates


def check_latest_versions(plugins: List[Plugin]):
    """
    Checks latest versions, subversions for each installed plugin version
    """
    log.info("Checking latest versions")
    log.debug(type(plugins))
    for plugin in plugins:
        print("\n\n")
        print(f"{type(plugin)=}")
        log.info(f"Checking for {plugin.name}")
        for version in plugin.installed.keys():
            subversions_result = search_for_versions(version, plugin.all_versions, 2)
            versions_result = search_for_versions(version, plugin.all_versions, 1)
            if subversions_result and versions_result:
                plugin.installed[version] = {
                    "latest_subversion": subversions_result[-1],
                    "latest_version": versions_result[-1],
                }
            else:
                plugin.installed[version] = {
                    "latest_subversion": "",
                    "latest_version": "",
                }
    log.info("Completed checking latest versions")


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
    r = re.compile(subversion_part + "\.*")
    result = list(filter(r.match, all_versions))
    log.debug(f"Matches for {r}:{result}")
    return result


# Report Generation


def display_report(plugins: List[Plugin]):
    log.info("Generating report")
    status, commands = generate_status_and_update_commands(plugins)

    print()
    log.info(f"{Colors.light_blue}› Show 'asdf current' output:")
    subprocess.check_call(["asdf", "current"])

    print()
    log.info(f"{Colors.light_yellow}› asdf Update Summary:{Colors.default}")
    headers = ["PLUGIN", "INSTALLED", "LATEST", "VERSION", "SUBVERSION"]
    print(
        f"{headers[0]: <15}{headers[1]: <15}{headers[2]: <15}{headers[3]: <25}{headers[4]}"
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
    log.info("Generating status and update commands")
    commands, status = [], []
    for plugin in plugins:
        # Ignore terraform as different verions are required for work purposes
        if plugin.name == "terraform":
            continue

        for version, updates in plugin.installed.items():
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
    else:
        status = f"{Colors.green}{installed} good{Colors.default}"
        update_command = ""

    return status, update_command


if __name__ == "__main__":
    asyncio.run(main())
