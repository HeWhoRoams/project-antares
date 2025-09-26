# Project Antares - GDScript Toolkit Setup Guide

## Overview
This guide provides detailed instructions for installing and configuring the GDScript Toolkit (GDToolkit) including GDlint, GDFormat, and GDDoc for Project Antares development.

## Installation Methods

### Method 1: Python Package Installation (Recommended)

#### Prerequisites
- Python 3.7 or higher
- pip package manager

#### Installation Steps
```bash
# Install GDToolkit globally
pip install gdtoolkit

# Or install for current user only
pip install --user gdtoolkit

# Verify installation
gdlint --version
gdformat --version
gddoc --version
```

#### Virtual Environment Installation (Recommended for Projects)
```bash
# Create virtual environment
python -m venv gdtoolkit-env

# Activate virtual environment
# On Windows:
gdtoolkit-env\Scripts\activate
# On macOS/Linux:
source gdtoolkit-env/bin/activate

# Install GDToolkit in virtual environment
pip install gdtoolkit

# Verify installation
gdlint --version
```

### Method 2: Standalone Executable

#### Download from GitHub Releases
1. Visit [GDToolkit GitHub Releases](https://github.com/Scony/godot-gdscript-toolkit/releases)
2. Download the appropriate executable for your platform
3. Extract to a directory in your PATH

#### Manual Installation
```bash
# Download latest release (example for Windows)
curl -L https://github.com/Scony/godot-gdscript-toolkit/releases/download/v4.1.0/gdtoolkit-windows.zip -o gdtoolkit.zip

# Extract
unzip gdtoolkit.zip

# Add to PATH or copy to project directory
```

### Method 3: Docker Container

#### Pull Official Image
```bash
docker pull scony/gdtoolkit:latest
```

#### Run GDToolkit in Docker
```bash
# Run gdlint on project files
docker run -v ${PWD}:/project scony/gdtoolkit:latest gdlint /project/scripts/**/*.gd

# Run gdformat on project files
docker run -v ${PWD}:/project scony/gdtoolkit:latest gdformat /project/scripts/**/*.gd
```

## Platform-Specific Installation

### Windows Installation

#### Using Chocolatey
```powershell
# Install Python if not already installed
choco install python

# Install GDToolkit
pip install gdtoolkit
```

#### Using Scoop
```powershell
# Install Python if not already installed
scoop install python

# Install GDToolkit
pip install gdtoolkit
```

#### Manual Windows Installation
```cmd
REM Check Python installation
python --version

REM Install GDToolkit
pip install gdtoolkit

REM Add to PATH if needed
set PATH=%PATH%;%USERPROFILE%\AppData\Roaming\Python\Python39\Scripts
```

### macOS Installation

#### Using Homebrew
```bash
# Install Python if not already installed
brew install python

# Install GDToolkit
pip3 install gdtoolkit
```

#### Using MacPorts
```bash
# Install Python if not already installed
sudo port install python39

# Install GDToolkit
pip3 install gdtoolkit
```

### Linux Installation

#### Ubuntu/Debian
```bash
# Install Python and pip
sudo apt update
sudo apt install python3 python3-pip

# Install GDToolkit
pip3 install gdtoolkit
```

#### CentOS/RHEL/Fedora
```bash
# Install Python and pip
sudo dnf install python3 python3-pip  # Fedora
# or
sudo yum install python3 python3-pip  # CentOS/RHEL

# Install GDToolkit
pip3 install gdtoolkit
```

#### Arch Linux
```bash
# Install Python and pip
sudo pacman -S python python-pip

# Install GDToolkit
pip3 install gdtoolkit
```

## Project-Specific Setup

### 1. Configuration Files

#### .gdlint Configuration
Already created in project root with Project Antares specific rules.

#### .gdformat Configuration  
Already created in project root with Project Antares specific formatting rules.

### 2. IDE Integration

#### Visual Studio Code
```json
// .vscode/settings.json
{
    "gdscript.lintOnSave": true,
    "gdscript.formatOnSave": true,
    "gdscript.linting.enabled": true,
    "gdscript.linting.configPath": ".gdlint",
    "gdscript.formatting.configPath": ".gdformat"
}
```

#### Sublime Text
```json
// GDScriptLint.sublime-settings
{
    "lint_on_save": true,
    "format_on_save": true,
    "gdlint_args": ["--config", ".gdlint"],
    "gdformat_args": ["--config", ".gdformat"]
}
```

#### Vim/Neovim
```vim
" .vimrc or init.vim
Plug 'habamax/vim-godot'
let g:godot_gdscript_lint_on_write = 1
let g:godot_gdscript_format_on_write = 1
```

### 3. Pre-commit Hooks

#### Install pre-commit
```bash
pip install pre-commit
```

#### .pre-commit-config.yaml
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
        args: ["--config", ".gdlint"]

      - id: gdformat-check
        name: GDScript Format Check
        entry: gdformat
        language: system
        types: [file]
        files: \.(gd)$
        args: ["--check", "--config", ".gdformat"]

      - id: gdformat
        name: GDScript Format
        entry: gdformat
        language: system
        types: [file]
        files: \.(gd)$
        args: ["--config", ".gdformat"]
```

#### Install hooks
```bash
pre-commit install
```

## CI/CD Pipeline Integration

### GitHub Actions
```yaml
# .github/workflows/gdscript-lint.yml
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
        run: |
          pip install gdtoolkit
          
      - name: Run GDScript Lint
        run: |
          gdlint scripts/**/*.gd gamedata/**/*.gd managers/**/*.gd tests/**/*.gd || exit 1
          
      - name: Check GDScript Formatting
        run: |
          gdformat --check scripts/**/*.gd gamedata/**/*.gd managers/**/*.gd tests/**/*.gd || exit 1
```

### GitLab CI
```yaml
# .gitlab-ci.yml
stages:
  - lint
  - test

gdlint:
  stage: lint
  image: python:3.9
  before_script:
    - pip install gdtoolkit
  script:
    - gdlint scripts/**/*.gd gamedata/**/*.gd managers/**/*.gd tests/**/*.gd
    - gdformat --check scripts/**/*.gd gamedata/**/*.gd managers/**/*.gd tests/**/*.gd
  only:
    - merge_requests
    - master
```

### Jenkins Pipeline
```groovy
pipeline {
    agent any
    stages {
        stage('GDScript Lint') {
            steps {
                sh '''
                    pip install gdtoolkit
                    gdlint scripts/**/*.gd gamedata/**/*.gd managers/**/*.gd tests/**/*.gd
                    gdformat --check scripts/**/*.gd gamedata/**/*.gd managers/**/*.gd tests/**/*.gd
                '''
            }
        }
    }
}
```

## Usage Examples

### Basic Linting
```bash
# Lint all GDScript files in project
gdlint scripts/**/*.gd gamedata/**/*.gd managers/**/*.gd tests/**/*.gd

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
# Generate documentation
gddoc scripts/managers/AIManager.gd

# Generate documentation for all files
gddoc scripts/**/*.gd > docs/api_reference.md
```

## Project Antares Specific Rules

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

### Common Issues and Solutions

#### 1. Import Path Issues
```bash
# Ensure all import paths are correct
gdlint --config .gdlint scripts/**/*.gd
```

#### 2. Configuration Conflicts
```bash
# Use project-specific configurations
gdlint --config .gdlint --verbose scripts/**/*.gd
```

#### 3. Performance Optimization
```bash
# Parallel processing for large projects
find scripts/ -name "*.gd" | xargs -P 4 -I {} gdlint {}
```

## Troubleshooting

### Common Installation Issues

#### 1. Permission Errors
```bash
# Install with user flag
pip install --user gdtoolkit

# Or use sudo (Linux/macOS)
sudo pip install gdtoolkit
```

#### 2. Python Version Issues
```bash
# Check Python version
python --version

# Use specific Python version
python3.9 -m pip install gdtoolkit
```

#### 3. PATH Issues
```bash
# Add to PATH (Linux/macOS)
export PATH="$PATH:$HOME/.local/bin"

# Add to PATH (Windows)
set PATH=%PATH%;%USERPROFILE%\AppData\Roaming\Python\Python39\Scripts
```

### Common Usage Issues

#### 1. Configuration Not Found
```bash
# Specify configuration explicitly
gdlint --config .gdlint scripts/**/*.gd

# Check current directory
pwd
ls -la .gdlint
```

#### 2. File Pattern Issues
```bash
# Use quotes for file patterns
gdlint "scripts/**/*.gd"

# Use find for complex patterns
find . -name "*.gd" -path "scripts/*" | xargs gdlint
```

#### 3. Performance Issues
```bash
# Limit file processing
gdlint --jobs 2 scripts/**/*.gd

# Process specific directories
gdlint scripts/managers/*.gd gamedata/empires/*.gd
```

## Advanced Configuration

### Custom Rules
Create custom linting rules for Project Antares specific patterns:

```python
# custom_rules.py
from gdtoolkit.linter import Rule

class AntaresNamingRule(Rule):
    """Custom rule for Project Antares naming conventions"""
    
    def visit_class(self, node):
        # Custom logic for class naming
        pass
        
    def visit_function(self, node):
        # Custom logic for function naming
        pass
```

### Integration with Existing Tools

#### Integration with GUT (Godot Unit Test)
```bash
# Run linting before tests
./run_ci.bat
```

#### Integration with Godot Editor
```bash
# Use Godot's built-in script validation
godot --headless --check-only project.godot
```

## Best Practices

### 1. Incremental Adoption
Start with basic linting and gradually enable more rules:
```bash
# Phase 1: Critical errors only
gdlint --disable-all --enable parse-error,duplicate-class-name scripts/**/*.gd

# Phase 2: Add style rules
gdlint --disable naming-convention-violation,missing-docstring scripts/**/*.gd

# Phase 3: Enable all rules
gdlint scripts/**/*.gd
```

### 2. Team Collaboration
Create team-specific configurations:
```bash
# Team A configuration
cp .gdlint .gdlint-team-a
# Modify for team A preferences

# Team B configuration  
cp .gdlint .gdlint-team-b
# Modify for team B preferences
```

### 3. Continuous Improvement
Regularly review and update configurations:
```bash
# Monthly review
gdlint --stats scripts/**/*.gd > monthly_stats.txt
```

This comprehensive setup ensures that GDScript Toolkit is properly integrated into Project Antares development workflow, providing consistent code quality and automatic error detection.
