@echo off
setlocal enabledelayedexpansion

echo ===============================================================================
echo Project Antares - Enhanced Debugging and Diagnostic System
echo ===============================================================================
echo Timestamp: %DATE% %TIME%
echo.

REM Configuration
SET GODOT_EXECUTABLE="C:\Tools\godot.exe"
SET DEBUG_LOG="debug_diagnostics.log"
SET ERROR_LOG="error_analysis.log"
SET WARNING_LOG="warning_analysis.log"
SET VERBOSE_LOG="verbose_debug.log"
SET SUMMARY_LOG="debug_summary.log"

echo [INFO] Starting enhanced debugging diagnostics...
echo [INFO] Debug logs will be saved to: %DEBUG_LOG%
echo [INFO] Error analysis will be saved to: %ERROR_LOG%
echo [INFO] Warning analysis will be saved to: %WARNING_LOG%
echo [INFO] Verbose debug output will be saved to: %VERBOSE_LOG%
echo [INFO] Summary report will be saved to: %SUMMARY_LOG%
echo.

REM Initialize counters
SET TOTAL_ERRORS=0
SET TOTAL_WARNINGS=0
SET CRITICAL_ERRORS=0
SET PARSE_ERRORS=0
SET SCRIPT_LOAD_FAILURES=0
SET MISSING_CLASSES=0
SET AUTOLOAD_FAILURES=0
SET RESOURCE_ERRORS=0
SET FUNCTION_CALL_ERRORS=0
SET DATA_ACCESS_ERRORS=0
SET MEMORY_LEAKS=0
SET TEST_FAILURES=0

echo [PHASE 1] Comprehensive System Diagnostics
echo ========================================
echo.

REM Run Godot with maximum verbosity for detailed diagnostics
echo [DIAGNOSTICS] Running Godot with enhanced debugging...
%GODOT_EXECUTABLE% --headless --verbose --debug -s res://addons/gut/gut_cmdln.gd -gdir=res://tests -gexit=true -gjunit_xml_file=%TEST_RESULTS_FILE% > %VERBOSE_LOG% 2>&1

SET GODOT_EXIT_CODE=%ERRORLEVEL%
echo [RESULT] Godot exited with code: %GODOT_EXIT_CODE%

echo.
echo [PHASE 2] Detailed Error Pattern Analysis
echo =======================================
echo.

REM Extract and categorize different error types
echo [ANALYSIS] Parsing error patterns from verbose output...

REM Parse Errors
findstr /C:"Parse Error" %VERBOSE_LOG% > parse_errors.log 2>nul
for /f %%i in ('type parse_errors.log ^| find /c /v ""') do SET PARSE_ERRORS=%%i

REM Script Loading Failures
findstr /C:"Failed to load script" %VERBOSE_LOG% > script_load_failures.log 2>nul
for /f %%i in ('type script_load_failures.log ^| find /c /v ""') do SET SCRIPT_LOAD_FAILURES=%%i

REM Missing Class Definitions
findstr /C:"Could not find type" %VERBOSE_LOG% > missing_classes.log 2>nul
for /f %%i in ('type missing_classes.log ^| find /c /v ""') do SET MISSING_CLASSES=%%i

REM Autoload Failures
findstr /C:"Failed to instantiate an autoload" %VERBOSE_LOG% > autoload_failures.log 2>nul
for /f %%i in ('type autoload_failures.log ^| find /c /v ""') do SET AUTOLOAD_FAILURES=%%i

REM Resource Loading Errors
findstr /C:"Failed loading resource" %VERBOSE_LOG% > resource_errors.log 2>nul
for /f %%i in ('type resource_errors.log ^| find /c /v ""') do SET RESOURCE_ERRORS=%%i

REM Function Call Errors
findstr /C:"Could not resolve external class member" %VERBOSE_LOG% > function_call_errors.log 2>nul
for /f %%i in ('type function_call_errors.log ^| find /c /v ""') do SET FUNCTION_CALL_ERRORS=%%i

REM Data Access Errors
findstr /C:"Invalid access to property or key" %VERBOSE_LOG% > data_access_errors.log 2>nul
for /f %%i in ('type data_access_errors.log ^| find /c /v ""') do SET DATA_ACCESS_ERRORS=%%i

