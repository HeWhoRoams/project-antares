@echo off
setlocal enabledelayedexpansion

echo ===============================================================================
echo Project Antares - Advanced Debug Monitor and Error Analyzer
echo ===============================================================================
echo Timestamp: %DATE% %TIME%
echo.

REM Configuration
SET LOG_FILE="debug_monitor.log"
SET ERROR_LOG="error_analysis.log"
SET WARNING_LOG="warning_analysis.log"
SET VERBOSE_LOG="verbose_debug.log"
SET SUMMARY_LOG="debug_summary.log"

echo [INFO] Starting advanced debug monitoring...
echo [INFO] Logging to: %LOG_FILE%
echo [INFO] Error analysis to: %ERROR_LOG%
echo [INFO] Warning analysis to: %WARNING_LOG%
echo [INFO] Verbose debug to: %VERBOSE_LOG%
echo [INFO] Summary report to: %SUMMARY_LOG%
echo.

REM Initialize counters
SET TOTAL_ERRORS=0
SET TOTAL_WARNINGS=0
SET PARSE_ERRORS=0
SET SCRIPT_LOAD_ERRORS=0
SET MISSING_CLASSES=0
SET AUTOLOAD_ERRORS=0
SET RESOURCE_ERRORS=0
SET FUNCTION_CALL_ERRORS=0
SET DATA_ACCESS_ERRORS=0
SET MEMORY_LEAKS=0
SET TEST_FAILURES=0

echo [PHASE 1] Comprehensive Error Collection
echo =======================================
echo.

REM Run enhanced CI/CD pipeline with maximum verbosity
echo [EXEC] Running enhanced CI/CD pipeline with verbose output...
.\enhanced_ci_with_gdlint.bat > %VERBOSE_LOG% 2>&1

SET PIPELINE_EXIT_CODE=%ERRORLEVEL%
echo [RESULT] Pipeline exited with code: %PIPELINE_EXIT_CODE%

echo.
echo [PHASE 2] Detailed Error Analysis
echo =================================
echo.

REM Extract all error patterns from verbose log
echo [ANALYSIS] Parsing comprehensive error patterns...

REM Parse errors
findstr /C:"Parse Error" %VERBOSE_LOG% > parse_errors_temp.log 2>nul
for /f %%i in ('type parse_errors_temp.log ^| find /c /v ""') do SET PARSE_ERRORS=%%i

REM Script loading errors
findstr /C:"Failed to load script" %VERBOSE_LOG% > script_load_errors_temp.log 2>nul
for /f %%i in ('type script_load_errors_temp.log ^| find /c /v ""') do SET SCRIPT_LOAD_ERRORS=%%i

REM Missing class definitions
findstr /C:"Could not find type" %VERBOSE_LOG% > missing_classes_temp.log 2>nul
for /f %%i in ('type missing_classes_temp.log ^| find /c /v ""') do SET MISSING_CLASSES=%%i

REM Autoload errors
findstr /C:"Failed to instantiate an autoload" %VERBOSE_LOG% > autoload_errors_temp.log 2>nul
for /f %%i in ('type autoload_errors_temp.log ^| find /c /v ""') do SET AUTOLOAD_ERRORS=%%i

REM Resource loading errors
findstr /C:"Failed loading resource" %VERBOSE_LOG% > resource_errors_temp.log 2>nul
for /f %%i in ('type resource_errors_temp.log ^| find /c /v ""') do SET RESOURCE_ERRORS=%%i

REM Function call errors
findstr /C:"Invalid call" %VERBOSE_LOG% > function_call_errors_temp.log 2>nul
for /f %%i in ('type function_call_errors_temp.log ^| find /c /v ""') do SET FUNCTION_CALL_ERRORS=%%i

REM Data access errors
findstr /C:"Invalid access to property" %VERBOSE_LOG% > data_access_errors_temp.log 2>nul
for /f %%i in ('type data_access_errors_temp.log ^| find /c /v ""') do SET DATA_ACCESS_ERRORS=%%i

REM Memory leaks
findstr /C:"ObjectDB instances leaked" %VERBOSE_LOG% > memory_leaks_temp.log 2>nul
for /f %%i in ('type memory_leaks_temp.log ^| find /c /v ""') do SET MEMORY_LEAKS=%%i

