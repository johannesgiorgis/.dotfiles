"""
Dot Files Manager
-----------------
Uses ansible playbooks for managing system software, configuration
Dependencies kept to a minimal - ansible, homebrew
"""


class bcolors:
    # HEADER = "\033[95m"
    # OKBLUE = "\033[94m"
    # OKCYAN = "\033[96m"
    # OKGREEN = "\033[92m"
    # WARNING = "\033[93m"
    # FAIL = "\033[91m"
    # ENDC = "\033[0m"
    # BOLD = "\033[1m"
    # UNDERLINE = "\033[4m"
    DEFAULT = "\033[39m"
    BLACK = "\033[30m"
    RED = "\033[0;31m"
    GREEN = "\033[32m"
    YELLOW = "\033[33m"
    BLUE = "\033[34m"
    MAGENTA = "\033[35m"
    CYAN = "\033[36m"
    LIGHT_GRAY = "\033[37m"
    DARK_GRAY = "\033[90m"
    LIGHT_RED = "\033[91m"
    LIGHT_GREEN = "\033[92m"
    LIGHT_YELLOW = "\033[93m"
    LIGHT_BLUE = "\033[94m"
    LIGHT_MAGENTA = "\033[95m"
    LIGHT_CYAN = "\033[96m"
    WHITE = "\033[97m"


def usage():
    print(
        f"""{bcolors.RED}ERROR: Script requires the following inputs:
    {bcolors.BLUE}
    -f: find tag
    -t: tag for ansible (DEFAULT: all)
    -i: get info for an aggregate tag (tags with multiple packages. e.g. macos-cli, macos-infra)
    -a: enable ask_become_pass
    """
    )
    print(
        f"""{bcolors.YELLOW}Usage:
    doi # will display all available tags
    doi -t zsh -a
    doi -t meld,broot
    doi -f macos
    """
    )


def main():
    usage()


if __name__ == "__main__":
    main()