REM Memory Leaks
findstr /C:"ObjectDB instances leaked" %VERBOSE_LOG% > memory_leaks.log 2>nul
for /f %%i in ('type memory_leaks.log ^| find /c /v ""') do SET MEMORY_LEAKS=%%i

REM Test Failures
findstr /C:"failure" %VERBOSE_LOG% > test_failures.log 2>nul
for /f %%i in ('type test_failures.log ^| find /c /v ""') do SET TEST_FAILURES=%%i

REM Calculate totals
SET /A TOTAL_ERRORS=%PARSE_ERRORS%+%SCRIPT_LOAD_FAILURES%+%MISSING_CLASSES%+%AUTOLOAD_FAILURES%+%RESOURCE_ERRORS%+%FUNCTION_CALL_ERRORS%+%DATA_ACCESS_ERRORS%
SET /A TOTAL_WARNINGS=%MEMORY_LEAKS%+%TEST_FAILURES%

echo [RESULTS] Error Pattern Analysis:
echo    - Parse Errors: %PARSE_ERRORS%
echo    - Script Load Failures: %SCRIPT_LOAD_FAILURES%
echo    - Missing Classes: %MISSING_CLASSES%
echo    - Autoload Failures: %AUTOLOAD_FAILURES%
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

REM Create detailed categorized reports
if %PARSE_ERRORS% GTR 0 (
    echo [PARSE ERRORS CATEGORIZED:] >> %ERROR_LOG%
    echo ========================== >> %ERROR_LOG%
    
    REM Indentation errors
    findstr /C:"Expected statement, found 'Indent' instead" parse_errors.log > indent_errors.log 2>nul
    for /f %%i in ('type indent_errors.log ^| find /c /v ""') do SET INDENT_ERRORS=%%i
    if %INDENT_ERRORS% GTR 0 (
        echo    - Indentation Errors: %INDENT_ERRORS% >> %ERROR_LOG%
        echo      Sample indent errors: >> %ERROR_LOG%
        type indent_errors.log | head -n 3 >> %ERROR_LOG%
        echo. >> %ERROR_LOG%
    )
    
    REM Syntax errors
    findstr /C:"Parse Error" parse_errors.log | findstr /V "Expected statement, found 'Indent' instead" > syntax_errors.log 2>nul
    for /f %%i in ('type syntax_errors.log ^| find /c /v ""') do SET SYNTAX_ERRORS=%%i
    if %SYNTAX_ERRORS% GTR 0 (
        echo    - Syntax Errors: %SYNTAX_ERRORS% >> %ERROR_LOG%
        echo      Sample syntax errors: >> %ERROR_LOG%
        type syntax_errors.log | head -n 3 >> %ERROR_LOG%
        echo. >> %ERROR_LOG%
    )
)

if %SCRIPT_LOAD_FAILURES% GTR 0 (
    echo [SCRIPT LOADING ERRORS CATEGORIZED:] >> %ERROR_LOG%
    echo ================================== >> %ERROR_LOG%
    
    REM Missing dependencies
    findstr /C:"Failed to load script" script_load_failures.log > missing_deps.log 2>nul
    for /f %%i in ('type missing_deps.log ^| find /c /v ""') do SET MISSING_DEPS=%%i
    if %MISSING_DEPS% GTR 0 (
        echo    - Missing Dependencies: %MISSING_DEPS% >> %ERROR_LOG%
        echo      Sample dependency errors: >> %ERROR_LOG%
        type missing_deps.log | head -n 3 >> %ERROR_LOG%
        echo. >> %ERROR_LOG%
    )
)

if %MISSING_CLASSES% GTR 0 (
    echo [MISSING CLASS ERRORS CATEGORIZED:] >> %ERROR_LOG%
    echo ================================= >> %ERROR_LOG%
    
    REM Critical missing classes
    findstr /C:"Could not find type" missing_classes.log > critical_missing.log 2>nul
    for /f %%i in ('type critical_missing.log ^| find /c /v ""') do SET CRITICAL_MISSING=%%i
    if %CRITICAL_MISSING% GTR 0 (
        echo    - Critical Missing Classes: %CRITICAL_MISSING% >> %ERROR_LOG%
        echo      Sample missing class errors: >> %ERROR_LOG%
        type critical_missing.log | head -n 5 >> %ERROR_LOG%
        echo. >> %ERROR_LOG%
    )
)

