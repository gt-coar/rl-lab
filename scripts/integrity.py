# Copyright (c) 2020 University System of Georgia and GTCOARLab Contributors
# Distributed under the terms of the BSD-3-Clause License

import pathlib
import re
import sys
import tempfile
from datetime import datetime

import pytest

from . import meta as M
from . import paths as P

PYTEST_INI = """
[pytest]
junit_family = xunit2
addopts =
    -vv
    --junitxml dist/xunit/integrity.xunit.xml
"""

VERSIONS = {
    P.LAB_PACKAGE / "src" / P.LAB_MODULE / "_version.py": r"""__version__ = "(.*?)\"""",
    P.RECIPES / P.LAB_NAME / "meta.yaml": r"""{% set version = "(.*?)" %}""",
}

YEAR = datetime.today().year
COPYRIGHT_HEADER = (
    f"{YEAR} University System of Georgia and {M.INSTALLER_NAME} Contributors"
)
LICENSE_HEADER = "Distributed under the terms of the BSD-3-Clause License"


def test_integrity_lab_versions():
    """ all lab versions agree with the TRUTH
    """
    versions = {
        path: re.findall(pattern, path.read_text())
        for path, pattern in VERSIONS.items()
    }
    for path, found_versions in versions.items():
        assert M.LAB_VERSION in found_versions, path


@pytest.mark.parametrize(
    "the_file,the_path",
    [[path.name, path] for path in [*P.ALL_PY, *P.ALL_MD, *P.ALL_YAML]],
)
def test_integrity_headers(the_file, the_path):
    the_text = the_path.read_text()
    assert COPYRIGHT_HEADER in the_text
    assert LICENSE_HEADER in the_text


def check_integrity():
    """ actually run the tests
    """
    args = [__file__]

    with tempfile.TemporaryDirectory() as tmp:
        ini = pathlib.Path(tmp) / "pytest.ini"
        ini.write_text(PYTEST_INI)

        args += ["-c", str(ini)]

        return pytest.main(args)


if __name__ == "__main__":
    sys.exit(check_integrity())