# Project Antares - Testing Framework

## Overview
Project Antares uses the **Godot Unit Test (GUT)** framework for comprehensive testing of all game systems. The testing framework is designed to prevent redundant testing, eliminate testing overlap, and ensure that new additions automatically run through the test suite before being considered "good".

## Test Architecture

### Test Organization
```
tests/
├── test_ai_manager.gd              # AI decision making and behavior
├── test_audio_manager.gd           # Audio system functionality
├── test_colony_management.gd       # Colony establishment and management
├── test_colony_manager.gd          # Colony resource production and growth
├── test_combat.gd                  # Combat system mechanics
├── test_council_manager.gd         # Diplomatic council functionality
├── test_data_manager.gd            # Data loading and management
├── test_debug_manager.gd           # Debug system functionality
├── test_empire_manager.gd          # Empire creation and management
├── test_galaxy.gd                  # Galaxy generation and management
├── test_galaxy_manager.gd          # Star system and celestial body management
├── test_game_manager.gd            # Game state and progression
├── test_game_setup.gd              # New game setup and configuration
├── test_main_menu.gd               # Main menu UI functionality
├── test_save_load_versioning.gd    # Save/load system and version compatibility
├── test_scene_validator.gd         # Scene loading and validation
├── test_ship_fleet_integration.gd  # Ship and fleet system integration
├── test_static_analysis.gd         # Code quality and static analysis
├── test_technology_effect_manager.gd # Technology effects and bonuses
├── test_turn_manager.gd            # Turn-based game progression
├── test_turns_integration_cycle.gd # Full turn cycle integration
└── test_ui_layouts.gd             # UI layout and positioning
```

### Test Categories
1. **Unit Tests**: Individual function and method testing
2. **Integration Tests**: Multi-component interaction testing
3. **System Tests**: Full system functionality testing
4. **Regression Tests**: Preventing previously fixed bugs from returning
5. **Performance Tests**: Resource usage and optimization validation
6. **Compatibility Tests**: Cross-platform and version compatibility

## Test Coverage Strategy

### Preventing Redundant Testing
To prevent redundant testing, Project Antares implements:

#### 1. Test Dependency Mapping
Each test file explicitly declares its dependencies and scope:
```gdscript
# test_colony_manager.gd
extends "res://addons/gut/test.gd"

# Scope: Colony resource production, population growth, building management
# Dependencies: ColonyData, PlanetData, Empire, ResourceManager
# Exclusions: Combat systems, AI decision making, UI rendering
```

#### 2. Test Isolation
Tests are isolated by functionality to prevent overlap:
- **Colony Management**: Population, resources, buildings
- **AI Systems**: Decision weights, behavior patterns, turn execution
- **Game Progression**: Turn cycles, victory conditions, state management
- **Data Systems**: Loading, saving, migration, validation

#### 3. Unique Test Identification
Each test has a unique identifier and clear scope:
```gdscript
func test_colony_population_growth_with_normal_conditions():
    # Test ID: COLONY-001
    # Scope: Normal population growth under standard conditions
    # Dependencies: ColonyData, PlanetData
    # Exclusions: None
    pass

func test_colony_population_growth_with_food_shortage():
    # Test ID: COLONY-002
    # Scope: Population decline due to insufficient food
    # Dependencies: ColonyData, PlanetData
    # Exclusions: None
    pass
```

### AI Readability and Adherence

#### 1. Structured Test Documentation
All tests follow a standardized documentation format:
```gdscript
func test_technology_effect_application():
    """
    Test ID: TECH-001
    Description: Verify that technology effects are properly applied to empires
    Scope: TechnologyEffectManager.apply_technology_effects()
    Preconditions: 
        - Empire exists with valid ID
        - Technology data is loaded
        - Empire has unlocked technologies
    Postconditions:
        - Technology effects are applied to empire attributes
        - Applied effects are tracked in TechnologyEffectManager
    Expected Results:
        - Empire attributes are modified according to technology effects
        - No errors or exceptions occur
    """
    # Test implementation here
```

#### 2. Semantic Test Naming
Tests use descriptive, semantic names that clearly indicate purpose:
```gdscript
# GOOD - Clear semantic meaning
func test_empire_manager_creates_new_empire_with_valid_parameters():
func test_colony_manager_handles_population_growth_with_insufficient_food():
func test_ai_manager_selects_appropriate_research_target_based_on_personality():

# AVOID - Ambiguous naming
func test_1():
func test_empire_creation():
func test_ai_behavior():
```

