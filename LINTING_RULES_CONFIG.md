# Project Antares - Linting Rules Configuration

## Overview
This document defines the comprehensive linting rules configuration for Project Antares, including GDScript Toolkit (GDlint) rules, formatting standards, and best practices for maintaining code quality.

## GDScript Linting Rules

### Core Linting Philosophy
Project Antares follows a progressive linting approach:
1. **Phase 1**: Critical errors only (parse errors, missing classes, syntax issues)
2. **Phase 2**: Style and consistency rules (naming conventions, formatting)
3. **Phase 3**: Advanced quality rules (complexity, documentation, best practices)

### Enabled Rules (Critical Errors)
These rules are always enabled to catch fundamental issues:

#### Parse Error Detection
```yaml
# Always catch parse errors to prevent compilation failures
- parse-error                   # Syntax errors that prevent compilation
- duplicate-class-name         # Prevent duplicate class names causing conflicts
- duplicate-signal-name         # Prevent duplicate signal names causing conflicts
- duplicate-subscription        # Prevent duplicate signal subscriptions
- getter-setter-type-mismatch   # Ensure getter/setter type consistency
- empty-body                    # Warn about empty function bodies
- unreachable-code               # Detect unreachable code blocks
- comparison-with-itself        # Detect self-comparison (usually a bug)
- constant-condition            # Detect constant conditions (usually a bug)
- return-value-discarded        # Warn when return values are ignored
- shadowed-variable             # Detect shadowed variables causing confusion
- wrong-super-call-arguments    # Detect incorrect super() calls
- invalid-getter-setter-usage   # Detect invalid getter/setter usage
- invalid-signal-connection     # Detect invalid signal connections
- invalid-node-path            # Detect invalid node paths
- invalid-resource-path         # Detect invalid resource paths
- invalid-group-name            # Detect invalid group names
- invalid-property-name        # Detect invalid property names
```

#### Script Loading Validation
```yaml
# Validate script loading and class resolution
- failed-to-load-script        # Detect script loading failures
- could-not-find-type          # Detect missing class definitions
- failed-to-instantiate-autoload # Detect autoload instantiation failures
- invalid-access-to-property   # Detect invalid property access
- nonexistent-function         # Detect calls to non-existent functions
```

### Disabled Rules (Temporary Relaxations)
These rules are temporarily disabled to allow gradual adoption:

#### Documentation Rules
```yaml
# Temporarily allow missing documentation during refactoring
- missing-docstring              # Allow missing function/class docstrings
- missing-module-docstring       # Allow missing module docstrings
- missing-class-docstring        # Allow missing class docstrings
- missing-function-docstring     # Allow missing function docstrings
- missing-parameter-docstring    # Allow missing parameter documentation
- missing-return-docstring       # Allow missing return value documentation
```

#### Code Quality Rules
```yaml
# Temporarily relax quality rules during active development
- unused-argument                # Allow unused arguments in overridden methods
- unused-variable                # Allow variables that might be used later
- naming-convention-violation   # Temporarily relax naming conventions
- line-too-long                 # Allow longer lines for complex expressions
- function-too-long             # Allow longer functions during refactoring
- class-too-long                # Allow longer classes during refactoring
- too-many-arguments            # Allow functions with many arguments
- too-many-locals               # Allow functions with many local variables
- too-many-branches             # Allow functions with many branches
- too-many-statements           # Allow functions with many statements
- too-many-public-methods       # Allow classes with many public methods
- too-many-attributes           # Allow classes with many attributes
- too-many-return-statements    # Allow functions with many return statements
- too-many-nested-blocks        # Allow functions with nested blocks
- too-many-instance-attributes  # Allow classes with many instance attributes
- too-many-public-members       # Allow classes with many public members
- too-many-private-members      # Allow classes with many private members
- too-many-protected-members    # Allow classes with many protected members
```

#### Complexity Rules
```yaml
# Temporarily relax complexity rules during active development
- cyclomatic-complexity         # Allow complex branching logic
- cognitive-complexity          # Allow complex cognitive load
- nesting-depth                 # Allow deep nesting
- function-parameters-count     # Allow many function parameters
- class-methods-count           # Allow many class methods
- class-attributes-count        # Allow many class attributes
- module-lines-count           # Allow long modules
- file-lines-count             # Allow long files
```

## Formatting Standards

### Code Style Guidelines

