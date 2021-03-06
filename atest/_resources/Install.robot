# Copyright (c) 2021 University System of Georgia and GTCOARLab Contributors
# Distributed under the terms of the BSD-3-Clause License

*** Settings ***
Documentation     Install an Installer
Library           OperatingSystem
Library           Process
Resource          ./Cleanup.robot
Resource          ./Variables.robot
Resource          ./Shell.robot
Resource          ./JSON.robot

*** Keywords ***
Maybe Run the Installer
    [Documentation]    Run the installer, if not already installed
    ${history} =    Normalize Path    ${INST_DIR}${/}conda-meta${/}history
    ${installed} =    Evaluate    __import__('os.path').path.exists(r"""${history}""")
    Run Keyword If    ${installed}
    ...    Log    Already installed!
    ...    ELSE
    ...    Run The Installer
    Validate the Installation

Run the Installer
    [Documentation]    Run the platform-specific installer
    File Should Exist    ${INSTALLER}
    ${path} =    Set Variable    ${OUTPUT DIR}
    Set Global Variable    ${HOME}    ${path}${/}home
    ${rc} =
    ...    Run Keyword If    "${OS}" == "Linux"
    ...    Run the Linux Installer
    ...    ELSE IF    "${OS}" == "Windows"
    ...    Run the Windows Installer
    ...    ELSE IF    "${OS}" == "Darwin"
    ...    Run the MacOSX Installer
    ...    ELSE
    ...    Fatal Error    Can't install on platform ${OS}!
    Should Be Equal as Integers    ${rc}    0
    ...    msg=Couldn't complete installer, see ${INSTALL LOG}
    ${post} =   Set Variable    ${INST_DIR}${/}post_install.log
    Wait Until Created    ${post}   timeout=1000s
    [Teardown]   List Files In Installation Directory

List Files In Installation Directory
    [Documentation]   List all of the files in the root of the installation
    ${files} =   List Directory   ${INST_DIR}
    Create File as JSON   ${OUTPUT DIR}${/}post-install-files.json    ${files}

Validate the Installation
    [Documentation]    Ensure some baseline commands work
    ${post} =   Set Variable    ${INST_DIR}${/}post_install.log
    ${postinstall log} =  Get File   ${post}
    Log    ${postinstall log}
    Wait Until Keyword Succeeds    5x    10s
    ...    Run Shell Script in Installation
    ...    mamba info
    Run Shell Script in Installation
    ...    mamba list --explicit > ${OUTPUT DIR}${/}conda.lock
    Run Shell Script in Installation
    ...    python -m pip freeze > ${OUTPUT DIR}${/}requirements.txt

Run the Linux installer
    [Documentation]    Install on Linux
    Set Global Variable    ${ACTIVATE SCRIPT}    ${INST_DIR}${/}bin${/}activate
    Set Global Variable    ${ACTIVATE}    . "${ACTIVATE SCRIPT}" "${INST_DIR}" && set -eux
    Set Global Variable    ${PATH ENV}    ${INST_DIR}${/}bin:%{PATH}
    ${result} =    Run Process    bash    ${INSTALLER}    -fbp    ${INST_DIR}
    ...    stdout=${INSTALL LOG}    stderr=STDOUT
    [Return]    ${result.rc}

Run the MacOSX installer
    [Documentation]    Install on OSX
    Set Global Variable    ${ACTIVATE SCRIPT}    ${INST_DIR}${/}bin${/}activate
    Set Global Variable    ${ACTIVATE}    . "${ACTIVATE SCRIPT}" "${INST_DIR}"
    Set Global Variable    ${PATH ENV}    ${INST_DIR}${/}bin${:}%{PATH}
    ${result} =    Run Process    bash    ${INSTALLER}    -fbp    ${INST_DIR}
    ...    stdout=${INSTALL LOG}    stderr=STDOUT
    [Return]    ${result.rc}

Run the Windows installer
    [Documentation]    Install on Windows
    Set Global Variable    ${ACTIVATE SCRIPT}    ${INST_DIR}${/}Scripts${/}activate.bat
    Set Global Variable    ${ACTIVATE}    call "${ACTIVATE SCRIPT}" "${INST_DIR}"
    Set Global Variable    ${PATH ENV}
    ...    ${INST_DIR}${:}${INST_DIR}${/}Scripts${:}${INST_DIR}${/}Library${/}bin${:}%{PATH}
    ${args} =    Set Variable
    ...    /InstallationType=JustMe /AddToPath=0 /RegisterPython=0 /S /D=${INST_DIR}
    ${result} =    Run Process    ${INSTALLER} ${args}
    ...    stdout=${INSTALL LOG}    stderr=STDOUT    shell=True
    [Return]    ${result.rc}

Get GeckoDriver
    [Documentation]    Get the path to the bundled geckodriver
    ${path} =    Set Variable    ${INST_DIR}${/}&{GECKODRIVER}[${OS}]
    File Should Exist    ${path}
    [Return]    ${path}

Get Firefox
    [Documentation]    Get the path to the bundled firefox
    ${path} =    Set Variable    ${INST_DIR}${/}${FIREFOX}[${OS}]
    File Should Exist    ${path}
    [Return]    ${path}
