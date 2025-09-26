# Project Antares - GDScript Toolkit Installation and Setup Guide

## Overview
This guide provides detailed instructions for installing and configuring the GDScript Toolkit (GDToolkit) including GDlint, GDFormat, and GDDoc for Project Antares development.

## Prerequisites
- Python 3.7 or higher
- pip package manager
- Git (for submodule installation)
- Godot Engine 4.0+ (already installed at C:\Tools\godot.exe)

## Installation Methods

### Method 1: Python Package Installation (Recommended)

#### Windows Installation
```powershell
# Check Python installation
python --version

# Install GDToolkit globally
pip install gdtoolkit

# Or install for current user only (if you don't have admin rights)
pip install --user gdtoolkit

# Verify installation
gdlint --version
gdformat --version
gddoc --version
```

#### macOS Installation
```bash
# Check Python installation
python3 --version

# Install GDToolkit
pip3 install gdtoolkit

# Or install for current user only
pip3 install --user gdtoolkit

# Verify installation
gdlint --version
gdformat --version
gddoc --version
```

#### Linux Installation
```bash
# Check Python installation
python3 --version

# Install GDToolkit
pip3 install gdtoolkit

# Or install for current user only
pip3 install --user gdtoolkit

# Verify installation
gdlint --version
gdformat --version
gddoc --version
```

### Method 2: Virtual Environment Installation (Recommended for Projects)

#### Windows
```powershell
# Create virtual environment
python -m venv gdtoolkit-env

# Activate virtual environment
gdtoolkit-env\Scripts\activate

# Install GDToolkit in virtual environment
pip install gdtoolkit

# Verify installation
gdlint --version
gdformat --version
gddoc --version

# Deactivate when done
deactivate
```

#### macOS/Linux
```bash
# Create virtual environment
python3 -m venv gdtoolkit-env

# Activate virtual environment
source gdtoolkit-env/bin/activate

# Install GDToolkit in virtual environment
pip install gdtoolkit

# Verify installation
gdlint --version
gdformat --version
gddoc --version

# Deactivate when done
deactivate
```

### Method 3: Git Submodule Installation (For Version Control)

```bash
# Navigate to project root
cd c:/github/project-antares

# Add GDUnit4 as a submodule (since we're using GDUnit4, not just GDToolkit)
git submodule add https://github.com/MikeSchulze/gdUnit4 addons/gdUnit4

# Initialize and update submodule
git submodule init
git submodule update

# Install GDToolkit for linting/formatting
pip install gdtoolkit
```

### Method 4: Manual Download

#### Windows
```powershell
# Download latest release
curl -L https://github.com/Scony/godot-gdscript-toolkit/releases/latest/download/gdtoolkit-windows.zip -o gdtoolkit.zip

# Extract
Expand-Archive -Path gdtoolkit.zip -DestinationPath .

# Add to PATH or copy executables to project directory
```

#### macOS/Linux
```bash
# Download latest release
wget https://github.com/Scony/godot-gdscript-toolkit/releases/latest/download/gdtoolkit-linux.tar.gz -O gdtoolkit.tar.gz

# Extract
tar -xzf gdtoolkit.tar.gz

# Add to PATH or copy executables to project directory
```

## Configuration Files

### .gdlint Configuration
Already created in project root with Project Antares specific rules.

### .gdformat Configuration  
Already created in project root with Project Antares specific formatting rules.

### project_antares.gdlint Configuration
Already created with advanced Project Antares specific configurations.

## IDE Integration

### Visual Studio Code
1. Install the **Godot Tools** extension
2. Install the **GDScript Language Server** extension
3. Configure settings in `.vscode/settings.json`:

```json
{
    "gdscript.lintOnSave": true,
    "gdscript.formatOnSave": true,
    "gdscript.linting.enabled": true,
    "gdscript.linting.configPath": ".gdlint",
    "gdscript.formatting.configPath": ".gdformat",
    "gdscript.languageServer.enabled": true,
    "gdscript.languageServer.port": 6008,
    "gdscript.debugger.enabled": true,
    "gdscript.debugger.port": 6007,
    "gdscript.autoReloadScripts": true,
    "gdscript.showWarnings": true,
    "gdscript.showErrors": true
}
```

### Sublime Text
1. Install **Package Control** if not already installed
2. Install **Godot GDScript** package
3. Configure in `Preferences > Package Settings > Godot GDScript`:

```json
{
    "lint_on_save": true,
    "format_on_save": true,
    "gdlint_args": ["--config", ".gdlint"],
    "gdformat_args": ["--config", ".gdformat"],
    "show_warnings": true,
    "show_errors": true
}
```

### Vim/Neovim
1. Install **vim-godot** plugin
2. Add to `.vimrc` or `init.vim`:

```vim
" Godot GDScript support
Plug 'habamax/vim-godot'

" Enable linting and formatting
let g:godot_gdscript_lint_on_write = 1
let g:godot_gdscript_format_on_write = 1
let g:godot_gdscript_show_warnings = 1
let g:godot_gdscript_show_errors = 1

" Configure paths
let g:godot_gdscript_lint_config = '.gdlint'
let g:godot_gdscript_format_config = '.gdformat'
```

