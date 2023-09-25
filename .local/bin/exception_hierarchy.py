#!/usr/bin/env python
import sys

if len(sys.argv) > 1 and (sys.argv[1] == "-h" or sys.argv[1] == "--help"):
    print("Print Python builtin exception hierarchy.")
    print("Adapted from <https://stackoverflow.com/a/18296681>.")
    raise SystemExit(0)


def classtree(cls, indent=0):
    """Print exception hierarchy for the class `cls`."""
    print(' '*indent + cls.__name__)
    for subcls in cls.__subclasses__():
        classtree(subcls, indent+3)


if __name__ == '__main__':
    classtree(BaseException)
