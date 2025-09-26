# Project Antares - Installation and Setup Guide

## Overview
This guide provides detailed instructions for installing and setting up all required tools and dependencies for Project Antares development, including GDScript Toolkit, Godot Engine, and CI/CD pipeline components.

## Prerequisites

### System Requirements
- **Operating System**: Windows 10/11, macOS 10.15+, or Ubuntu 20.04+/Debian 11+/Fedora 35+
- **RAM**: 8GB minimum (16GB recommended)
- **Storage**: 500MB free space for tools, 2GB+ for project assets
- **CPU**: Modern multi-core processor

### Required Software
1. **Python 3.7 or higher** with pip
2. **Git** for version control
3. **Godot Engine 4.0+** 
4. **Text Editor** (VSCode recommended)

## Installation Steps

### 1. Python Installation

#### Windows
```powershell
# Download Python from https://www.python.org/downloads/
# Or use Chocolatey:
choco install python

# Verify installation
python --version
pip --version
```

#### macOS
```bash
# Using Homebrew
brew install python

# Or download from https://www.python.org/downloads/mac-osx/
# Verify installation
python3 --version
pip3 --version
```

#### Linux (Ubuntu/Debian)
```bash
# Install Python and pip
sudo apt update
sudo apt install python3 python3-pip

# Verify installation
python3 --version
pip3 --version
```

#### Linux (CentOS/RHEL/Fedora)
```bash
# Install Python and pip
sudo dnf install python3 python3-pip  # Fedora
# or
sudo yum install python3 python3-pip  # CentOS/RHEL

# Verify installation
python3 --version
pip3 --version
```

### 2. Git Installation

#### Windows
```powershell
# Download from https://git-scm.com/download/win
# Or use Chocolatey:
choco install git

# Verify installation
git --version
```

#### macOS
```bash
# Using Homebrew
brew install git

# Or download from https://git-scm.com/download/mac
# Verify installation
git --version
```

#### Linux
```bash
# Ubuntu/Debian
sudo apt install git

# CentOS/RHEL/Fedora
sudo dnf install git  # Fedora
# or
sudo yum install git  # CentOS/RHEL

# Verify installation
git --version
```

### 3. Godot Engine Installation