#### Indentation and Spacing
```yaml
# Consistent indentation and spacing rules
indent_size: 4                    # 4 spaces for indentation
indent_type: spaces               # Use spaces, not tabs
max_line_length: 120              # Maximum line length (standard for most projects)
newline_style: lf                # Unix line endings
insert_final_newline: true        # Insert final newline at end of file

# Spacing around operators
spaces_around_operators: true     # Spaces around =, +, -, *, /, etc.
spaces_around_delimiters: true    # Spaces around [], {}, ()
spaces_around_comments: true     # Spaces around # comments
spaces_before_colon: false        # No space before : (except in dictionaries)
spaces_after_colon: true         # Space after : in dictionaries and ternary
spaces_before_comma: false        # No space before ,
spaces_after_comma: true          # Space after ,

# Line spacing
blank_lines_after_imports: 1     # Blank line after import statements
blank_lines_after_class_declaration: 1  # Blank line after class declaration
blank_lines_after_function_declaration: 1  # Blank line after function declaration
blank_lines_before_function_return: 1  # Blank line before return statement
blank_lines_between_functions: 1  # Blank line between functions
blank_lines_between_classes: 2    # Blank lines between classes
```

#### Wrapping and Alignment
```yaml
# Code wrapping and alignment rules
wrap_line_on_long_call: true      # Wrap long function calls
wrap_line_on_long_list: true      # Wrap long lists
wrap_line_on_long_dict: true      # Wrap long dictionaries
wrap_line_on_long_string: true    # Wrap long strings
wrap_line_on_long_condition: true  # Wrap long conditions

# Comment alignment
align_comments: true              # Align comments vertically
comment_min_spacing: 2            # Minimum spacing for comment alignment

# Import sorting
sort_imports: true                # Sort import statements alphabetically
sort_dictionary_keys: false      # Don't sort dictionary keys (preserve order)
sort_case_sensitive: false         # Case insensitive sorting
```

### Naming Conventions

#### Class Names
```gdscript
# Classes use PascalCase
class_name GalaxyManager extends Node
class_name StarSystemView extends Node2D
class_name PlanetData extends Resource
class_name TechnologyEffectManager extends Node
```

#### Function Names
```gdscript
# Functions use snake_case
func calculate_optimal_routes():
    pass

func get_empire_by_id(empire_id: StringName) -> Empire:
    return empires.get(empire_id)

func _private_helper_function():
    pass
```

#### Variable Names
```gdscript
# Variables use snake_case
var current_system_id = ""
var is_active = false
var owned_ships: Dictionary = {}
var research_points: int = 0
```

#### Constant Names
```gdscript
# Constants use UPPER_SNAKE_CASE
const MAX_SYSTEMS = 100
const DEFAULT_FLEET_SIZE = 10
const RESEARCH_COST_MULTIPLIER = 1.5
const FOOD_PRODUCTION_RATE = 2.0
```

#### Enum Names
```gdscript
# Enums use PascalCase
enum AIPersonality {
    AGGRESSIVE,
    DEFENSIVE,
    EXPANSIONIST,
    TECHNOLOGICAL,
    BALANCED
}

# Enum values use UPPER_SNAKE_CASE
enum PlanetType {
    TERRAN,
    OCEAN,
    DESERT,
    ICE,
    BARREN
}
```

## Project Antares Specific Rules

### Code Quality Standards

#### Documentation Requirements
```gdscript
# Functions should have docstrings explaining purpose, parameters, and return values
func calculate_distance(point_a: Vector2, point_b: Vector2) -> float:
    """
    Calculate the Euclidean distance between two points in 2D space.
    
    Args:
        point_a: The first point as a Vector2
        point_b: The second point as a Vector2
        
    Returns:
        float: The distance between the two points
        
    Example:
        var dist = calculate_distance(Vector2(0, 0), Vector2(3, 4))
        # Returns: 5.0
    """
    return point_a.distance_to(point_b)
```

#### Error Handling
```gdscript
# Proper error handling with descriptive messages
func load_empire_data(empire_id: String) -> Dictionary:
    if empire_id.is_empty():
        push_error("Empire ID cannot be empty")
        return {}
    
    var data = _load_from_file("user://%s.dat" % empire_id)
    if not data:
        push_warning("Failed to load data for empire: %s" % empire_id)
        return {}
        
    return data
```

#### Resource Management
```gdscript
# Proper resource loading with fallbacks
var hover_sound = preload("res://assets/audio/sfx/ui/ui_hover.wav")
if not hover_sound:
    hover_sound = preload("res://assets/audio/sfx/ui/default_hover.wav")

# Proper resource cleanup
func _exit_tree() -> void:
    if hover_sound:
        hover_sound = null
```

### Testing Standards

#### Test Naming Conventions
```gdscript
# Tests use descriptive names indicating what is being tested
func test_empire_manager_creates_new_empire_with_valid_parameters():
    pass

func test_colony_manager_handles_population_growth_with_insufficient_food():
    pass

func test_ai_manager_selects_appropriate_research_target_based_on_personality():
    pass
```

