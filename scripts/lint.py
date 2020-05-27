# Copyright (c) 2020 University System of Georgia and GTCOARLab Contributors
# Distributed under the terms of the BSD-3-Clause License
import sys

from . import paths as P
from . import utils as U

PY_LINTERS = [
    ["isort", "-rc", *P.LINTERS["py"]],
    ["black", *P.LINTERS["py"]],
    ["flake8", *P.LINTERS["py"]],
]

YAML_LINTERS = [["yamllint", *P.LINTERS["yaml"]]]


def lint_py():
    for lint_args in PY_LINTERS:
        lint_rc = U._(lint_args)
        if lint_rc != 0:
            break
    return lint_rc


def lint_yaml():
    for lint_args in YAML_LINTERS:
        lint_rc = U._(lint_args)
        if lint_rc != 0:
            break
    return lint_rc


def lint_prettier():
    return U._(["yarn", "prettier", "--write", *P.LINTERS["prettier"]])


def lint(targets):
    lint_rc = 1
    for target in targets:
        linter = globals().get(f"lint_{target}")
        if not linter:
            print(f"don't know how to lint {target}")
            break
        lint_rc = linter()
        if lint_rc != 0:
            break
    return lint_rc


if __name__ == "__main__":
    sys.exit(lint(sys.argv[1:] or ["prettier", "py", "yaml"]))