REM Test failures
findstr /C:"failure" %VERBOSE_LOG% > test_failures_temp.log 2>nul
for /f %%i in ('type test_failures_temp.log ^| find /c /v ""') do SET TEST_FAILURES=%%i

REM Calculate total errors
SET /A TOTAL_ERRORS=%PARSE_ERRORS%+%SCRIPT_LOAD_ERRORS%+%MISSING_CLASSES%+%AUTOLOAD_ERRORS%+%RESOURCE_ERRORS%+%FUNCTION_CALL_ERRORS%+%DATA_ACCESS_ERRORS%
SET /A TOTAL_WARNINGS=%MEMORY_LEAKS%+%TEST_FAILURES%

echo [RESULTS] Error Analysis Summary:
echo    - Parse Errors: %PARSE_ERRORS%
echo    - Script Load Errors: %SCRIPT_LOAD_ERRORS%
echo    - Missing Classes: %MISSING_CLASSES%
echo    - Autoload Errors: %AUTOLOAD_ERRORS%
echo    - Resource Errors: %RESOURCE_ERRORS%
echo    - Function Call Errors: %FUNCTION_CALL_ERRORS%
echo    - Data Access Errors: %DATA_ACCESS_ERRORS%
echo    - Total Critical Errors: %TOTAL_ERRORS%
echo    - Memory Leaks: %MEMORY_LEAKS%
echo    - Test Failures: %TEST_FAILURES%
echo    - Total Warnings: %TOTAL_WARNINGS%
echo.

echo [PHASE 3] Categorized Error Reporting
echo ====================================
echo.

REM Categorize and report parse errors
if %PARSE_ERRORS% GTR 0 (
    echo [PARSE ERRORS CATEGORIZED:]
    echo ==========================
    
    REM Indentation errors
    findstr /C:"Expected statement, found 'Indent' instead" parse_errors_temp.log > indent_errors.log 2>nul
    for /f %%i in ('type indent_errors.log ^| find /c /v ""') do SET INDENT_ERRORS=%%i
    if %INDENT_ERRORS% GTR 0 (
        echo    - Indentation Errors: %INDENT_ERRORS%
        echo      Sample indent errors:
        type indent_errors.log | head -n 3
        echo.
    )
    
    REM Syntax errors
    findstr /C:"Parse Error" parse_errors_temp.log | findstr /V "Expected statement, found 'Indent' instead" > syntax_errors.log 2>nul
    for /f %%i in ('type syntax_errors.log ^| find /c /v ""') do SET SYNTAX_ERRORS=%%i
    if %SYNTAX_ERRORS% GTR 0 (
        echo    - Syntax Errors: %SYNTAX_ERRORS%
        echo      Sample syntax errors:
        type syntax_errors.log | head -n 3
        echo.
    )
)

REM Categorize and report script loading errors
if %SCRIPT_LOAD_ERRORS% GTR 0 (
    echo [SCRIPT LOADING ERRORS CATEGORIZED:]
    echo ==================================
    
    REM Missing dependencies
    findstr /C:"Failed to load script" script_load_errors_temp.log > missing_deps.log 2>nul
    for /f %%i in ('type missing_deps.log ^| find /c /v ""') do SET MISSING_DEPS=%%i
    if %MISSING_DEPS% GTR 0 (
        echo    - Missing Dependencies: %MISSING_DEPS%
        echo      Sample dependency errors:
        type missing_deps.log | head -n 3
        echo.
    )
)

REM Categorize and report missing classes
if %MISSING_CLASSES% GTR 0 (
    echo [MISSING CLASS ERRORS CATEGORIZED:]
    echo =================================
    
    REM Critical missing classes
    findstr /C:"Could not find type" missing_classes_temp.log > critical_missing.log 2>nul
    for /f %%i in ('type critical_missing.log ^| find /c /v ""') do SET CRITICAL_MISSING=%%i
    if %CRITICAL_MISSING% GTR 0 (
        echo    - Critical Missing Classes: %CRITICAL_MISSING%
        echo      Sample missing class errors:
        type critical_missing.log | head -n 5
        echo.
    )
)