#### 3. Behavior-Driven Test Structure
Tests follow Given-When-Then structure for AI readability:
```gdscript
func test_colony_building_construction_completes_when_requirements_met():
    # GIVEN: A colony with sufficient production and valid building in queue
    var colony = _create_test_colony()
    colony.production_produced = 100
    var building = BuildingData.create_hydroponics_farm()
    colony.construction_queue.append(building)
    
    # WHEN: Construction processing occurs
    ColonyManager._process_construction(colony)
    
    # THEN: Building should be completed and moved to active buildings
    assert_eq(colony.construction_queue.size(), 0, "Construction queue should be empty")
    assert_eq(colony.buildings.size(), 1, "Building should be added to active buildings")
    assert_true(colony.buildings[0] is BuildingData, "Active building should be BuildingData instance")
```

## Automatic Test Suite Integration

### New Addition Validation
All new code additions must automatically run through the test suite:

#### 1. Pre-commit Hooks
```yaml
# .pre-commit-config.yaml
repos:
  - repo: local
    hooks:
      - id: antares-tests
        name: Project Antares Tests
        entry: ./run_ci.bat
        language: system
        types: [file]
        files: \.(gd)$
        pass_filenames: false
```

#### 2. Git Hooks Implementation
```bash
#!/bin/bash
# pre-commit hook
echo "Running Project Antares test suite..."

# Run fast tests first
./run_ci_fast.bat
if [ $? -ne 0 ]; then
    echo "❌ Fast tests failed - commit aborted"
    exit 1
fi

# Run full test suite for significant changes
if git diff --cached --name-only | grep -E "\.(gd|tscn|tres)$"; then
    echo "🎮 Running full test suite for code changes..."
    ./run_ci.bat
    if [ $? -ne 0 ]; then
        echo "❌ Full test suite failed - commit aborted"
        exit 1
    fi
fi

echo "✅ All tests passed - commit allowed"
exit 0
```

#### 3. Continuous Integration Validation
The CI/CD pipeline automatically validates all changes:
```yaml
# GitHub Actions workflow
name: Project Antares CI/CD
on: [push, pull_request]

jobs:
  test:
    runs-on: windows-latest
    steps:
      - uses: actions/checkout@v3
      - name: Run Fast Tests
        run: ./run_ci_fast.bat
      - name: Run Full Test Suite
        run: ./run_ci.bat
      - name: Upload Test Results
        uses: actions/upload-artifact@v3
        if: always()
        with:
          name: test-results
          path: test_results.xml
```

### Test Dependency Resolution
The system automatically resolves test dependencies:

#### 1. Test Order Optimization
Tests are organized to minimize setup/teardown overhead:
```gdscript
# Test execution order optimized for shared setup
# 1. DataManager tests (foundational data loading)
# 2. EmpireManager tests (depends on DataManager)
# 3. ColonyManager tests (depends on EmpireManager)
# 4. GalaxyManager tests (depends on DataManager)
# 5. AIManager tests (depends on all above)
```

#### 2. Shared Fixture Management
Common test fixtures are reused to prevent redundant setup:
```gdscript
# test_base.gd - Shared test base class
extends "res://addons/gut/test.gd"

var test_empire: Empire
var test_colony: ColonyData
var test_planet: PlanetData

func before_each():
    # Create shared test objects once and reuse
    if not test_empire:
        test_empire = _create_test_empire()
    if not test_planet:
        test_planet = _create_test_planet()
    if not test_colony:
        test_colony = _create_test_colony(test_planet, test_empire)
```

## Quality Assurance Standards

### Test Completeness Requirements
Each new feature must include:

#### 1. Unit Test Coverage
- **Minimum 80%** line coverage for new code
- **100%** branch coverage for critical paths
- **Edge case testing** for boundary conditions
- **Error condition testing** for failure scenarios

#### 2. Integration Test Coverage
- **Component interaction validation** for multi-system features
- **Data flow verification** between connected systems
- **State transition testing** for complex workflows
- **Performance baseline establishment** for resource-intensive operations

#### 3. Regression Test Coverage
- **Previously identified bug prevention** tests
- **Backward compatibility validation** for API changes
- **Cross-platform behavior consistency** verification
- **Save/load state preservation** testing

### Test Quality Metrics

#### 1. Code Coverage Analysis
```bash
# Generate coverage report
./run_ci_with_coverage.bat
# Results saved to coverage_report.html
```

Coverage targets:
- **New Code**: 80%+ line coverage
- **Core Systems**: 90%+ line coverage
- **Critical Paths**: 100% branch coverage
- **Public APIs**: 95%+ line coverage