#### Test Structure
```gdscript
# Tests follow AAA pattern (Arrange-Act-Assert)
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
    # ARRANGE - Set up test data and preconditions
    var empire = Empire.new()
    empire.id = "test_empire"
    empire.display_name = "Test Empire"
    empire.research_points = 100
    empire.income_per_turn = 50
    
    # ACT - Execute the behavior being tested
    TechnologyEffectManager.apply_technology_effects(empire)
    
    # ASSERT - Verify the expected outcome
    assert_that(empire.research_points).is_greater_than(100)
    assert_that(empire.income_per_turn).is_greater_than(50)
```

### Performance Guidelines

#### Memory Management
```gdscript
# Use object pooling for frequently created/destroyed objects
var _object_pool: Array = []

func _get_pooled_object() -> Object:
    if _object_pool.size() > 0:
        return _object_pool.pop_back()
    return Object.new()

func _return_to_pool(obj: Object) -> void:
    obj.reset()  # Reset object state
    _object_pool.append(obj)
```

#### Efficient Loops
```gdscript
# Use efficient iteration patterns
# GOOD - Cache size to avoid repeated calls
var size = array.size()
for i in range(size):
    process_item(array[i])

# AVOID - Repeated size calls in loop condition
for i in range(array.size()):  # Inefficient
    process_item(array[i])
```

#### Resource Loading
```gdscript
# Preload resources when possible
const Empire = preload("res://gamedata/empires/empire.gd")
const Technology = preload("res://gamedata/technologies/technology.gd")
const ShipData = preload("res://gamedata/ships/ship_data.gd")

# Use lazy loading for large resources
func _load_large_asset(path: String):
    if not _asset_cache.has(path):
        _asset_cache[path] = load(path)
    return _asset_cache[path]
```

## Configuration Files

### .gdlint Configuration
```yaml
# GDScript Linting Configuration for Project Antares
disable:
  - missing-docstring              # Temporarily allow missing docstrings
  - unused-argument                # Allow unused arguments in overridden methods
  - unused-variable                # Allow variables that might be used in derived classes
  - naming-convention-violation   # Temporarily relax naming conventions
  - line-too-long                 # Allow longer lines for complex expressions
  - function-too-long             # Allow longer functions during refactoring
  - class-too-long                # Allow longer classes during refactoring
  - too-many-arguments            # Allow functions with many arguments during refactoring
  - too-many-locals               # Allow functions with many local variables
  - too-many-branches             # Allow functions with many branches
  - too-many-statements           # Allow functions with many statements
  - too-many-public-methods       # Allow classes with many public methods
  - too-many-attributes           # Allow classes with many attributes
  - too-many-return-statements    # Allow functions with many return statements
  - too-many-nested-blocks        # Allow functions with nested blocks
  - too-many-instance-attributes  # Allow classes with many instance attributes

enable:
  - parse-error                   # Always catch parse errors
  - duplicate-class-name         # Prevent duplicate class names
  - duplicate-signal-name         # Prevent duplicate signal names
  - duplicate-subscription        # Prevent duplicate signal subscriptions
  - getter-setter-type-mismatch   # Ensure getter/setter type consistency
  - empty-body                    # Warn about empty function bodies
  - unreachable-code               # Detect unreachable code
  - comparison-with-itself        # Detect self-comparison
  - constant-condition            # Detect constant conditions
  - return-value-discarded        # Warn when return values are discarded
  - shadowed-variable             # Detect shadowed variables
  - wrong-super-call-arguments    # Detect incorrect super() calls
  - invalid-getter-setter-usage   # Detect invalid getter/setter usage
  - invalid-signal-connection     # Detect invalid signal connections
  - invalid-node-path            # Detect invalid node paths
  - invalid-resource-path         # Detect invalid resource paths
  - invalid-group-name            # Detect invalid group names
  - invalid-property-name        # Detect invalid property names

# Configuration parameters
max-line-length: 120              # Maximum line length (standard for most projects)
max-function-lines: 50           # Maximum lines per function
max-class-lines: 500             # Maximum lines per class
max-file-lines: 1000             # Maximum lines per file
max-parameters: 8                 # Maximum parameters per function
max-branches: 12                  # Maximum branches in a function
max-locals: 15                    # Maximum local variables in a function
max-expressions: 50              # Maximum expressions in a function
max-public-methods: 20           # Maximum public methods per class
max-attributes: 20               # Maximum attributes per class
max-return-statements: 5          # Maximum return statements per function
max-nested-blocks: 4              # Maximum nested blocks per function
max-instance-attributes: 20       # Maximum instance attributes per class

# Naming convention rules
class-name-case: PascalCase       # Class names in PascalCase
function-name-case: snake_case    # Function names in snake_case
variable-name-case: snake_case    # Variable names in snake_case
constant-name-case: UPPER_SNAKE_CASE  # Constants in UPPER_SNAKE_CASE

# Indentation rules
indent-size: 4                    # 4 spaces for indentation
indent-type: spaces               # Use spaces, not tabs
