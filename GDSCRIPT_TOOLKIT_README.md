# Project Antares - GDScript Toolkit Integration

## Overview
This document provides comprehensive information about the GDScript Toolkit integration for Project Antares, including installation, configuration, usage, and best practices.

## Table of Contents
1. [Introduction](#introduction)
2. [Installation](#installation)
3. [Configuration](#configuration)
4. [Usage](#usage)
5. [CI/CD Integration](#ci-cd-integration)
6. [Best Practices](#best-practices)
7. [Troubleshooting](#troubleshooting)
8. [Contributing](#contributing)

## Introduction

The GDScript Toolkit integration brings professional-grade static analysis, code formatting, and documentation generation to Project Antares. This integration includes:

- **GDlint**: Static code analysis for syntax errors, style violations, and code quality issues
- **GDFormat**: Automatic code formatting to enforce consistent style
- **GDDoc**: Documentation generation from code comments
- **Enhanced CI/CD Pipeline**: Integrated analysis with proper error reporting

## Installation

### Prerequisites
- Python 3.7 or higher
- pip package manager
- Godot Engine 3.5+ or 4.0+

### Installing GDToolkit

#### Method 1: Global Installation
```bash
pip install gdtoolkit
```

#### Method 2: Virtual Environment (Recommended)
```bash
# Create virtual environment
python -m venv gdtoolkit-env

# Activate virtual environment
# Windows:
gdtoolkit-env\Scripts\activate
# macOS/Linux:
source gdtoolkit-env/bin/activate

# Install GDToolkit
pip install gdtoolkit
```

#### Method 3: User Installation
```bash
pip install --user gdtoolkit
```

### Verifying Installation
```bash
gdlint --version
gdformat --version
gddoc --version
```

## Configuration

### Project Configuration Files

#### .gdlint
Located in the project root, this file contains linting rules specific to Project Antares:
```yaml
# GDScript Linting Configuration for Project Antares
disable:
  - missing-docstring              # Temporarily allow missing docstrings
  - unused-argument                # Allow unused arguments in overridden methods
  # ... other disabled rules

enable:
  - parse-error                   # Always catch parse errors
  - duplicate-class-name         # Prevent duplicate class names
  # ... other enabled rules

# Configuration parameters
max-line-length: 120
max-function-lines: 50
# ... other parameters
```

#### .gdformat
Located in the project root, this file contains formatting rules:
```yaml
# GDScript Formatting Configuration for Project Antares
indent_size: 4
indent_type: spaces
max_line_length: 120
# ... other formatting parameters
```

### IDE Integration

#### Visual Studio Code
Install the Godot Tools extension and configure:
```json
{
    "gdscript.lintOnSave": true,
    "gdscript.formatOnSave": true,
    "gdscript.linting.enabled": true,
    "gdscript.linting.configPath": ".gdlint",
    "gdscript.formatting.configPath": ".gdformat"
}
```

#### Vim/Neovim
```vim
Plug 'habamax/vim-godot'
let g:godot_gdscript_lint_on_write = 1
let g:godot_gdscript_format_on_write = 1
```

## Usage

### Basic Linting
```bash
# Lint all GDScript files in the project
gdlint scripts/**/*.gd gamedata/**/*.gd managers/**/*.gd

# Lint with project-specific configuration
gdlint --config .gdlint scripts/managers/AIManager.gd

# Lint with verbose output
gdlint --verbose scripts/**/*.gd
```

### Code Formatting
```bash
# Check formatting without modifying files
gdformat --check scripts/**/*.gd

# Format files in-place
gdformat scripts/**/*.gd

# Format with specific configuration
gdformat --config .gdformat scripts/managers/DataManager.gd
```

### Documentation Generation
```bash
# Generate documentation for a single file
gddoc scripts/managers/AIManager.gd

# Generate documentation for all files
gddoc scripts/**/*.gd > docs/api_reference.md
```

### Advanced Usage

#### Selective Linting
```bash
# Lint only changed files
git diff --name-only HEAD~1 HEAD | grep "\.gd$" | xargs gdlint

# Lint specific directories
gdlint scripts/managers/*.gd
gdlint gamedata/empires/*.gd
```

#### Batch Operations
```bash
# Format and lint in one command
gdformat scripts/**/*.gd && gdlint scripts/**/*.gd

# Check formatting and lint with error handling
gdformat --check scripts/**/*.gd || echo "Formatting issues found"
gdlint scripts/**/*.gd || echo "Linting issues found"
```

## CI/CD Integration

### Enhanced Pipeline Features

The `enhanced_ci_with_gdlint.bat` script provides comprehensive CI/CD integration:

#### Phase 1: Pre-flight Validation
- Godot executable verification
- GDToolkit availability check and installation
- Project structure validation

#### Phase 2: Static Code Analysis
- GDlint syntax and style checking
- GDFormat formatting validation
- Error categorization and reporting

#### Phase 3: Resource Validation
- Asset existence verification
- Missing critical file detection

#### Phase 4: Script Compilation Testing
- Godot headless execution
- Detailed error capture

#### Phase 5: Error Analysis
- Parse error detection
- Script loading failure analysis
- Missing class identification

#### Phase 6: Test Execution
- Unit test running
- Results analysis and reporting

#### Phase 7: Final Assessment
- Status determination
- Detailed reporting
- Proper exit code handling

### GitHub Actions Integration
```yaml
name: GDScript Lint
on: [push, pull_request]

jobs:
  lint:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Set up Python
        uses: actions/setup-python@v4
        with:
          python-version: '3.9'
      - name: Install GDToolkit
        run: pip install gdtoolkit
      - name: Run GDScript Lint
        run: gdlint scripts/**/*.gd gamedata/**/*.gd managers/**/*.gd
```

### GitLab CI Integration
```yaml
gdlint:
  stage: lint
  image: python:3.9
  before_script:
    - pip install gdtoolkit
  script:
    - gdlint scripts/**/*.gd gamedata/**/*.gd managers/**/*.gd
    - gdformat --check scripts/**/*.gd gamedata/**/*.gd managers/**/*.gd
```

## Best Practices

### Code Quality Standards

#### Naming Conventions
```gdscript
# Classes: PascalCase
class_name GalaxyManager extends Node

# Functions: snake_case  
func calculate_optimal_routes():
    pass

# Variables: snake_case
var current_system_id = ""
var is_active = false

# Constants: UPPER_SNAKE_CASE
const MAX_SYSTEMS = 100
const DEFAULT_FLEET_SIZE = 10
```

#### Documentation Requirements
```gdscript
# Functions should have docstrings
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

### Incremental Adoption Strategy

#### Phase 1: Critical Issues Only
```bash
# Start with only critical errors
gdlint --disable-all --enable parse-error,duplicate-class-name scripts/**/*.gd
```

#### Phase 2: Style Rules
```bash
# Gradually enable style rules
gdlint --disable naming-convention-violation,missing-docstring scripts/**/*.gd
```

#### Phase 3: Full Compliance
```bash
# Enable all rules for new code
gdlint scripts/**/*.gd
```

### Team Collaboration

#### Pre-commit Hooks
```yaml
repos:
  - repo: local
    hooks:
      - id: gdlint
        name: GDScript Lint
        entry: gdlint
        language: system
        types: [file]
        files: \.(gd)$
```

#### Code Review Process
- Run linting before submitting pull requests
- Address all linting warnings and errors
- Document exceptions with inline comments
- Follow established naming conventions

## Troubleshooting

### Common Installation Issues

#### Permission Errors
```bash
# Install with user flag
pip install --user gdtoolkit

# Or use sudo (Linux/macOS)
sudo pip install gdtoolkit
```

#### Python Version Issues
```bash
# Check Python version
python --version

# Use specific Python version
python3.9 -m pip install gdtoolkit
```

#### PATH Issues
```bash
# Add to PATH (Linux/macOS)
export PATH="$PATH:$HOME/.local/bin"

# Add to PATH (Windows)
set PATH=%PATH%;%USERPROFILE%\AppData\Roaming\Python\Python39\Scripts
```

### Common Usage Issues

#### Configuration Not Found
```bash
# Specify configuration explicitly
gdlint --config .gdlint scripts/**/*.gd

# Check current directory
pwd
ls -la .gdlint
```

#### File Pattern Issues
```bash
# Use quotes for file patterns
gdlint "scripts/**/*.gd"

# Use find for complex patterns
find . -name "*.gd" -path "scripts/*" | xargs gdlint
```

### Performance Optimization

#### Parallel Processing
```bash
# Process files in parallel
find scripts/ -name "*.gd" | xargs -P 4 -I {} gdlint {}
```

#### Selective Processing
```bash
# Only process changed files
git diff --name-only HEAD~1 HEAD | grep "\.gd$" | xargs gdlint
```

## Contributing

### Getting Started
1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Run linting and formatting checks
5. Submit a pull request

### Code Review Process
- All code must pass GDlint checks
- Formatting must comply with GDFormat standards
- Documentation should be updated for new features
- Tests should be added for new functionality

### Reporting Issues
- Check existing issues before creating new ones
- Provide detailed reproduction steps
- Include error messages and logs
- Specify GDToolkit version and Python version

### Feature Requests
- Explain the use case and benefits
- Provide examples of how the feature would be used
- Consider impact on existing code
- Discuss potential implementation approaches

## Additional Resources

### Documentation
- [GDToolkit GitHub Repository](https://github.com/Scony/godot-gdscript-toolkit)
- [Godot GDScript Style Guide](https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/gdscript_styleguide.html)
- [Project Antares Documentation](./docs/)

### Configuration Files
- `.gdlint`: Linting configuration
- `.gdformat`: Formatting configuration
- `project_antares.gdlint`: Project-specific advanced configuration

### Scripts
- `enhanced_ci_with_gdlint.bat`: Enhanced CI/CD pipeline
- `GDSCRIPT_TOOLKIT_SETUP.md`: Detailed installation guide

### Support
For questions and support:
- Open an issue on GitHub
- Contact the development team
- Check the project documentation

---

*Last Updated: September 25, 2025*
*Version: 1.0.0*