if %AUTOLOAD_FAILURES% GTR 0 (
    echo [AUTOLOAD ERRORS CATEGORIZED:] >> %ERROR_LOG%
    echo ============================= >> %ERROR_LOG%
    
    REM Manager instantiation failures
    findstr /C:"Failed to instantiate an autoload" autoload_failures.log > manager_failures.log 2>nul
    for /f %%i in ('type manager_failures.log ^| find /c /v ""') do SET MANAGER_FAILURES=%%i
    if %MANAGER_FAILURES% GTR 0 (
        echo    - Manager Instantiation Failures: %MANAGER_FAILURES% >> %ERROR_LOG%
        echo      Sample manager failures: >> %ERROR_LOG%
        type manager_failures.log | head -n 3 >> %ERROR_LOG%
        echo. >> %ERROR_LOG%
    )
)

if %RESOURCE_ERRORS% GTR 0 (
    echo [RESOURCE LOADING ERRORS CATEGORIZED:] >> %ERROR_LOG%
    echo ==================================== >> %ERROR_LOG%
    
    REM Missing assets
    findstr /C:"Failed loading resource" resource_errors.log > missing_assets.log 2>nul
    for /f %%i in ('type missing_assets.log ^| find /c /v ""') do SET MISSING_ASSETS=%%i
    if %MISSING_ASSETS% GTR 0 (
        echo    - Missing Assets: %MISSING_ASSETS% >> %ERROR_LOG%
        echo      Sample missing assets: >> %ERROR_LOG%
        type missing_assets.log | head -n 3 >> %ERROR_LOG%
        echo. >> %ERROR_LOG%
    )
)

if %FUNCTION_CALL_ERRORS% GTR 0 (
    echo [FUNCTION CALL ERRORS CATEGORIZED:] >> %ERROR_LOG%
    echo ================================= >> %ERROR_LOG%
    
    REM Invalid function calls
    findstr /C:"Could not resolve external class member" function_call_errors.log > invalid_calls.log 2>nul
    for /f %%i in ('type invalid_calls.log ^| find /c /v ""') do SET INVALID_CALLS=%%i
    if %INVALID_CALLS% GTR 0 (
        echo    - Invalid Function Calls: %INVALID_CALLS% >> %ERROR_LOG%
        echo      Sample invalid calls: >> %ERROR_LOG%
        type invalid_calls.log | head -n 3 >> %ERROR_LOG%
        echo. >> %ERROR_LOG%
    )
)

if %DATA_ACCESS_ERRORS% GTR 0 (
    echo [DATA ACCESS ERRORS CATEGORIZED:] >> %ERROR_LOG%
    echo ================================ >> %ERROR_LOG%
    
    REM Invalid property access
    findstr /C:"Invalid access to property or key" data_access_errors.log > invalid_access.log 2>nul
    for /f %%i in ('type invalid_access.log ^| find /c /v ""') do SET INVALID_ACCESS=%%i
    if %INVALID_ACCESS% GTR 0 (
        echo    - Invalid Property Access: %INVALID_ACCESS% >> %ERROR_LOG%
        echo      Sample invalid access: >> %ERROR_LOG%
        type invalid_access.log | head -n 3 >> %ERROR_LOG%
        echo. >> %ERROR_LOG%
    )
)

echo.
echo [PHASE 4] Impact Assessment
echo ==========================
echo.

REM Determine impact level
if %TOTAL_ERRORS% GTR 50 (
    echo [IMPACT] CRITICAL - Game will not run due to core system failures >> %WARNING_LOG%
    SET IMPACT_LEVEL=CRITICAL
    SET IMPACT_DESCRIPTION="Core systems failed to load - game cannot run properly"
) else if %TOTAL_ERRORS% GTR 20 (
    echo [IMPACT] HIGH - Significant functionality issues detected >> %WARNING_LOG%
    SET IMPACT_LEVEL=HIGH
    SET IMPACT_DESCRIPTION="Major components failing - gameplay severely impacted"
) else if %TOTAL_ERRORS% GTR 5 (
    echo [IMPACT] MEDIUM - Moderate functionality issues detected >> %WARNING_LOG%
    SET IMPACT_LEVEL=MEDIUM
    SET IMPACT_DESCRIPTION="Some components failing - gameplay somewhat impacted"
) else if %TOTAL_ERRORS% GTR 0 (
    echo [IMPACT] LOW - Minor functionality issues detected >> %WARNING_LOG%
    SET IMPACT_LEVEL=LOW
    SET IMPACT_DESCRIPTION="Few components failing - gameplay minimally impacted"
) else (
    echo [IMPACT] NONE - No critical errors detected >> %WARNING_LOG%
    SET IMPACT_LEVEL=NONE
    SET IMPACT_DESCRIPTION="All systems functioning normally"
)