REM Categorize and report autoload errors
if %AUTOLOAD_ERRORS% GTR 0 (
    echo [AUTOLOAD ERRORS CATEGORIZED:]
    echo =============================
    
    REM Manager instantiation failures
    findstr /C:"Failed to instantiate an autoload" autoload_errors_temp.log > manager_failures.log 2>nul
    for /f %%i in ('type manager_failures.log ^| find /c /v ""') do SET MANAGER_FAILURES=%%i
    if %MANAGER_FAILURES% GTR 0 (
        echo    - Manager Instantiation Failures: %MANAGER_FAILURES%
        echo      Sample manager failures:
        type manager_failures.log | head -n 3
        echo.
    )
)

REM Categorize and report resource errors
if %RESOURCE_ERRORS% GTR 0 (
    echo [RESOURCE LOADING ERRORS CATEGORIZED:]
    echo ====================================
    
    REM Missing assets
    findstr /C:"Failed loading resource" resource_errors_temp.log > missing_assets.log 2>nul
    for /f %%i in ('type missing_assets.log ^| find /c /v ""') do SET MISSING_ASSETS=%%i
    if %MISSING_ASSETS% GTR 0 (
        echo    - Missing Assets: %MISSING_ASSETS%
        echo      Sample missing assets:
        type missing_assets.log | head -n 3
        echo.
    )
)

REM Categorize and report function call errors
if %FUNCTION_CALL_ERRORS% GTR 0 (
    echo [FUNCTION CALL ERRORS CATEGORIZED:]
    echo =================================
    
    REM Invalid function calls
    findstr /C:"Invalid call" function_call_errors_temp.log > invalid_calls.log 2>nul
    for /f %%i in ('type invalid_calls.log ^| find /c /v ""') do SET INVALID_CALLS=%%i
    if %INVALID_CALLS% GTR 0 (
        echo    - Invalid Function Calls: %INVALID_CALLS%
        echo      Sample invalid calls:
        type invalid_calls.log | head -n 3
        echo.
    )
)

REM Categorize and report data access errors
if %DATA_ACCESS_ERRORS% GTR 0 (
    echo [DATA ACCESS ERRORS CATEGORIZED:]
    echo ================================
    
    REM Invalid property access
    findstr /C:"Invalid access to property" data_access_errors_temp.log > invalid_access.log 2>nul
    for /f %%i in ('type invalid_access.log ^| find /c /v ""') do SET INVALID_ACCESS=%%i
    if %INVALID_ACCESS% GTR 0 (
        echo    - Invalid Property Access: %INVALID_ACCESS%
        echo      Sample invalid access:
        type invalid_access.log | head -n 3
        echo.
    )
)

echo.
echo [PHASE 4] Impact Assessment
echo ==========================
echo.

REM Determine impact level
if %TOTAL_ERRORS% GTR 50 (
    echo [IMPACT] CRITICAL - Game will not run due to core system failures
    SET IMPACT_LEVEL=CRITICAL
    SET IMPACT_DESCRIPTION="Core systems failed to load - game cannot run properly"
) else if %TOTAL_ERRORS% GTR 20 (
    echo [IMPACT] HIGH - Significant functionality issues detected
    SET IMPACT_LEVEL=HIGH
    SET IMPACT_DESCRIPTION="Major components failing - gameplay severely impacted"
) else if %TOTAL_ERRORS% GTR 5 (
    echo [IMPACT] MEDIUM - Moderate functionality issues detected
    SET IMPACT_LEVEL=MEDIUM
    SET IMPACT_DESCRIPTION="Some components failing - gameplay somewhat impacted"
) else if %TOTAL_ERRORS% GTR 0 (
    echo [IMPACT] LOW - Minor functionality issues detected
    SET IMPACT_LEVEL=LOW
    SET IMPACT_DESCRIPTION="Few components failing - gameplay minimally impacted"
) else (
    echo [IMPACT] NONE - No critical errors detected
    SET IMPACT_LEVEL=NONE
    SET IMPACT_DESCRIPTION="All systems functioning normally"
)

echo.
echo [PHASE 5] Detailed Error Logs
echo ============================
echo.

REM Create detailed error logs for each category
if %PARSE_ERRORS% GTR 0 (
    echo [PARSE ERRORS DETAILED:]
    echo =======================
    type parse_errors_temp.log > %ERROR_LOG%
    echo Parse errors logged to: %ERROR_LOG%
    echo.
)

