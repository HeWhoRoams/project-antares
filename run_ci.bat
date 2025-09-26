@echo off
echo Running Godot Unit Tests (GUT) for Project Antares...

REM Path to your Godot executable.
REM If it's in your system's PATH, you can just use "godot.exe".
SET GODOT_EXECUTABLE="C:\Tools\godot.exe"

REM Run GUT's command-line interface script.
REM -gdir=res://tests runs all tests in the tests directory.
REM -gexit=true tells Godot to exit after the tests are complete.
REM -gjunit_xml_file tells GUT to export results to the specified file.
%GODOT_EXECUTABLE% --headless -s res://addons/gut/gut_cmdln.gd -gdir=res://tests -gexit=true -gjunit_xml_file=res://test_results.xml

IF %ERRORLEVEL% NEQ 0 (
    echo.
    echo Tests failed with exit code %ERRORLEVEL%.
    exit /b %ERRORLEVEL%
)

echo.
echo All tests passed.
exit /b 0