echo.
echo [PHASE 5] Detailed Logging and Reporting
echo =======================================
echo.

REM Create comprehensive debug logs
echo Project Antares - Enhanced Debug Diagnostics > %DEBUG_LOG%
echo ======================================== >> %DEBUG_LOG%
echo Timestamp: %DATE% %TIME% >> %DEBUG_LOG%
echo Godot Exit Code: %GODOT_EXIT_CODE% >> %DEBUG_LOG%
echo. >> %DEBUG_LOG%

echo Error Analysis Summary: >> %DEBUG_LOG%
echo ---------------------- >> %DEBUG_LOG%
echo Parse Errors: %PARSE_ERRORS% >> %DEBUG_LOG%
echo Script Load Failures: %SCRIPT_LOAD_FAILURES% >> %DEBUG_LOG%
echo Missing Classes: %MISSING_CLASSES% >> %DEBUG_LOG%
echo Autoload Failures: %AUTOLOAD_FAILURES% >> %DEBUG_LOG%
echo Resource Errors: %RESOURCE_ERRORS% >> %DEBUG_LOG%
echo Function Call Errors: %FUNCTION_CALL_ERRORS% >> %DEBUG_LOG%
echo Data Access Errors: %DATA_ACCESS_ERRORS% >> %DEBUG_LOG%
echo Total Critical Errors: %TOTAL_ERRORS% >> %DEBUG_LOG%
echo Memory Leaks: %MEMORY_LEAKS% >> %DEBUG_LOG%
echo Test Failures: %TEST_FAILURES% >> %DEBUG_LOG%
echo Total Warnings: %TOTAL_WARNINGS% >> %DEBUG_LOG%
echo. >> %DEBUG_LOG%

echo Impact Assessment: >> %DEBUG_LOG%
echo ------------------ >> %DEBUG_LOG%
echo Impact Level: %IMPACT_LEVEL% >> %DEBUG_LOG%
echo Impact Description: %IMPACT_DESCRIPTION% >> %DEBUG_LOG%
echo. >> %DEBUG_LOG%

REM Append detailed error logs
if %PARSE_ERRORS% GTR 0 (
    echo. >> %DEBUG_LOG%
    echo Parse Errors Details: >> %DEBUG_LOG%
    echo ==================== >> %DEBUG_LOG%
    type parse_errors.log >> %DEBUG_LOG%
)

if %SCRIPT_LOAD_FAILURES% GTR 0 (
    echo. >> %DEBUG_LOG%
    echo Script Loading Failures Details: >> %DEBUG_LOG%
    echo ============================== >> %DEBUG_LOG%
    type script_load_failures.log >> %DEBUG_LOG%
)

if %MISSING_CLASSES% GTR 0 (
    echo. >> %DEBUG_LOG%
    echo Missing Classes Details: >> %DEBUG_LOG%
    echo ====================== >> %DEBUG_LOG%
    type missing_classes.log >> %DEBUG_LOG%
)

if %AUTOLOAD_FAILURES% GTR 0 (
    echo. >> %DEBUG_LOG%
    echo Autoload Failures Details: >> %DEBUG_LOG%
    echo ======================== >> %DEBUG_LOG%
    type autoload_failures.log >> %DEBUG_LOG%
)

if %RESOURCE_ERRORS% GTR 0 (
    echo. >> %DEBUG_LOG%
    echo Resource Errors Details: >> %DEBUG_LOG%
    echo ====================== >> %DEBUG_LOG%
    type resource_errors.log >> %DEBUG_LOG%
)

