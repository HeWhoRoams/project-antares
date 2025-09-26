@echo off
setlocal enabledelayedexpansion

echo ===============================================================================
echo Project Antares - Enhanced CI/CD Pipeline with GDScript Toolkit Integration
echo ===============================================================================
echo Timestamp: %DATE% %TIME%
echo.

REM Configuration
SET GODOT_EXECUTABLE="C:\Tools\godot.exe"
SET TEST_RESULTS_FILE="test_results.xml"
SET LOG_FILE="ci_pipeline_detailed.log"
SET GD_TOOLKIT_AVAILABLE=0
SET STATIC_ANALYSIS_PERFORMED=0

echo [INFO] Starting enhanced CI/CD pipeline with GDScript Toolkit integration...
echo [INFO] Logging detailed output to: %LOG_FILE%
echo [INFO] Test results will be saved to: %TEST_RESULTS_FILE%
echo.

REM Initialize counters and flags
SET ERROR_COUNT=0
SET WARNING_COUNT=0
SET CRITICAL_ERROR_DETECTED=0
SET SCRIPT_LOAD_FAILURES=0
SET PARSE_ERROR_COUNT=0
SET MISSING_CLASS_COUNT=0
SET STATIC_ANALYSIS_ERRORS=0
SET FORMATTING_ISSUES=0

echo [PHASE 1] Pre-flight Validation and Tool Setup
echo =================================================
echo.

REM Check if Godot executable exists
if not exist C:\Tools\godot.exe (
    echo [ERROR] Godot executable not found at C:\Tools\godot.exe
    echo [ERROR] Please verify Godot installation path
    SET /A ERROR_COUNT+=1
    SET CRITICAL_ERROR_DETECTED=1
    goto :error_summary
)

echo [OK] Godot executable found at C:\Tools\godot.exe

REM Check for GDScript Toolkit availability and install if needed
echo [CHECK] Checking GDScript Toolkit availability...
where gdlint >nul 2>&1
if %errorlevel% equ 0 (
    echo [OK] GDlint found - static analysis will be performed
    SET GD_TOOLKIT_AVAILABLE=1
) else (
    echo [INFO] GDlint not found - attempting to install GDToolkit...
    pip install gdtoolkit --quiet >nul 2>&1
    if !errorlevel! equ 0 (
        where gdlint >nul 2>&1
        if !errorlevel! equ 0 (
            echo [OK] GDToolkit installed and GDlint available
            SET GD_TOOLKIT_AVAILABLE=1
        ) else (
            echo [WARNING] GDToolkit installed but GDlint not found
            SET /A WARNING_COUNT+=1
        )
    ) else (
        echo [WARNING] Failed to install GDToolkit - static analysis will be skipped
        SET /A WARNING_COUNT+=1
    )
)

REM Verify GDToolkit components
if %GD_TOOLKIT_AVAILABLE% equ 1 (
    where gdformat >nul 2>&1
    if !errorlevel! equ 0 (
        echo [OK] GDFormat found
    ) else (
        echo [INFO] GDFormat not available - formatting checks will be skipped
    )
    
    where gddoc >nul 2>&1
    if !errorlevel! equ 0 (
        echo [OK] GDDoc found
    ) else (
        echo [INFO] GDDoc not available - documentation checks will be skipped
    )
)

REM Check for essential project files
echo [CHECK] Verifying project structure...

if not exist "project.godot" (
    echo [ERROR] project.godot file not found - this is not a Godot project directory
    SET /A ERROR_COUNT+=1
    SET CRITICAL_ERROR_DETECTED=1
) else (
    echo [OK] Project file found
)

if not exist "scripts\" (
    echo [WARNING] Scripts directory not found
    SET /A WARNING_COUNT+=1
) else (
    echo [OK] Scripts directory exists
)

if not exist "gamedata\" (
    echo [WARNING] Game data directory not found
    SET /A WARNING_COUNT+=1
) else (
    echo [OK] Game data directory exists
)

if not exist "tests\" (
    echo [ERROR] Tests directory not found - cannot run unit tests
    SET /A ERROR_COUNT+=1
) else (
    echo [OK] Tests directory exists
)

echo.
echo [PHASE 2] Static Code Analysis with GDScript Toolkit
echo ======================================================
echo.

