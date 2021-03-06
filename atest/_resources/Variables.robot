# Copyright (c) 2021 University System of Georgia and GTCOARLab Contributors
# Distributed under the terms of the BSD-3-Clause License

*** Settings ***
Documentation     Variables used in more than one places

*** Variables ***
${INSTALL LOG}    ${OUTPUT DIR}${/}00_installer.log
&{GECKODRIVER}
...               Darwin=bin${/}geckodriver
...               Linux=bin${/}geckodriver
...               Windows=Scripts${/}geckodriver.exe
&{FIREFOX}
...               Darwin=bin${/}firefox
...               Linux=bin${/}firefox
...               Windows=Library${/}bin${/}firefox.exe