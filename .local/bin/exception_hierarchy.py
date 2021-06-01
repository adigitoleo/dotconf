#!/usr/bin/env python
"""Print Python builtin exception hierarchy.

Adapted from https://stackoverflow.com/a/18296681

"""


def classtree(cls, indent=0):
    """Print exception hierarchy for the class `cls`."""
    print(' '*indent + cls.__name__)
    for subcls in cls.__subclasses__():
        classtree(subcls, indent+3)


if __name__ == '__main__':
    classtree(BaseException)