if %GD_TOOLKIT_AVAILABLE% equ 1 (
    echo [STATIC ANALYSIS] Running GDScript linting and formatting checks...
    
    REM Check if configuration files exist
    if exist ".gdlint" (
        echo [CONFIG] Using .gdlint configuration file
        SET GDLINT_CONFIG="--config .gdlint"
    ) else (
        echo [CONFIG] Using default GDlint configuration
        SET GDLINT_CONFIG=""
    )
    
    if exist ".gdformat" (
        echo [CONFIG] Using .gdformat configuration file
        SET GDFORMAT_CONFIG="--config .gdformat"
    ) else (
        echo [CONFIG] Using default GDFormat configuration
        SET GDFORMAT_CONFIG=""
    )
    
    REM Run GDlint syntax and style checking
    echo [GDLINT] Running syntax and style analysis...
    gdlint %GDLINT_CONFIG% scripts/**/*.gd gamedata/**/*.gd managers/**/*.gd tests/**/*.gd 2> gdlint_errors.log
    SET GDLINT_EXIT_CODE=%ERRORLEVEL%
    
    if %GDLINT_EXIT_CODE% neq 0 (
        echo [WARNING] GDlint found code quality issues
        SET /A WARNING_COUNT+=1
        SET STATIC_ANALYSIS_ERRORS=1
        
        REM Count the errors
        findstr /C:"error" gdlint_errors.log > nul
        if !errorlevel! equ 0 (
            for /f %%i in ('type gdlint_errors.log ^| find /c /v ""') do SET GDLINT_ERROR_COUNT=%%i
            echo [GDLINT] Found !GDLINT_ERROR_COUNT! issues in GDScript files
        )
        
        REM Show sample errors
        echo [GDLINT SAMPLE ERRORS:]
        findstr /N /C:"error" gdlint_errors.log | head -n 5
        echo.
    ) else (
        echo [OK] GDlint analysis completed with no critical issues
    )
    
    REM Run GDFormat formatting validation
    echo [GDFORMAT] Checking code formatting compliance...
    gdformat %GDFORMAT_CONFIG% --check scripts/**/*.gd gamedata/**/*.gd managers/**/*.gd tests/**/*.gd 2> format_errors.log
    SET GDFORMAT_EXIT_CODE=%ERRORLEVEL%
    
    if %GDFORMAT_EXIT_CODE% neq 0 (
        echo [WARNING] GDFormat found formatting inconsistencies
        SET /A WARNING_COUNT+=1
        SET FORMATTING_ISSUES=1
        
        REM Count formatting issues
        findstr /C:"would reformat" format_errors.log > nul
        if !errorlevel! equ 0 (
            for /f %%i in ('type format_errors.log ^| findstr /C:"would reformat" ^| find /c /v ""') do SET FORMAT_ISSUE_COUNT=%%i
            echo [GDFORMAT] Found !FORMAT_ISSUE_COUNT! files with formatting issues
        )
    ) else (
        echo [OK] All GDScript files are properly formatted
    )
    
    SET STATIC_ANALYSIS_PERFORMED=1
    echo [STATIC ANALYSIS] Completed - see detailed logs for issues
) else (
    echo [SKIP] GDScript Toolkit not available - skipping static analysis
)

echo.
echo [PHASE 3] Resource and Asset Validation
echo ========================================
echo.

REM Check for missing essential assets
echo [CHECK] Checking for critical missing assets...

SET ASSET_MISSING_COUNT=0
for %%f in (
    "assets/audio/sfx/ui/ui_hover.wav"
    "assets/audio/sfx/ui/ui_confirm.wav" 
    "assets/audio/sfx/ui/ui_back.wav"
    "assets/audio/sfx/ui/ui_error.wav"
    "assets/icons/population.png"
) do (
    if not exist "%%f" (
        echo [WARNING] Missing asset: %%f
        SET /A ASSET_MISSING_COUNT+=1
        SET /A WARNING_COUNT+=1
    )
)

if %ASSET_MISSING_COUNT% equ 0 (
    echo [OK] All critical assets found
) else (
    echo [WARNING] %ASSET_MISSING_COUNT% critical assets missing
)

echo.
echo [PHASE 4] Script Compilation and Loading Test
echo =============================================
echo.

REM Create a temporary log file for detailed analysis
echo [INFO] Running Godot with detailed error capture...
echo [CMD] %GODOT_EXECUTABLE% --headless --verbose --debug

REM Run Godot with verbose output to capture more detailed information
%GODOT_EXECUTABLE% --headless --verbose -s res://addons/gut/gut_cmdln.gd -gdir=res://tests -gexit=true -gjunit_xml_file=%TEST_RESULTS_FILE% 2>&1 | findstr /V "VERBOSE DEBUG" > %LOG_FILE%

