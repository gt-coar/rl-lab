# Copyright (c) 2021 University System of Georgia and GTCOARLab Contributors
# Distributed under the terms of the BSD-3-Clause License

*** Settings ***
Documentation     Keywords for starting GTCOARLab
Library           String
Library           JupyterLibrary
Library           Collections

*** Keywords ***
Start GTCOARLab
    [Documentation]    Custom invocation of jupyter-server
    ${port} =    Get Unused Port
    ${token} =    Generate Random String    64
    ${base url} =    Set Variable    /co@r/
    ${notebook dir} =    Set Variable    ${OUTPUT DIR}${/}notebooks
    @{args} =    Build GTCOARLab Args    ${port}    ${token}    ${base url}
    &{config} =   Create Dictionary   stdout=${OUTPUT DIR}${/}lab.log   stderr=STDOUT
    ${reset} =   Set Variable   http://127.0.0.1:${port}${base url}lab?reset&token=${token}
    Set Suite Variable    ${LAB RESET URL}    ${reset}   children=${True}
    ${lab} =    Start New Jupyter Server
    ...    conda
    ...    ${port}
    ...    ${base url}
    ...    ${notebook dir}
    ...    ${token}
    ...    @{args}
    ...    &{config}
    Wait For Jupyter Server To Be Ready    ${lab}
    Open JupyterLab
    Wait for GTCOARLab to Open
    Tag With JupyterLab Metadata

Wait for GTCOARLab to Open
    [Documentation]     Generate some args
    Go To   ${LAB RESET URL}
    Set Window Size    1440    900
    Run Keyword and Ignore Error
    ...    Wait Until Keyword Succeeds   3x   5s
    ...    Wait for JupyterLab Splash Screen
    Page Should Contain Element    css:.jp-Launcher

Build GTCOARLab Args
    [Arguments]    ${port}    ${token}    ${base url}
    [Documentation]     Generate some args
    @{args} =    Set Variable
    ...    run
    ...    --prefix    ${INST_DIR}    --no-capture-output
    ...    jupyter-lab
    ...    --no-browser
    ...    --debug
    ...    --expose-app-in-browser
    ...    --port\=${port}
    ...    --ServerApp.token\=${token}
    ...    --ServerApp.base_url\=${base url}
    Log    ${args}
    [Return]    @{args}