### Godot Editor Integration
1. Open Project Antares in Godot Editor
2. Go to **Editor > Editor Settings**
3. Navigate to **Text Editor > Files**
4. Enable **Auto Reload Scripts**
5. Navigate to **Text Editor > Completion**
6. Enable **Show Warnings** and **Show Errors**

## Pre-commit Hooks

### Install pre-commit
```bash
pip install pre-commit
```

### .pre-commit-config.yaml
Create this file in the project root:

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

### Install hooks
```bash
pre-commit install
```

## CI/CD Pipeline Integration

### GitHub Actions
Create `.github/workflows/gdscript-lint.yml`:

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
        run: |
          pip install gdtoolkit
          
      - name: Run GDScript Lint
        run: |
          gdlint --config .gdlint scripts/**/*.gd gamedata/**/*.gd managers/**/*.gd tests/**/*.gd || exit 1
          
      - name: Check GDScript Formatting
        run: |
          gdformat --check --config .gdformat scripts/**/*.gd gamedata/**/*.gd managers/**/*.gd tests/**/*.gd || exit 1
```

### GitLab CI
Create `.gitlab-ci.yml`:

```yaml
stages:
  - lint
  - test

gdlint:
  stage: lint
  image: python:3.9
  before_script:
    - pip install gdtoolkit
  script:
    - gdlint --config .gdlint scripts/**/*.gd gamedata/**/*.gd managers/**/*.gd tests/**/*.gd
    - gdformat --check --config .gdformat scripts/**/*.gd gamedata/**/*.gd managers/**/*.gd tests/**/*.gd
  only:
    - merge_requests
    - master
```

### Jenkins Pipeline
Create `Jenkinsfile`:

```groovy
pipeline {
    agent any
    stages {
        stage('GDScript Lint') {
            steps {
                sh '''
                    pip install gdtoolkit
                    gdlint --config .gdlint scripts/**/*.gd gamedata/**/*.gd managers/**/*.gd tests/**/*.gd
                    gdformat --check --config .gdformat scripts/**/*.gd gamedata/**/*.gd managers/**/*.gd tests/**/*.gd
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
gdlint --config .gdlint scripts/**/*.gd gamedata/**/*.gd managers/**/*.gd tests/**/*.gd

# Lint with verbose output
gdlint --config .gdlint --verbose scripts/**/*.gd

# Lint specific files
gdlint --config .gdlint scripts/managers/AIManager.gd scripts/managers/galaxymanager.gd
```

### Code Formatting
```bash
# Check formatting without modifying files
gdformat --config .gdformat --check scripts/**/*.gd

# Format files in-place
gdformat --config .gdformat scripts/**/*.gd

# Format specific files
gdformat --config .gdformat scripts/managers/DataManager.gd scripts/managers/EmpireManager.gd
```

### Documentation Generation
```bash
# Generate documentation for a single file
gddoc scripts/managers/AIManager.gd

# Generate documentation for all files
gddoc --config .gdlint scripts/**/*.gd > docs/api_reference.md
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

## Troubleshooting Common Issues

### 1. Installation Problems

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

### 2. Configuration Issues

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

### 3. IDE Integration Issues

#### Extension Not Working
```bash
# Restart Godot Editor
# Reinstall Godot Tools extension
# Check extension logs for errors
```

#### Linting Not Triggering
```bash
# Verify gdlint is in PATH
where gdlint

# Check IDE settings for linting configuration
# Ensure file associations are correct
```

### 4. Performance Issues

#### Slow Linting
```bash
# Limit file processing
gdlint --jobs 2 scripts/**/*.gd

# Process specific directories
gdlint scripts/managers/*.gd gamedata/empires/*.gd
```

#### Memory Issues
```bash
# Use smaller batch sizes
gdlint --batch-size 10 scripts/**/*.gd

# Process files in smaller groups
find scripts/ -name "*.gd" | head -n 50 | xargs gdlint
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

## Verification Steps

### 1. Installation Verification
```bash
# Verify all tools are installed
gdlint --version
gdformat --version
gddoc --version

# Test basic functionality
echo "extends Node" > test.gd
gdlint test.gd
gdformat --check test.gd
rm test.gd
```

### 2. Configuration Verification
```bash
# Test configuration files
gdlint --config .gdlint --check-config
gdformat --config .gdformat --check-config
```

### 3. Project Integration Verification
```bash
# Test on a few project files
gdlint scripts/managers/AIManager.gd
gdformat --check scripts/managers/galaxymanager.gd
```

## Support and Resources

### Getting Help
- **Documentation**: This comprehensive installation guide
- **Issue Tracker**: GitHub issues for GDToolkit problems
- **Community Forums**: Discussion boards for GDScript development
- **Development Chat**: Real-time support in Discord/Slack

### Learning Resources
- **GDToolkit GitHub Repository**: https://github.com/Scony/godot-gdscript-toolkit
- **Godot GDScript Style Guide**: https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/gdscript_styleguide.html
- **Project Antares Documentation**: `docs/README.md` and related files
- **GDScript Best Practices**: Industry-standard coding conventions

---

*Last Updated: September 26, 2025*
*Version: 1.0.0*