if %SCRIPT_LOAD_ERRORS% GTR 0 (
    echo [SCRIPT LOADING ERRORS DETAILED:]
    echo ================================
    type script_load_errors_temp.log >> %ERROR_LOG%
    echo Script loading errors appended to: %ERROR_LOG%
    echo.
)

if %MISSING_CLASSES% GTR 0 (
    echo [MISSING CLASSES DETAILED:]
    echo =========================
    type missing_classes_temp.log >> %ERROR_LOG%
    echo Missing classes appended to: %ERROR_LOG%
    echo.
)

if %AUTOLOAD_ERRORS% GTR 0 (
    echo [AUTOLOAD ERRORS DETAILED:]
    echo =========================
    type autoload_errors_temp.log >> %ERROR_LOG%
    echo Autoload errors appended to: %ERROR_LOG%
    echo.
)

if %RESOURCE_ERRORS% GTR 0 (
    echo [RESOURCE ERRORS DETAILED:]
    echo =========================
    type resource_errors_temp.log >> %ERROR_LOG%
    echo Resource errors appended to: %ERROR_LOG%
    echo.
)

if %FUNCTION_CALL_ERRORS% GTR 0 (
    echo [FUNCTION CALL ERRORS DETAILED:]
    echo ===============================
    type function_call_errors_temp.log >> %ERROR_LOG%
    echo Function call errors appended to: %ERROR_LOG%
    echo.
)

if %DATA_ACCESS_ERRORS% GTR 0 (
    echo [DATA ACCESS ERRORS DETAILED:]
    echo =============================
    type data_access_errors_temp.log >> %ERROR_LOG%
    echo Data access errors appended to: %ERROR_LOG%
    echo.
)

echo.
echo [PHASE 6] Warning Analysis
echo ========================
echo.

if %MEMORY_LEAKS% GTR 0 (
    echo [MEMORY LEAKS DETECTED:]
    echo =======================
    findstr /C:"ObjectDB instances leaked" %VERBOSE_LOG% > memory_leaks.log
    type memory_leaks.log > %WARNING_LOG%
    echo Memory leaks logged to: %WARNING_LOG%
    echo.
)

if %TEST_FAILURES% GTR 0 (
    echo [TEST FAILURES DETECTED:]
    echo ========================
    findstr /C:"failure" %VERBOSE_LOG% > test_failures.log
    type test_failures.log >> %WARNING_LOG%
    echo Test failures appended to: %WARNING_LOG%
    echo.
)

echo.
echo [PHASE 7] Summary Report Generation
echo =================================
echo.

REM Generate comprehensive summary
echo Project Antares - Debug Monitor Summary Report > %SUMMARY_LOG%
echo ============================================ >> %SUMMARY_LOG%
echo Timestamp: %DATE% %TIME% >> %SUMMARY_LOG%
echo. >> %SUMMARY_LOG%
echo Error Analysis Summary: >> %SUMMARY_LOG%
echo ---------------------- >> %SUMMARY_LOG%
echo Parse Errors: %PARSE_ERRORS% >> %SUMMARY_LOG%
echo Script Load Errors: %SCRIPT_LOAD_ERRORS% >> %SUMMARY_LOG%
echo Missing Classes: %MISSING_CLASSES% >> %SUMMARY_LOG%
echo Autoload Errors: %AUTOLOAD_ERRORS% >> %SUMMARY_LOG%
echo Resource Errors: %RESOURCE_ERRORS% >> %SUMMARY_LOG%
echo Function Call Errors: %FUNCTION_CALL_ERRORS% >> %SUMMARY_LOG%
echo Data Access Errors: %DATA_ACCESS_ERRORS% >> %SUMMARY_LOG%
echo Total Critical Errors: %TOTAL_ERRORS% >> %SUMMARY_LOG%
echo. >> %SUMMARY_LOG%
echo Warning Analysis Summary: >> %SUMMARY_LOG%
echo ------------------------ >> %SUMMARY_LOG%
echo Memory Leaks: %MEMORY_LEAKS% >> %SUMMARY_LOG%
echo Test Failures: %TEST_FAILURES% >> %SUMMARY_LOG%
echo Total Warnings: %TOTAL_WARNINGS% >> %SUMMARY_LOG%
echo. >> %SUMMARY_LOG%
echo Impact Assessment: >> %SUMMARY_LOG%
echo ------------------ >> %SUMMARY_LOG%
echo Impact Level: %IMPACT_LEVEL% >> %SUMMARY_LOG%
echo Impact Description: %IMPACT_DESCRIPTION% >> %SUMMARY_LOG%
echo. >> %SUMMARY_LOG%
echo Pipeline Status: >> %SUMMARY_LOG%
echo --------------- >> %SUMMARY_LOG%
echo Exit Code: %PIPELINE_EXIT_CODE% >> %SUMMARY_LOG%
if %PIPELINE_EXIT_CODE% EQU 0 (
    echo Status: SUCCESS >> %SUMMARY_LOG%
) else (
    echo Status: FAILED >> %SUMMARY_LOG%
)
echo. >> %SUMMARY_LOG%

