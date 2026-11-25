"""Entry point: `harmonix <command>`.

A command is a module in harmonix.commands exposing `register(subparsers)`,
which adds its parser and sets `run` as the parser's default. Adding one means
writing that module and listing it in COMMANDS.
"""

import argparse
import sys

from harmonix.commands import organize

COMMANDS = [organize]


def main() -> None:
    parser = argparse.ArgumentParser(prog="harmonix")
    subparsers = parser.add_subparsers(dest="command", metavar="<command>")
    for command in COMMANDS:
        command.register(subparsers)

    args = parser.parse_args()
    if args.command is None:
        parser.print_help()
        sys.exit(1)
    sys.exit(args.run(args) or 0)