REM Also capture the full verbose output for analysis
%GODOT_EXECUTABLE% --headless --verbose -s res://addons/gut/gut_cmdln.gd -gdir=res://tests -gexit=true -gjunit_xml_file=%TEST_RESULTS_FILE% > temp_verbose.log 2>&1

echo.
echo [PHASE 5] Detailed Error Analysis
echo ==================================
echo.

REM Analyze the log file for specific error patterns
echo [ANALYSIS] Parsing error patterns from execution...

REM Count different types of errors
findstr /C:"Parse Error" %LOG_FILE% > parse_errors.log
for /f %%i in ('type parse_errors.log ^| find /c /v ""') do SET PARSE_ERROR_COUNT=%%i

findstr /C:"Failed to load script" %LOG_FILE% > script_failures.log  
for /f %%i in ('type script_failures.log ^| find /c /v ""') do SET SCRIPT_LOAD_FAILURES=%%i

findstr /C:"Could not find type" %LOG_FILE% > missing_types.log
for /f %%i in ('type missing_types.log ^| find /c /v ""') do SET MISSING_CLASS_COUNT=%%i

findstr /C:"SCRIPT ERROR" %LOG_FILE% > script_errors.log
for /f %%i in ('type script_errors.log ^| find /c /v ""') do SET SCRIPT_ERROR_COUNT=%%i

echo [RESULTS] Error Analysis Summary:
echo    - Parse Errors: %PARSE_ERROR_COUNT%
echo    - Script Load Failures: %SCRIPT_LOAD_FAILURES%  
echo    - Missing Class Definitions: %MISSING_CLASS_COUNT%
echo    - Total Script Errors: %SCRIPT_ERROR_COUNT%

REM Check for critical system failures
findstr /C:"Failed to instantiate an autoload" %LOG_FILE% > autoload_failures.log
for /f %%i in ('type autoload_failures.log ^| find /c /v ""') do SET AUTOLOAD_FAILURES=%%i

echo    - Autoload Instantiation Failures: %AUTOLOAD_FAILURES%

if %AUTOLOAD_FAILURES% GTR 0 (
    echo [CRITICAL] Autoload system failures detected - core game systems not loading!
    SET CRITICAL_ERROR_DETECTED=1
)

if %SCRIPT_LOAD_FAILURES% GTR 0 (
    echo [CRITICAL] Script loading failures detected - dependencies not resolved!
    SET CRITICAL_ERROR_DETECTED=1
)

if %PARSE_ERROR_COUNT% GTR 0 (
    echo [CRITICAL] Parse errors detected - syntax issues in scripts!
    SET CRITICAL_ERROR_DETECTED=1
)

echo.
echo [PHASE 6] Test Execution Results
echo =================================
echo.

REM Check the actual exit code
SET EXIT_CODE=%ERRORLEVEL%
echo [RESULT] Process exited with code: %EXIT_CODE%

REM Analyze test results if they exist
if exist %TEST_RESULTS_FILE% (
    echo [OK] Test results file generated: %TEST_RESULTS_FILE%
    REM Count test results
    findstr /C:"testsuite" %TEST_RESULTS_FILE% > test_suites.log
    for /f %%i in ('type test_suites.log ^| find /c /v ""') do SET TEST_SUITE_COUNT=%%i
    
    findstr /C:"testcase" %TEST_RESULTS_FILE% > test_cases.log  
    for /f %%i in ('type test_cases.log ^| find /c /v ""') do SET TEST_CASE_COUNT=%%i
    
    findstr /C:"failure" %TEST_RESULTS_FILE% > test_failures.log
    for /f %%i in ('type test_failures.log ^| find /c /v ""') do SET TEST_FAILURE_COUNT=%%i
    
    echo [TEST SUMMARY] Test Results Analysis:
    echo    - Test Suites: %TEST_SUITE_COUNT%
    echo    - Test Cases: %TEST_CASE_COUNT% 
    echo    - Test Failures: %TEST_FAILURE_COUNT%
    
    if %TEST_FAILURE_COUNT% GTR 0 (
        echo [WARNING] Some tests failed - see detailed results
        SET /A WARNING_COUNT+=1
    )
) else (
    echo [WARNING] No test results file generated
    SET /A WARNING_COUNT+=1
)