type %SUMMARY_LOG%

echo.
echo [PHASE 8] Final Status Determination
echo ===================================
echo.

REM Determine final status
if %TOTAL_ERRORS% GTR 0 (
    echo [STATUS] ❌ DEBUG MONITOR: CRITICAL ERRORS DETECTED
    echo [REASON] %IMPACT_DESCRIPTION%
    echo [ACTION] Address critical errors before proceeding
    SET DEBUG_MONITOR_STATUS=FAILED
) else if %TOTAL_WARNINGS% GTR 0 (
    echo [STATUS] ⚠️  DEBUG MONITOR: WARNINGS DETECTED
    echo [ACTION] Review warnings and address issues
    SET DEBUG_MONITOR_STATUS=PARTIAL
) else (
    echo [STATUS] ✅ DEBUG MONITOR: ALL SYSTEMS NOMINAL
    SET DEBUG_MONITOR_STATUS=SUCCESS
)

echo.
echo [PHASE 9] Recommendations
echo ========================
echo.

if %PARSE_ERRORS% GTR 0 (
    echo [RECOMMENDATION] Fix parse errors first - they block script compilation
    echo    - Check indentation in scripts
    - Verify syntax in problematic files
    - Run gdlint for detailed analysis
)

if %MISSING_CLASSES% GTR 0 (
    echo [RECOMMENDATION] Resolve missing class definitions
    echo    - Create missing class files
    - Add proper preload statements
    - Verify class_name declarations
)

if %AUTOLOAD_ERRORS% GTR 0 (
    echo [RECOMMENDATION] Fix autoload instantiation failures
    echo    - Ensure classes inherit from Node
    - Check class constructors
    - Verify resource paths
)

if %RESOURCE_ERRORS% GTR 0 (
    echo [RECOMMENDATION] Address missing resource issues
    echo    - Import missing assets in Godot editor
    - Verify resource paths
    - Add fallback mechanisms
)

if %MEMORY_LEAKS% GTR 0 (
    echo [RECOMMENDATION] Investigate memory leaks
    echo    - Check object cleanup in _exit_tree()
    - Verify proper resource disposal
    - Use weak references where appropriate
)

echo.
echo [PHASE 10] Cleanup and Final Output
echo ===================================
echo.

REM Cleanup temporary files
del parse_errors_temp.log 2>nul
del script_load_errors_temp.log 2>nul
del missing_classes_temp.log 2>nul
del autoload_errors_temp.log 2>nul
del resource_errors_temp.log 2>nul
del function_call_errors_temp.log 2>nul
del data_access_errors_temp.log 2>nul
del memory_leaks_temp.log 2>nul
del test_failures_temp.log 2>nul
del indent_errors.log 2>nul
del syntax_errors.log 2>nul
del missing_deps.log 2>nul
del critical_missing.log 2>nul
del manager_failures.log 2>nul
del missing_assets.log 2>nul
del invalid_calls.log 2>nul
del invalid_access.log 2>nul
del memory_leaks.log 2>nul
del test_failures.log 2>nul

echo [CLEANUP] Temporary files removed
echo [OUTPUT] Detailed logs saved to:
echo    - %LOG_FILE% (general logging)
echo    - %ERROR_LOG% (critical errors)
echo    - %WARNING_LOG% (warnings and issues)
echo    - %VERBOSE_LOG% (full verbose output)
echo    - %SUMMARY_LOG% (summary report)
echo.

REM Final exit with appropriate code
if %TOTAL_ERRORS% GTR 0 (
    exit /b 1
) else (
    exit /b 0
)

endlocal
