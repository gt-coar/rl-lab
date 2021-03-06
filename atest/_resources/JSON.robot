# Copyright (c) 2021 University System of Georgia and GTCOARLab Contributors
# Distributed under the terms of the BSD-3-Clause License

*** Settings ***
Documentation   Tools for working with JSON
Library    OperatingSystem
Library    json   WITH NAME   JSON

*** Keywords ***
Load JSON from String
    [Arguments]  ${text}
    [Documentation]   Ensure properly-quoted JSON parsing
    ${loaded} =    JSON.loads  ${text}
    [Return]    ${loaded}

Get File as JSON
    [Arguments]   ${path}
    [Documentation]   Load JSON from a file
    ${text} =    Get File    ${path}
    ${loaded} =    Load JSON from String   ${text}
    [Return]     ${loaded}

Create File as JSON
    [Arguments]   ${path}  ${data}    ${indent}=${2}  ${sort_keys}=${TRUE}
    [Documentation]   Write a JSON file
    ${text} =    JSON.dumps    ${data}   indent=${indent}   sort_keys=${sort_keys}
    Create File   ${path}   ${text}
