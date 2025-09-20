@echo off
REM Define the path to your Godot executable
SET GODOT_PATH="C:\Tools\Godot_v4.4.1-stable_win64.exe"

REM Run the tests
%GODOT_PATH% --path . -s res://tests/test_harness.tscn -gselect=res://tests -gexit