if %FUNCTION_CALL_ERRORS% GTR 0 (
    echo. >> %DEBUG_LOG%
    echo Function Call Errors Details: >> %DEBUG_LOG%
    echo =========================== >> %DEBUG_LOG%
    type function_call_errors.log >> %DEBUG_LOG%
)

if %DATA_ACCESS_ERRORS% GTR 0 (
    echo. >> %DEBUG_LOG%
    echo Data Access Errors Details: >> %DEBUG_LOG%
    echo ========================= >> %DEBUG_LOG%
    type data_access_errors.log >> %DEBUG_LOG%
)

if %MEMORY_LEAKS% GTR 0 (
    echo. >> %DEBUG_LOG%
    echo Memory Leaks Details: >> %DEBUG_LOG%
    echo ==================== >> %DEBUG_LOG%
    type memory_leaks.log >> %DEBUG_LOG%
)

if %TEST_FAILURES% GTR 0 (
    echo. >> %DEBUG_LOG%
    echo Test Failures Details: >> %DEBUG_LOG%
    echo ===================== >> %DEBUG_LOG%
    type test_failures.log >> %DEBUG_LOG%
)

echo.
echo [PHASE 6] Summary Report Generation
echo =================================
echo.

REM Generate summary report
echo Project Antares - Debug Summary Report > %SUMMARY_LOG%
echo ==================================== >> %SUMMARY_LOG%
echo Timestamp: %DATE% %TIME% >> %SUMMARY_LOG%
echo. >> %SUMMARY_LOG%

echo Overall Status: >> %SUMMARY_LOG%
echo -------------- >> %SUMMARY_LOG%
if %TOTAL_ERRORS% GTR 0 (
    echo ❌ DEBUG FAILED - Critical errors detected >> %SUMMARY_LOG%
) else if %TOTAL_WARNINGS% GTR 0 (
    echo ⚠️  DEBUG PARTIAL SUCCESS - Warnings detected >> %SUMMARY_LOG%
) else (
    echo ✅ DEBUG SUCCESS - All systems nominal >> %SUMMARY_LOG%
)
echo. >> %SUMMARY_LOG%

echo Critical Error Summary: >> %SUMMARY_LOG%
echo -------------------- >> %SUMMARY_LOG%
echo Parse Errors: %PARSE_ERRORS% >> %SUMMARY_LOG%
echo Script Load Failures: %SCRIPT_LOAD_FAILURES% >> %SUMMARY_LOG%
echo Missing Classes: %MISSING_CLASSES% >> %SUMMARY_LOG%
echo Autoload Failures: %AUTOLOAD_FAILURES% >> %SUMMARY_LOG%
echo Resource Errors: %RESOURCE_ERRORS% >> %SUMMARY_LOG%
echo Function Call Errors: %FUNCTION_CALL_ERRORS% >> %SUMMARY_LOG%
echo Data Access Errors: %DATA_ACCESS_ERRORS% >> %SUMMARY_LOG%
echo Total Critical Errors: %TOTAL_ERRORS% >> %SUMMARY_LOG%
echo. >> %SUMMARY_LOG%

echo Warning Summary: >> %SUMMARY_LOG%
echo -------------- >> %SUMMARY_LOG%
echo Memory Leaks: %MEMORY_LEAKS% >> %SUMMARY_LOG%
echo Test Failures: %TEST_FAILURES% >> %SUMMARY_LOG%
echo Total Warnings: %TOTAL_WARNINGS% >> %SUMMARY_LOG%
echo. >> %SUMMARY_LOG%

echo Impact Assessment: >> %SUMMARY_LOG%
echo ------------------ >> %SUMMARY_LOG%
echo Impact Level: %IMPACT_LEVEL% >> %SUMMARY_LOG%
echo Impact Description: %IMPACT_DESCRIPTION% >> %SUMMARY_LOG%
echo. >> %SUMMARY_LOG%

echo Exit Code: %GODOT_EXIT_CODE% >> %SUMMARY_LOG%
echo. >> %SUMMARY_LOG%

REM Display summary to console
type %SUMMARY_LOG%

echo.
echo [PHASE 7] Recommendations and Next Steps
echo =======================================
echo.