#### Method 1: Download from Official Website
1. Visit [Godot Engine Downloads](https://godotengine.org/download/)
2. Download the latest stable version for your platform
3. Extract to `C:\Tools\` (Windows) or `/opt/godot/` (Linux) or `/Applications/` (macOS)

#### Method 2: Using Package Managers

##### Windows (Chocolatey)
```powershell
choco install godot
```

##### Windows (Scoop)
```powershell
scoop install godot
```

##### macOS (Homebrew)
```bash
brew install --cask godot
```

##### Linux (Snap)
```bash
sudo snap install godot --classic
```

##### Linux (Flatpak)
```bash
flatpak install flathub org.godotengine.Godot
```

#### Method 3: Manual Installation
```bash
# Windows
mkdir C:\Tools
curl -L https://github.com/godotengine/godot/releases/download/4.4.1-stable/Godot_v4.4.1-stable_win64.exe.zip -o godot.zip
unzip godot.zip -d C:\Tools\
ren C:\Tools\Godot_v4.4.1-stable_win64.exe godot.exe

# macOS
mkdir -p /Applications/Godot.app
curl -L https://github.com/godotengine/godot/releases/download/4.4.1-stable/Godot_v4.4.1-stable_macos.universal.zip -o godot.zip
unzip godot.zip -d /Applications/Godot.app/

# Linux
mkdir -p /opt/godot
curl -L https://github.com/godotengine/godot/releases/download/4.4.1-stable/Godot_v4.4.1-stable_linux.x86_64.zip -o godot.zip
unzip godot.zip -d /opt/godot/
chmod +x /opt/godot/Godot_v4.4.1-stable_linux.x86_64
```

### 4. GDScript Toolkit Installation

#### Using pip (Recommended)
```bash
# Install GDToolkit globally
pip install gdtoolkit

# Or install for current user only (if you don't have admin rights)
pip install --user gdtoolkit

# Verify installation
gdlint --version
gdformat --version
gddoc --version
```

#### Using Virtual Environment (Recommended for Projects)
```bash
# Create virtual environment
python -m venv gdtoolkit-env

# Activate virtual environment
# Windows:
gdtoolkit-env\Scripts\activate
# macOS/Linux:
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

#### From Source (Development Version)
```bash
# Clone repository
git clone https://github.com/Scony/godot-gdscript-toolkit.git
cd godot-gdscript-toolkit

# Install in development mode
pip install -e .

# Verify installation
gdlint --version
```

### 5. Project Antares Setup

#### Clone Repository
```bash
# Clone the repository
git clone https://github.com/HeWhoRoams/project-antares.git
cd project-antares

# Initialize submodules (if any)
git submodule init
git submodule update
```

#### Verify Project Structure
```bash
# Check essential directories
ls -la
# Should see:
# - project.godot
# - scripts/
# - gamedata/
# - tests/
# - addons/
# - assets/

# Verify Godot project file
cat project.godot | head -n 10
```

#### Install Project Dependencies
```bash
# Install GDToolkit for the project
pip install gdtoolkit

# Verify configuration files exist
ls -la .gdlint .gdformat project_antares.gdlint
```

### 6. IDE Configuration

#### Visual Studio Code (Recommended)

##### Install Extensions
1. **Godot Tools** - Official Godot extension
2. **GDScript Language Server** - Language support
3. **GDScript Toolkit** - Linting and formatting support

##### Configure Settings
```json
// .vscode/settings.json
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

##### Configure Tasks
```json
// .vscode/tasks.json
{
    "version": "2.0.0",
    "tasks": [
        {
            "label": "Run CI/CD Pipeline",
            "type": "shell",
            "command": "./enhanced_run_ci.bat",
            "group": "build",
            "presentation": {
                "echo": true,
                "reveal": "always"
            },
            "problemMatcher": "$gdscript"
        },
        {
            "label": "Run GDScript Lint",
            "type": "shell",
            "command": "gdlint",
            "args": ["--config", ".gdlint", "scripts/**/*.gd", "gamedata/**/*.gd", "managers/**/*.gd", "tests/**/*.gd"],
            "group": "build",
            "presentation": {
                "echo": true,
                "reveal": "always"
            },
            "problemMatcher": "$gdscript"
        },
        {
            "label": "Format GDScript Files",
            "type": "shell",
            "command": "gdformat",
            "args": ["--config", ".gdformat", "scripts/**/*.gd", "gamedata/**/*.gd", "managers/**/*.gd", "tests/**/*.gd"],
            "group": "build",
            "presentation": {
                "echo": true,
                "reveal": "always"
            }
        }
    ]
}
```

##### Configure Launch
```json
// .vscode/launch.json
{
    "version": "0.2.0",
    "configurations": [
        {
            "name": "Launch Project Antares",
            "type": "godot",
            "request": "launch",
            "project": "${workspaceFolder}",
            "godotExecutable": "C:\\Tools\\godot.exe"
        },
        {
            "name": "Run Tests",
            "type": "godot",
            "request": "launch",
            "project": "${workspaceFolder}",
            "godotExecutable": "C:\\Tools\\godot.exe",
            "args": ["--headless", "-s", "res://addons/gut/gut_cmdln.gd", "-gdir=res://tests", "-gexit=true"]
        }
    ]
}
```

#### Sublime Text

##### Install Package Control
1. Press `Ctrl+Shift+P` (Windows/Linux) or `Cmd+Shift+P` (macOS)
2. Type "Install Package Control"
3. Press Enter

##### Install Packages
1. Press `Ctrl+Shift+P` (Windows/Linux) or `Cmd+Shift+P` (macOS)
2. Type "Package Control: Install Package"
3. Install:
   - **Godot GDScript**
   - **GDScript Lint**
   - **GDScript Format**

##### Configure Settings
```json
// Preferences > Package Settings > Godot GDScript
{
    "lint_on_save": true,
    "format_on_save": true,
    "gdlint_args": ["--config", ".gdlint"],
    "gdformat_args": ["--config", ".gdformat"],
    "show_warnings": true,
    "show_errors": true
}
```

#### Vim/Neovim

##### Install Plugins
```vim
" .vimrc or init.vim
Plug 'habamax/vim-godot'
Plug 'scony/godot-gdscript-toolkit.vim'

let g:godot_gdscript_lint_on_write = 1
let g:godot_gdscript_format_on_write = 1
let g:godot_gdscript_show_warnings = 1
let g:godot_gdscript_show_errors = 1
```

### 7. Pre-commit Hooks Setup

#### Install pre-commit
```bash
pip install pre-commit
```

#### Create .pre-commit-config.yaml
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

#### Install Hooks
```bash
pre-commit install
```

### 8. CI/CD Pipeline Configuration

#### GitHub Actions
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
          gdlint --config .gdlint scripts/**/*.gd gamedata/**/*.gd managers/**/*.gd tests/**/*.gd || exit 1
          
      - name: Check GDScript Formatting
        run: |
          gdformat --check --config .gdformat scripts/**/*.gd gamedata/**/*.gd managers/**/*.gd tests/**/*.gd || exit 1
```

#### GitLab CI
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
    - gdlint --config .gdlint scripts/**/*.gd gamedata/**/*.gd managers/**/*.gd tests/**/*.gd
    - gdformat --check --config .gdformat scripts/**/*.gd gamedata/**/*.gd managers/**/*.gd tests/**/*.gd
  only:
    - merge_requests
    - master
```

#### Jenkins Pipeline
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
