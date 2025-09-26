# Project Antares - GDUnit4 Integration Guide

## Overview
This guide provides comprehensive instructions for integrating GDUnit4 into Project Antares to enhance testing capabilities, improve debugging information, and resolve the false positive reporting issues in the CI/CD pipeline.

## Why GDUnit4?

### Advantages Over GUT
1. **Enhanced Error Reporting**: Better error messages and stack traces
2. **Advanced Testing Features**: Fuzz testing, parameterized testing, and flaky test handling
3. **Improved Debugging**: Detailed diagnostic information and better assertion failures
4. **Scene Testing**: Built-in support for UI and scene testing
5. **Performance Testing**: Benchmark decorators and timing analysis
6. **Better CI/CD Integration**: Proper exit codes and failure reporting

## Installation and Setup

### 1. Installing GDUnit4

#### Method 1: Git Submodule (Recommended)
```bash
# Navigate to project root
cd c:/github/project-antares

# Add GDUnit4 as a submodule
git submodule add https://github.com/MikeSchulze/gdUnit4 addons/gdUnit4

# Initialize and update submodule
git submodule init
git submodule update
```

#### Method 2: Manual Download
1. Download the latest GDUnit4 release from [GitHub](https://github.com/MikeSchulze/gdUnit4/releases)
2. Extract to `addons/gdUnit4/` directory
3. Ensure the directory structure is correct

#### Method 3: Asset Library (via Godot Editor)
1. Open Project Antares in Godot Editor
2. Go to **AssetLib** tab
3. Search for "GDUnit4"
4. Install the addon
5. Enable in **Project Settings > Plugins**

### 2. Configuration

#### Project Settings
Add to `project.godot`:
```ini
[autoload]
# Keep existing autoloads
# Add GDUnit4 if needed for runtime features

[plugins]
enabled_plugins=["res://addons/gdUnit4/plugin.cfg"]
```

#### GDUnit4 Configuration File
Create `gdunit4_config.json`:
```json
{
    "version": "1.0",
    "report": {
        "format": "junit",
        "output_path": "res://test_results/",
        "generate_html": true,
        "generate_xml": true
    },
    "execution": {
        "parallel": true,
        "timeout": 30,
        "retry_flaky_tests": 3,
        "stop_on_failure": false
    },
    "coverage": {
        "enabled": true,
        "output_path": "res://coverage/",
        "threshold": 80
    },
    "logging": {
        "level": "INFO",
        "file": "res://logs/gdunit4.log",
        "console": true
    }
}
```

## Migration Strategy

### Phase 1: Parallel Installation
Keep GUT for existing tests while adding GDUnit4 for new features:

#### Directory Structure
```
addons/
├── gut/              # Existing GUT framework
└── gdUnit4/          # New GDUnit4 framework

tests/
├── gut_tests/        # Existing GUT tests (temporary)
├── gdunit4_tests/    # New GDUnit4 tests
└── integration/      # Cross-framework integration tests
```

### Phase 2: Test Migration
Gradually migrate existing tests to GDUnit4:

#### Migration Priority
1. **High Priority**: Tests with critical errors and false positives
2. **Medium Priority**: Core functionality tests
3. **Low Priority**: Peripheral feature tests

#### Migration Example
```gdscript
# BEFORE: GUT test
# tests/gut_tests/test_empire_manager.gd
extends "res://addons/gut/test.gd"

func test_empire_creation():
    var empire = Empire.new()
    empire.id = "test_empire"
    assert_not_null(empire)
    assert_eq(empire.id, "test_empire")

# AFTER: GDUnit4 test
# tests/gdunit4_tests/test_empire_manager.gd
extends "res://addons/gdUnit4/GdUnitTestSuite.gd"

func test_empire_creation():
    # Arrange
    var empire = Empire.new()
    empire.id = "test_empire"
    
    # Assert
    assert_that(empire).is_not_null()
    assert_that(empire.id).is_equal("test_empire")
```

## Enhanced Testing Features

### 1. Scene Testing

#### UI Scene Validation
```gdscript
# tests/gdunit4_tests/test_ui_scenes.gd
extends "res://addons/gdUnit4/GdUnitTestSuite.gd"

func test_main_menu_scene_loads():
    # Load and validate main menu scene
    var scene = load("res://ui/main_menu.tscn").instantiate()
    assert_that(scene).is_not_null()
    assert_that(scene.name).is_equal("MainMenu")
    
    # Validate UI components exist
    var start_button = scene.get_node("%StartButton")
    assert_that(start_button).is_not_null()
    assert_that(start_button.text).is_equal("Start Game")

func test_settings_scene_interactions():
    # Test UI interactions and state changes
    var scene = load("res://ui/settings_screen.tscn").instantiate()
    add_child_autofree(scene)
    
    var volume_slider = scene.get_node("%VolumeSlider")
    volume_slider.value = 0.5
    assert_that(volume_slider.value).is_equal(0.5)
```

### 2. Fuzz Testing

#### Randomized Input Testing
```gdscript
# tests/gdunit4_tests/test_fuzz_colony.gd
extends "res://addons/gdUnit4/GdUnitTestSuite.gd"

@TestCase
@RandomParameters([
    @Parameter(name="population", type=int, min=0, max=10000),
    @Parameter(name="food_production", type=int, min=0, max=1000)
])
func test_colony_population_growth_fuzz(population: int, food_production: int):
    var colony = ColonyData.new()
    colony.current_population = max(0, population)
    colony.food_produced = max(0, food_production)
    
    var result = colony.calculate_growth()
    assert_that(result).is_greater_or_equal(0)
    # Validate that negative inputs don't cause errors

@TestCase
@RandomParameters([
    @Parameter(name="input_value", type=float, min=-1000.0, max=1000.0),
    @Parameter(name="multiplier", type=float, min=0.1, max=10.0)
])
func test_technology_effect_calculation_fuzz(input_value: float, multiplier: float):
    var effect_manager = TechnologyEffectManager.new()
    var result = effect_manager.apply_multiplier_effect(input_value, multiplier)
    assert_that(result).is_not_nan()
    # Ensure no NaN results from extreme values
```

### 3. Parameterized Testing

#### Data-Driven Tests
```gdscript
# tests/gdunit4_tests/test_parameterized_technology.gd
extends "res://addons/gdUnit4/GdUnitTestSuite.gd"

@TestCase
@Parameters([
    [10, 5, 50],    # population, growth_rate, expected_result
    [20, 3, 60],
    [5, 10, 50],
    [0, 5, 0],      # Edge case: zero population
    [-5, 5, 0]      # Edge case: negative population
])
func test_population_growth_calculation(population: int, growth_rate: int, expected: int):
    var colony = ColonyData.new()
    colony.current_population = max(0, population)
    colony.growth_rate = growth_rate
    
    var result = colony.calculate_growth()
    assert_that(result).is_equal(expected)
```

### 4. Flaky Test Handling

#### Retry Mechanisms
```gdscript
# tests/gdunit4_tests/test_flaky_network.gd
extends "res://addons/gdUnit4/GdUnitTestSuite.gd"

@Flaky(retries=3, delay=100)
func test_network_dependent_operation():
    var result = NetworkManager.make_request("http://api.example.com/data")
    # This test might fail due to network issues, so retry up to 3 times
    assert_that(result.success).is_true()

@Test(stability_threshold=0.95)
func test_ai_decision_making():
    var ai_manager = AIManager.new()
    var decision = ai_manager.make_decision(test_scenario)
    
    # Track stability over multiple runs
    assert_that(decision).is_not_null()
    # GDUnit4 will monitor pass/fail rate and flag if below 95% threshold
```

### 5. Performance Testing

#### Benchmark Decorators
```gdscript
# tests/gdunit4_tests/test_performance_benchmark.gd
extends "res://addons/gdUnit4/GdUnitTestSuite.gd"

@Benchmark(iterations=1000)
func test_colony_update_performance():
    var colony = ColonyData.new()
    colony.initialize_large_colony(1000)  # 1000 population colony
    
    # Measure performance of colony update operation
    colony.update_turn()
    
    # GDUnit4 will track execution time and compare against baseline

@Stress(duration=30, threads=4)
func test_galaxy_generation_stress():
    var generator = GalaxyGenerator.new()
    var galaxy = generator.generate_galaxy(1000)  # Generate 1000 star systems
    
    assert_that(galaxy.star_systems.size()).is_equal(1000)
    # Monitor memory usage and performance during stress test
```

## Enhanced Debugging Capabilities

### 1. Detailed Error Reporting

#### Enhanced Assertion Messages
```gdscript
# BEFORE: Basic GUT assertion
assert_eq(result, expected, "Values should match")

# AFTER: GDUnit4 enhanced assertion with context
assert_that(result)
    .with_message("Colony population calculation should account for food availability")
    .is_equal(expected)
```

### 2. Stack Trace Preservation

#### Better Error Context
```gdscript
# tests/gdunit4_tests/test_debug_enhanced.gd
extends "res://addons/gdUnit4/GdUnitTestSuite.gd"

func test_with_detailed_context():
    """
    Test ID: DEBUG-001
    Description: Demonstrate enhanced debugging with GDUnit4
    Scope: Error context and stack trace preservation
    Preconditions: 
        - Empire exists with valid configuration
        - Colony data is properly initialized
    Postconditions:
        - Detailed error information is available
        - Stack traces are preserved for debugging
    Expected Results:
        - Enhanced error messages with context
        - Full stack trace for failed assertions
    """
    
    # Arrange with detailed setup
    var empire = _create_test_empire_with_detailed_config()
    var colony = _create_test_colony_with_population(100)
    
    # Act with error handling
    var result = _perform_complex_calculation(empire, colony)
    
    # Assert with detailed context
    assert_that(result.population_growth)
        .with_message("Population growth calculation failed for empire '%s' in colony '%s'" % [empire.id, colony.id])
        .is_greater_than(0)
        .with_details({
            "empire_population": empire.current_population,
            "colony_food": colony.food_produced,
            "growth_rate": colony.growth_rate,
            "expected_minimum": 1
        })
```

### 3. Memory Leak Detection

#### Object Tracking
```gdscript
# tests/gdunit4_tests/test_memory_leak_detection.gd
extends "res://addons/gdUnit4/GdUnitTestSuite.gd"

func test_object_cleanup():
    # Track object creation
    var initial_object_count = get_object_count()
    
    # Create objects that should be cleaned up
    var test_objects = []
    for i in range(100):
        var obj = TestObject.new()
        test_objects.append(obj)
    
    # Clean up objects
    test_objects.clear()
    
    # Check for memory leaks
    yield(get_tree().create_timer(0.1), "timeout")
    var final_object_count = get_object_count()
    
    # Allow some variance for Godot's internal cleanup
    assert_that(abs(final_object_count - initial_object_count))
        .with_message("Memory leak detected: Objects not properly cleaned up")
        .is_less_than(10)
```

## CI/CD Pipeline Integration

### Enhanced Pipeline Script

#### run_ci_gdunit4.bat
```batch
@echo off
setlocal enabledelayedexpansion

echo ===============================================================================
echo Project Antares - GDUnit4 CI/CD Pipeline
echo ===============================================================================
echo Timestamp: %DATE% %TIME%
echo.

REM Configuration
SET GODOT_EXECUTABLE="C:\Tools\godot.exe"
SET GDUNIT4_TEST_DIR="res://tests/gdunit4_tests/"
SET TEST_RESULTS_DIR="test_results/"
SET COVERAGE_DIR="coverage/"
SET LOG_FILE="ci_pipeline_gdunit4.log"

echo [INFO] Starting GDUnit4 CI/CD pipeline...
echo [INFO] Test directory: %GDUNIT4_TEST_DIR%
echo [INFO] Results directory: %TEST_RESULTS_DIR%
echo [INFO] Log file: %LOG_FILE%
echo.

REM Initialize counters
SET ERROR_COUNT=0
SET WARNING_COUNT=0
SET TEST_FAILURE_COUNT=0
SET FLAKY_TEST_COUNT=0

echo [PHASE 1] Pre-flight Validation
echo ==================================
echo.

REM Check Godot executable
if not exist C:\Tools\godot.exe (
    echo [ERROR] Godot executable not found at C:\Tools\godot.exe
    SET /A ERROR_COUNT+=1
    goto :error_summary
)

echo [OK] Godot executable found

REM Check GDUnit4 installation
if not exist "addons\gdUnit4" (
    echo [ERROR] GDUnit4 not found at addons/gdUnit4
    echo [SOLUTION] Install GDUnit4: git submodule add https://github.com/MikeSchulze/gdUnit4 addons/gdUnit4
    SET /A ERROR_COUNT+=1
    goto :error_summary
)

echo [OK] GDUnit4 framework found

REM Check test directory
if not exist "tests\gdunit4_tests" (
    echo [WARNING] GDUnit4 test directory not found - creating...
    mkdir tests\gdunit4_tests 2>nul
    if !errorlevel! neq 0 (
        echo [ERROR] Failed to create test directory
        SET /A ERROR_COUNT+=1
        goto :error_summary
    )
)

echo [OK] Test directory ready

echo.
echo [PHASE 2] Test Execution
echo ========================
echo.

REM Run GDUnit4 tests with detailed output
echo [EXEC] Running GDUnit4 tests...
%GODOT_EXECUTABLE% --headless -s res://addons/gdUnit4/gdunit_cli.gd ^
    --path %GDUNIT4_TEST_DIR% ^
    --junit-report %TEST_RESULTS_DIR%gdunit4_results.xml ^
    --html-report %TEST_RESULTS_DIR%gdunit4_report.html ^
    --coverage %COVERAGE_DIR%coverage.xml ^
    --log-file %LOG_FILE% ^
    --verbose

SET EXIT_CODE=%ERRORLEVEL%
echo [RESULT] Tests completed with exit code: %EXIT_CODE%

echo.
echo [PHASE 3] Result Analysis
echo ========================
echo.

REM Analyze test results
if exist "%TEST_RESULTS_DIR%gdunit4_results.xml" (
    echo [ANALYSIS] Parsing test results...
    
    REM Count test suites
    findstr /C:"testsuite" "%TEST_RESULTS_DIR%gdunit4_results.xml" > temp_suites.log
    for /f %%i in ('type temp_suites.log ^| find /c /v ""') do SET TEST_SUITE_COUNT=%%i
    
    REM Count test cases
    findstr /C:"testcase" "%TEST_RESULTS_DIR%gdunit4_results.xml" > temp_cases.log
    for /f %%i in ('type temp_cases.log ^| find /c /v ""') do SET TEST_CASE_COUNT=%%i
    
    REM Count failures
    findstr /C:"failure" "%TEST_RESULTS_DIR%gdunit4_results.xml" > temp_failures.log
    for /f %%i in ('type temp_failures.log ^| find /c /v ""') do SET TEST_FAILURE_COUNT=%%i
    
    REM Count errors
    findstr /C:"error" "%TEST_RESULTS_DIR%gdunit4_results.xml" > temp_errors.log
    for /f %%i in ('type temp_errors.log ^| find /c /v ""') do SET TEST_ERROR_COUNT=%%i
    
    echo [RESULTS] Test Execution Summary:
    echo    - Test Suites: %TEST_SUITE_COUNT%
    echo    - Test Cases: %TEST_CASE_COUNT%
    echo    - Failures: %TEST_FAILURE_COUNT%
    echo    - Errors: %TEST_ERROR_COUNT%
    
    if %TEST_FAILURE_COUNT% GTR 0 (
        echo [WARNING] Some tests failed - see detailed results
        SET /A WARNING_COUNT+=1
    )
    
    if %TEST_ERROR_COUNT% GTR 0 (
        echo [ERROR] Test execution errors detected
        SET /A ERROR_COUNT+=1
    )
) else (
    echo [WARNING] No test results file generated
    SET /A WARNING_COUNT+=1
)

REM Analyze coverage if available
if exist "%COVERAGE_DIR%coverage.xml" (
    echo [COVERAGE] Analyzing code coverage...
    
    REM Extract coverage percentage
    findstr /C:"line-rate" "%COVERAGE_DIR%coverage.xml" > temp_coverage.log
    for /f "tokens=2 delims== " %%i in ('type temp_coverage.log') do SET COVERAGE_PERCENTAGE=%%i
    
    echo [COVERAGE] Code coverage: %COVERAGE_PERCENTAGE%%
    
    REM Check if coverage meets threshold
    if defined COVERAGE_PERCENTAGE (
        for /f "tokens=1 delims=." %%j in ("%COVERAGE_PERCENTAGE%") do SET COVERAGE_INT=%%j
        if %COVERAGE_INT% LSS 80 (
            echo [WARNING] Coverage below 80%% threshold
            SET /A WARNING_COUNT+=1
        )
    )
)

echo.
echo [PHASE 4] Log Analysis
echo =====================
echo.

REM Analyze detailed logs for specific issues
if exist "%LOG_FILE%" (
    echo [LOG] Analyzing pipeline logs...
    
    REM Look for critical errors
    findstr /C:"CRITICAL" "%LOG_FILE%" > temp_critical.log
    for /f %%i in ('type temp_critical.log ^| find /c /v ""') do SET CRITICAL_LOG_COUNT=%%i
    
    REM Look for warnings
    findstr /C:"WARNING" "%LOG_FILE%" > temp_warnings.log
    for /f %%i in ('type temp_warnings.log ^| find /c /v ""') do SET WARNING_LOG_COUNT=%%i
    
    REM Look for errors
    findstr /C:"ERROR" "%LOG_FILE%" > temp_log_errors.log
    for /f %%i in ('type temp_log_errors.log ^| find /c /v ""') do SET ERROR_LOG_COUNT=%%i
    
    echo [LOG ANALYSIS] Pipeline Log Summary:
    echo    - Critical Issues: %CRITICAL_LOG_COUNT%
    echo    - Warnings: %WARNING_LOG_COUNT%
    echo    - Errors: %ERROR_LOG_COUNT%
    
    if %CRITICAL_LOG_COUNT% GTR 0 (
        echo [CRITICAL] Critical issues found in pipeline logs:
        type temp_critical.log
        SET /A ERROR_COUNT+=1
    )
)

echo.
echo [PHASE 5] Final Status Assessment
echo ================================
echo.

REM Determine overall pipeline status
if %EXIT_CODE% NEQ 0 (
    echo [STATUS] ❌ PIPELINE FAILED - Process exited with error code %EXIT_CODE%
    SET PIPELINE_STATUS=FAILED
    goto :error_summary
)

if %ERROR_COUNT% GTR 0 (
    echo [STATUS] ❌ PIPELINE FAILED - Critical errors detected
    SET PIPELINE_STATUS=FAILED
    goto :error_summary
)

if %TEST_FAILURE_COUNT% GTR 0 (
    echo [STATUS] ⚠️  PIPELINE PARTIAL SUCCESS - Tests executed but some failed
    SET PIPELINE_STATUS=PARTIAL
) else (
    echo [STATUS] ✅ PIPELINE SUCCESS - All tests passed
    SET PIPELINE_STATUS=SUCCESS
)

goto :summary

:error_summary
echo.
echo ===============================================================================
echo ERROR SUMMARY
echo ===============================================================================
echo.

if exist temp_critical.log (
    echo [CRITICAL ISSUES:]
    type temp_critical.log
    echo.
)

if exist temp_log_errors.log (
    echo [ERRORS FOUND:]
    type temp_log_errors.log
    echo.
)

if exist temp_failures.log (
    echo [TEST FAILURES:]
    type temp_failures.log
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
echo Exit Code: %EXIT_CODE%
echo Errors: %ERROR_COUNT%
echo Warnings: %WARNING_COUNT%
echo Test Failures: %TEST_FAILURE_COUNT%
echo Test Errors: %TEST_ERROR_COUNT%
echo Coverage: %COVERAGE_PERCENTAGE%%
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
    echo    All tests passed and pipeline executed successfully.
    exit /b 0
)

echo.
echo Detailed logs saved to: %LOG_FILE%
echo Test results saved to: %TEST_RESULTS_DIR%gdunit4_results.xml
echo Coverage report saved to: %COVERAGE_DIR%coverage.xml
echo HTML report saved to: %TEST_RESULTS_DIR%gdunit4_report.html
echo.

endlocal
```

## Best Practices for GDUnit4 Testing

### 1. Test Structure Guidelines

#### AAA Pattern (Arrange-Act-Assert)
```gdscript
func test_feature_behavior_under_specific_conditions():
    # ARRANGE - Set up test data and preconditions
    var test_object = TestClass.new()
    test_object.setup_test_data()
    
    # ACT - Execute the behavior being tested
    var result = test_object.perform_action()
    
    # ASSERT - Verify the expected outcome
    assert_that(result).is_equal(expected_value)
        .with_message("Clear description of what is being tested")
```

### 2. Test Data Management

#### Factory Methods
```gdscript
# Use factory methods for consistent test data
func _create_test_empire(id: String = "test_empire", name: String = "Test Empire") -> Empire:
    var empire = Empire.new()
    empire.id = id
    empire.display_name = name
    empire.color = Color.RED
    empire.is_ai_controlled = false
    return empire

# Reuse test data when possible
func before_each():
    test_empire = _create_test_empire()
```

### 3. Test Isolation

#### Independent Tests
```gdscript
# Each test should be independent
func test_feature_a():
    # Don't rely on state from test_feature_b()
    var local_data = create_test_data()
    # Test implementation
    
func test_feature_b():
    # Don't rely on state from test_feature_a()
    var local_data = create_test_data()
    # Test implementation
```

## Migration Checklist

### Phase 1: Setup and Installation
- [ ] Install GDUnit4 framework
- [ ] Configure project settings
- [ ] Create GDUnit4 configuration file
- [ ] Set up test directory structure
- [ ] Verify installation with sample test

### Phase 2: Core System Migration
- [ ] Migrate EmpireManager tests
- [ ] Migrate ColonyManager tests  
- [ ] Migrate GameManager tests
- [ ] Migrate AIManager tests
- [ ] Migrate TechnologyEffectManager tests

### Phase 3: Integration Testing
- [ ] Create scene testing capabilities
- [ ] Implement UI validation tests
- [ ] Add performance benchmarking
- [ ] Set up fuzz testing for critical functions
- [ ] Configure flaky test detection

### Phase 4: CI/CD Integration
- [ ] Update pipeline scripts
- [ ] Configure proper error reporting
- [ ] Set up coverage analysis
- [ ] Implement memory leak detection
- [ ] Add detailed logging capabilities

### Phase 5: Documentation and Training
- [ ] Update testing documentation
- [ ] Create migration guides
- [ ] Document best practices
- [ ] Provide team training
- [ ] Set up example test templates

## Troubleshooting Common Issues

### 1. Installation Problems
```bash
# If GDUnit4 fails to install
git submodule update --init --recursive
git submodule foreach git pull origin main

# If Godot can't find GDUnit4
# Check that addon.cfg exists in addons/gdUnit4/
# Verify plugin is enabled in Project Settings
```

### 2. Test Execution Issues
```gdscript
# If tests fail to run
# Check that test files extend GdUnitTestSuite.gd
# Verify @TestCase annotations are correct
# Ensure proper import statements
```

### 3. Assertion Failures
```gdscript
# If assertions fail unexpectedly
# Use with_message() to add context
# Check data setup in Arrange phase
# Verify expected vs actual values
```

## Future Improvements

### Planned Enhancements
1. **AI-Powered Test Generation**: Automatically generate test cases from code analysis
2. **Predictive Test Selection**: Run only relevant tests based on code changes
3. **Cross-Platform Validation**: Automated testing across all supported platforms
4. **Security Vulnerability Scanning**: Integration with security testing tools
5. **Performance Regression Detection**: Automatic identification of performance degradations

### Community Contributions
We welcome contributions to improve the testing framework:
- **New Test Categories**: Add specialized testing for specific domains
- **Enhanced Reporting**: Improve test result visualization and analysis
- **Tool Integration**: Connect with additional development tools and services
- **Documentation**: Expand testing guides and best practices

## Support and Resources

### Getting Help
- **Documentation**: This comprehensive GDUnit4 integration guide
- **Issue Tracker**: GitHub issues for testing framework problems
- **Community Forums**: Discussion boards for testing strategies
- **Development Chat**: Real-time support in Discord/Slack

### Learning Resources
- **GDUnit4 Documentation**: Official framework guides and examples
- **Godot Testing Best Practices**: Industry-standard testing design
- **GDScript Testing Patterns**: Proven approaches to effective testing
- **Continuous Integration**: Automated testing and deployment strategies

---

*Last Updated: September 26, 2025*
*Version: 1.0.0*