#### 2. Performance Benchmarks
Tests are monitored for performance degradation:
- **Execution Time**: Each test should complete within 100ms
- **Memory Usage**: Tests should not leak memory
- **Resource Consumption**: Minimal CPU/GPU usage during testing
- **Parallel Execution**: Tests should support concurrent execution

#### 3. Reliability Metrics
- **Flaky Test Detection**: Tests that fail intermittently are flagged
- **Dependency Tracking**: Tests that fail due to external dependencies
- **Environment Sensitivity**: Tests that fail in different environments
- **Consistency Verification**: Tests that produce consistent results

## Debugging and Troubleshooting

### Enhanced Error Reporting
The testing framework provides detailed error information:

#### 1. Context-Rich Error Messages
```gdscript
func test_empire_research_progression():
    var empire = _create_test_empire()
    empire.current_researching_tech = "tech_advanced_research"
    empire.research_points = 50
    empire.research_per_turn = 25
    
    TechnologyEffectManager.apply_technology_effects(empire)
    
    # Enhanced assertion with context
    assert_eq(
        empire.research_points, 
        75, 
        "Empire research points should increase by 25 per turn. " +
        "Expected: 75, Got: %d. " % empire.research_points +
        "Check TechnologyEffectManager for research bonus calculations."
    )
```

#### 2. Stack Trace Preservation
Full stack traces are captured for debugging:
```gdscript
func _capture_stack_trace() -> String:
    var stack = get_stack()
    var trace = "Stack Trace:\n"
    for frame in stack:
        trace += "  %s:%d in %s()\n" % [frame.source, frame.line, frame.function]
    return trace
```

### Diagnostic Tools

#### 1. Test Profiling
```bash
# Run tests with profiling enabled
./run_ci.bat --profile
# Generates profile_report.json with timing information
```

#### 2. Memory Leak Detection
```bash
# Run tests with memory leak detection
./run_ci.bat --detect-leaks
# Reports object orphans and memory issues
```

#### 3. Dependency Analysis
```bash
# Analyze test dependencies
./analyze_test_dependencies.bat
# Generates dependency_graph.dot for visualization
```

## Best Practices for New Contributors

### Writing Effective Tests

#### 1. Test Structure Guidelines
```gdscript
func test_feature_behavior_under_specific_conditions():
    # ARRANGE - Set up test data and preconditions
    var test_object = TestClass.new()
    test_object.setup_test_data()
    
    # ACT - Execute the behavior being tested
    var result = test_object.perform_action()
    
    # ASSERT - Verify the expected outcome
    assert_eq(result, expected_value, "Clear description of what is being tested")
```

#### 2. Test Data Management
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

#### 3. Test Isolation
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

### Integration with Development Workflow

#### 1. Test-Driven Development
```gdscript
# RED - Write failing test first
func test_new_feature_functionality():
    var new_feature = NewFeature.new()
    var result = new_feature.do_something()
    assert_eq(result, expected_result, "Feature should work correctly")

# GREEN - Implement minimal code to make test pass
# REFACTOR - Improve implementation while keeping tests passing
```

#### 2. Continuous Testing
```bash
# Run tests automatically when files change
./watch_tests.bat
# Monitors file changes and runs relevant tests
```

#### 3. Test Result Analysis
```bash
# Generate detailed test reports
./generate_test_report.bat
# Creates HTML report with failure analysis and trends
```

## Future Improvements

### Planned Enhancements
1. **AI-Powered Test Generation**: Automatically generate test cases from code analysis
2. **Predictive Test Selection**: Run only relevant tests based on code changes
3. **Cross-Platform Validation**: Automated testing across all supported platforms
4. **Performance Regression Detection**: Automatic identification of performance degradations
5. **Security Vulnerability Scanning**: Integration with security testing tools

### Community Contributions
We welcome contributions to improve the testing framework:
- **New Test Categories**: Add specialized testing for specific domains
- **Enhanced Reporting**: Improve test result visualization and analysis
- **Tool Integration**: Connect with additional development tools and services
- **Documentation**: Expand testing guides and best practices

## Support and Resources

### Getting Help
- **Documentation**: This comprehensive testing guide
- **Issue Tracker**: GitHub issues for testing framework problems
- **Community Forums**: Discussion boards for testing strategies
- **Development Chat**: Real-time support in Discord/Slack

### Learning Resources
- **GUT Framework Documentation**: Official Godot Unit Test guides
- **GDScript Best Practices**: Coding standards and patterns
- **Test Design Patterns**: Proven approaches to effective testing
- **Performance Optimization**: Techniques for fast test execution

---

*Last Updated: September 26, 2025*
*Version: 1.0.0*