echo.
echo [PHASE 7] Final Status Assessment
echo =================================
echo.

REM Determine overall pipeline status
if %CRITICAL_ERROR_DETECTED% EQU 1 (
    echo [STATUS] ❌ PIPELINE FAILED - Critical errors detected
    echo [REASON] Core systems failed to load - game cannot run properly
    echo [ACTION] Fix critical compilation and loading errors before proceeding
    SET PIPELINE_STATUS=FAILED
    goto :error_summary
)

if %EXIT_CODE% NEQ 0 (
    echo [STATUS] ❌ PIPELINE FAILED - Process exited with error code %EXIT_CODE%
    echo [ACTION] Investigate the cause of non-zero exit code
    SET PIPELINE_STATUS=FAILED
    goto :error_summary
)

if %TEST_FAILURE_COUNT% GTR 0 (
    echo [STATUS] ⚠️  PIPELINE PARTIAL SUCCESS - Tests executed but some failed
    echo [ACTION] Review failed tests and address issues
    SET PIPELINE_STATUS=PARTIAL
) else (
    echo [STATUS] ✅ PIPELINE SUCCESS - All systems loaded and tests passed
    SET PIPELINE_STATUS=SUCCESS
)

goto :summary

:error_summary
echo.
echo ===============================================================================
echo ERROR SUMMARY
echo ===============================================================================
echo.

if exist parse_errors.log (
    echo [PARSE ERRORS DETECTED:]
    type parse_errors.log | findstr /C:"Parse Error"
    echo.
)

if exist script_failures.log (
    echo [SCRIPT LOADING FAILURES:]
    type script_failures.log | findstr /C:"Failed to load script"
    echo.
)

if exist missing_types.log (
    echo [MISSING CLASS DEFINITIONS:]
    type missing_types.log | findstr /C:"Could not find type"
    echo.
)

if exist autoload_failures.log (
    echo [AUTOLOAD FAILURES:]
    type autoload_failures.log | findstr /C:"Failed to instantiate an autoload"
    echo.
)

if %STATIC_ANALYSIS_ERRORS% EQU 1 (
    echo [STATIC ANALYSIS ERRORS:]
    type gdlint_errors.log | findstr /C:"error" | head -n 10
    echo.
)

if %FORMATTING_ISSUES% EQU 1 (
    echo [FORMATTING ISSUES:]
    type format_errors.log | findstr /C:"would reformat" | head -n 10
    echo.
)

:summary
echo.
echo ===============================================================================
echo FINAL PIPELINE REPORT
echo ===============================================================================
echo Timestamp: %DATE% %TIME%
echo.
echo Overall Status: %PIPELINE_STATUS%
echo Critical Errors: %CRITICAL_ERROR_DETECTED%
echo Parse Errors: %PARSE_ERROR_COUNT%
echo Script Load Failures: %SCRIPT_LOAD_FAILURES%
echo Missing Classes: %MISSING_CLASS_COUNT%
echo Autoload Failures: %AUTOLOAD_FAILURES%
echo Test Failures: %TEST_FAILURE_COUNT%
echo Static Analysis Errors: %STATIC_ANALYSIS_ERRORS%
echo Formatting Issues: %FORMATTING_ISSUES%
echo Warnings: %WARNING_COUNT%
echo Exit Code: %EXIT_CODE%
echo Static Analysis Performed: %STATIC_ANALYSIS_PERFORMED%
echo.

if "%PIPELINE_STATUS%"=="FAILED" (
    echo 💥 PIPELINE RESULT: ❌ CRITICAL FAILURE
    echo    The pipeline detected critical errors that prevent proper execution.
    echo    These errors must be fixed before the system can run correctly.
    exit /b 1
) else if "%PIPELINE_STATUS%"=="PARTIAL" (
    echo ⚠️  PIPELINE RESULT: ⚠️  PARTIAL SUCCESS  
    echo    Tests executed but some failed. Review results and address issues.
    exit /b 0
) else (
    echo ✅ PIPELINE RESULT: ✅ COMPLETE SUCCESS
    echo    All systems loaded successfully and all tests passed.
    exit /b 0
)

echo.
echo Detailed logs saved to: %LOG_FILE%
echo Test results saved to: %TEST_RESULTS_FILE%
if %STATIC_ANALYSIS_PERFORMED% EQU 1 (
    echo GDlint errors saved to: gdlint_errors.log
    echo Formatting issues saved to: format_errors.log
)
echo.

endlocal