if %TOTAL_ERRORS% GTR 0 (
    echo [RECOMMENDATIONS] Critical Issues Need Attention:
    echo ==============================================
    
    if %PARSE_ERRORS% GTR 0 (
        echo 1. Fix Parse Errors First:
        echo    - Check indentation in scripts
        echo    - Verify syntax in problematic files
        echo    - Run gdlint for detailed analysis
        echo.
    )
    
    if %MISSING_CLASSES% GTR 0 (
        echo 2. Resolve Missing Class Definitions:
        echo    - Create missing class files
        echo    - Add proper preload statements
        echo    - Verify class_name declarations
        echo.
    )
    
    if %AUTOLOAD_FAILURES% GTR 0 (
        echo 3. Fix Autoload Instantiation Failures:
        echo    - Ensure classes inherit from Node
        echo    - Check class constructors
        echo    - Verify resource paths
        echo.
    )
    
    if %SCRIPT_LOAD_FAILURES% GTR 0 (
        echo 4. Address Script Loading Failures:
        echo    - Check for missing dependencies
        echo    - Verify file paths
        echo    - Ensure proper class imports
        echo.
    )
    
    if %RESOURCE_ERRORS% GTR 0 (
        echo 5. Fix Resource Loading Issues:
        echo    - Import missing assets in Godot editor
        echo    - Verify resource paths
        echo    - Add fallback mechanisms
        echo.
    )
    
    if %FUNCTION_CALL_ERRORS% GTR 0 (
        echo 6. Resolve Function Call Errors:
        echo    - Check function signatures
        echo    - Verify class methods exist
        echo    - Ensure proper method calls
        echo.
    )
    
    if %DATA_ACCESS_ERRORS% GTR 0 (
        echo 7. Fix Data Access Errors:
        echo    - Add null checks for data access
        echo    - Verify property existence
        echo    - Implement proper error handling
        echo.
    )
    
    echo [NEXT STEPS]:
    echo ===========
    echo 1. Prioritize critical errors above
    echo 2. Run enhanced_debugging.bat after each fix
    echo 3. Verify error counts decrease
    echo 4. Continue until TOTAL_ERRORS = 0
    echo.
    
    SET DEBUG_STATUS=FAILED
) else if %TOTAL_WARNINGS% GTR 0 (
    echo [RECOMMENDATIONS] Warnings to Address:
    echo ====================================
    
    if %MEMORY_LEAKS% GTR 0 (
        echo 1. Investigate Memory Leaks:
        echo    - Check object cleanup in _exit_tree()
        echo    - Verify proper resource disposal
        echo    - Use weak references where appropriate
        echo.
    )
    
    if %TEST_FAILURES% GTR 0 (
        echo 2. Review Test Failures:
        echo    - Check failed test cases
        echo    - Address test implementation issues
        echo    - Verify test data validity
        echo.
    )
    
    echo [NEXT STEPS]:
    echo ===========
    echo 1. Address warnings above
    echo 2. Run enhanced_debugging.bat to verify fixes
    echo 3. Continue improving until warnings are minimized
    echo.
    
    SET DEBUG_STATUS=PARTIAL
) else (
    echo [RECOMMENDATIONS] All Systems Nominal:
    echo ====================================
    echo No critical errors or warnings detected.
    echo System is ready for production use.
    echo.
    
    echo [NEXT STEPS]:
    echo ===========
    echo 1. Continue regular development
    echo 2. Run enhanced_debugging.bat periodically
    echo 3. Monitor for new issues
    echo.
    
    SET DEBUG_STATUS=SUCCESS
)

echo.
echo [PHASE 8] Cleanup and Final Output
echo =================================
echo.

REM Cleanup temporary files
del parse_errors.log 2>nul
del script_load_failures.log 2>nul
del missing_classes.log 2>nul
del autoload_failures.log 2>nul
del resource_errors.log 2>nul
del function_call_errors.log 2>nul
del data_access_errors.log 2>nul
del memory_leaks.log 2>nul
del test_failures.log 2>nul
del indent_errors.log 2>nul
del syntax_errors.log 2>nul
del missing_deps.log 2>nul
del critical_missing.log 2>nul
del manager_failures.log 2>nul
del missing_assets.log 2>nul
del invalid_calls.log 2>nul
del invalid_access.log 2>nul

echo [CLEANUP] Temporary files removed
echo [OUTPUT] Detailed logs saved to:
echo    - %DEBUG_LOG% (comprehensive diagnostics)
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
