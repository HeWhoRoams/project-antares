# Project Antares - Comprehensive Debugging Guide

## Overview
This guide provides detailed debugging strategies for identifying and resolving the critical errors currently preventing proper CI/CD pipeline execution in Project Antares.

## Common Error Patterns and Solutions

### 1. Parse Errors ("Expected statement, found 'Indent' instead")
**Symptoms:**
- "Expected statement, found 'Indent' instead" errors
- Incorrect indentation in GDScript files
- Compilation failures in specific lines

**Debugging Steps:**
1. **Visual Inspection**: Open the problematic file and check line indentation
2. **Consistent Spacing**: Ensure all indentation uses either spaces OR tabs consistently
3. **Block Alignment**: Verify that all code blocks are properly aligned
4. **Match Statement Check**: Ensure all match cases are properly indented at the same level

**Solution Example:**
```gdscript
# INCORRECT INDENTATION
match variable:
    VALUE_A:
        do_something()
    _:  # This line is misaligned
do_other_thing()  # This line is also misaligned

# CORRECT INDENTATION  
match variable:
    VALUE_A:
        do_something()
    _:  # Properly aligned with other cases
        do_other_thing()
```

### 2. Missing Class Definitions ("Could not find type 'ClassName'")
**Symptoms:**
- "Could not find type 'Empire' in the current scope"
- "Identifier 'TechnologyEffectManager' not declared in the current scope"  
- "Could not resolve external class member 'get_empire_by_id'"

**Debugging Steps:**
1. **Verify Class Existence**: Check if the class file exists in the expected location
2. **Check Class Names**: Ensure class_name declarations match expected names
3. **Validate Preload Statements**: Confirm proper preload paths are used
4. **Check Import Order**: Ensure dependencies are loaded before usage

**Solution Example:**
```gdscript
# ADD MISSING PRELOAD STATEMENTS
const Empire = preload("res://gamedata/empires/empire.gd")
const TechnologyEffectManager = preload("res://scripts/managers/TechnologyEffectManager.gd")

# VERIFY CLASS FILE EXISTS AND HAS PROPER DECLARATION
# File: res://gamedata/empires/empire.gd
class_name Empire
extends Resource
```

### 3. Script Loading Failures ("Failed to load script")
**Symptoms:**
- "Failed to load script 'res://scripts/managers/galaxymanager.gd' with error 'Parse error'"
- "Script 'res://scripts/managers/AIManager.gd' does not inherit from 'Node'"
- Multiple cascading script loading failures

**Debugging Steps:**
1. **Check Script Dependencies**: Identify which scripts depend on failing scripts
2. **Validate Inheritance**: Ensure scripts inherit from proper base classes
3. **Verify Syntax**: Check for parse errors in the failing script
4. **Check Resource Paths**: Confirm all resource paths are correct

**Solution Example:**
```gdscript
# ENSURE PROPER INHERITANCE
# File: res://scripts/managers/AIManager.gd
extends Node  # Must extend Node or appropriate base class

# CHECK FOR PARSE ERRORS IN DEPENDENCIES
# Fix any syntax errors before addressing dependent scripts
```

### 4. Autoload Failures ("Failed to instantiate an autoload")
**Symptoms:**
- "Failed to instantiate an autoload, script does not inherit from 'Node'"
- Core managers fail to initialize
- Game systems don't load properly

**Debugging Steps:**
1. **Check Autoload Configuration**: Verify scripts are properly configured in project settings
2. **Validate Script Structure**: Ensure autoload scripts have proper structure
3. **Check for Circular Dependencies**: Look for scripts that depend on each other
4. **Verify Singleton Pattern**: Ensure autoloads follow singleton patterns correctly

## Detailed Error Analysis Framework

### Phase 1: Pre-flight Validation
```batch
@echo [PHASE 1] Pre-flight Validation
@echo ================================
@echo Checking Godot executable...
if not exist %GODOT_PATH% (
    echo ERROR: Godot executable not found
    exit /b 1
)

@echo Checking project structure...
if not exist "project.godot" (
    echo ERROR: Not a valid Godot project
    exit /b 1
)
```

### Phase 2: Resource Dependency Mapping
Create a dependency map to understand script relationships:
```python
# PSEUDO-CODE FOR DEPENDENCY ANALYSIS
dependencies = {
    "galaxymanager.gd": ["CelestialBodyGenerator.gd", "GalaxyBuilder.gd", "SystemNameGenerator.gd"],
    "AIManager.gd": ["Empire.gd", "AIDecisionWeights.gd", "ColonyData.gd", "BuildingData.gd"],
    "DataManager.gd": ["Technology.gd", "JSON.gd"],
    # ... map all dependencies
}

# Validate dependencies exist and load properly
for script, deps in dependencies.items():
    for dep in deps:
        if not file_exists(dep):
            log_error(f"Missing dependency: {dep} required by {script}")
```

### Phase 3: Class Resolution Verification
```batch
@echo [PHASE 3] Class Resolution Verification  
@echo ======================================
@echo Checking essential class definitions...

REM Verify core classes exist and are properly defined
for %%class in (Empire Technology ShipData PlanetData StarSystem GalaxyBuilder) do (
    if not exist "res://gamedata/**/*.gd" (
        echo WARNING: Core class %%class may be missing
    ) else (
        findstr /C:"class_name %%class" "res://gamedata/**/*.gd" > nul
        if errorlevel 1 (
            echo ERROR: Class %%class defined but not properly declared
        )
    )
)
```

## Advanced Debugging Techniques

### 1. Verbose Logging Strategy
Enable detailed logging to capture all error information:
```batch
REM Run with maximum verbosity
%GODOT_EXECUTABLE% --verbose --debug --headless -s script.gd 2>&1 | tee debug_output.log

REM Filter specific error patterns
findstr /C:"Parse Error" debug_output.log > parse_errors.log
findstr /C:"Failed to load" debug_output.log > load_failures.log  
findstr /C:"Could not find" debug_output.log > missing_classes.log
```

### 2. Dependency Chain Analysis
Create a script to analyze dependency chains:
```python
def analyze_dependency_chain(start_script):
    """Analyze the complete dependency chain for a script"""
    chain = []
    visited = set()
    
    def traverse(script_path):
        if script_path in visited:
            return f"Circular dependency detected: {script_path}"
        
        visited.add(script_path)
        chain.append(script_path)
        
        # Find all preload statements
        with open(script_path, 'r') as f:
            content = f.read()
            
        preloads = re.findall(r'preload\("([^"]+)"\)', content)
        for preload_path in preloads:
            if os.path.exists(preload_path):
                traverse(preload_path)
    
    traverse(start_script)
    return chain
```

### 3. Error Pattern Recognition
Implement pattern recognition for common error types:
```batch
REM Parse error detection
findstr /C:"Parse Error:" ci_output.log > parse_errors.tmp
for /f %%i in (parse_errors.tmp) do (
    echo DETECTED: Parse error in %%i
    call :analyze_parse_error "%%i"
)

:analyze_parse_error
set error_line=%~1
echo ANALYZING: %error_line%
REM Extract file and line number
for /f "tokens=1,2 delims=:" %%a in ("%error_line%") do (
    set error_file=%%a
    set error_line_num=%%b
    echo FILE: %error_file% LINE: %error_line_num%
)
goto :eof
```

## Systematic Resolution Approach

### Step 1: Critical Path Analysis
Identify the most critical scripts that block others:
1. **Core Managers**: DataManager.gd, EmpireManager.gd, GalaxyManager.gd
2. **Base Classes**: Technology.gd, Empire.gd, PlanetData.gd
3. **Utility Scripts**: AssetLoader.gd, JSON parsing utilities

### Step 2: Dependency Resolution
Resolve dependencies in proper order:
1. **Foundation Classes**: Create/fix base resource classes first
2. **Core Managers**: Ensure manager scripts load properly  
3. **Game Systems**: Fix gameplay system scripts
4. **UI Components**: Address user interface scripts last

### Step 3: Incremental Testing
Test fixes incrementally:
```batch
REM Test individual script compilation
%GODOT_EXECUTABLE% --headless -s res://scripts/managers/DataManager.gd --check-only

REM Test core manager loading
%GODOT_EXECUTABLE% --headless -s res://scripts/managers/EmpireManager.gd --check-only

REM Test full system initialization
%GODOT_EXECUTABLE% --headless --import
```

## Common Resolution Patterns

### Pattern 1: Missing Preload Statements
```gdscript
# BEFORE (causing errors)
func _ready():
    var empire = Empire.new()  # Error: Empire not found

# AFTER (fixed)
const Empire = preload("res://gamedata/empires/empire.gd")

func _ready():
    var empire = Empire.new()  # Now works
```

### Pattern 2: Incorrect Inheritance
```gdscript
# BEFORE (causing autoload failure)
class_name GalaxyManager
# Missing extends Node

# AFTER (fixed)  
class_name GalaxyManager
extends Node
```

### Pattern 3: Circular Dependencies
```gdscript
# BEFORE (circular dependency)
# File A.gd imports B.gd
# File B.gd imports A.gd

# SOLUTION: Use signal-based communication or dependency inversion
# File A.gd
signal data_updated(data)

# File B.gd  
func _on_A_data_updated(data):
    # Handle data without direct import
```

## Monitoring and Prevention

### Continuous Integration Checks
Add these checks to prevent regression:
```batch
REM Pre-commit hook validation
@echo Running pre-commit validation...
call :validate_script_structure
call :validate_class_definitions  
call :validate_dependencies
call :validate_inheritance

:validate_script_structure
REM Check for common syntax issues
findstr /R /C:"^ *" *.gd | findstr /C:"^[[:space:]]*$" > nul
if %errorlevel% equ 0 (
    echo WARNING: Potential indentation issues found
)
goto :eof
```

### Automated Error Detection
Create a monitoring script:
```python
#!/usr/bin/env python3
"""
Automated error detection for Project Antares CI/CD pipeline
"""

import re
import os
import sys
from pathlib import Path

class ErrorDetector:
    def __init__(self, log_file):
        self.log_file = log_file
        self.errors = []
        
    def detect_parse_errors(self):
        """Detect parse errors in GDScript files"""
        pattern = r'Parse Error: (.+) at: GDScript::reload \((.+):(\d+)\)'
        return self._find_pattern(pattern)
        
    def detect_missing_classes(self):
        """Detect missing class definitions"""  
        pattern = r"Could not find type '(.+)' in the current scope"
        return self._find_pattern(pattern)
        
    def detect_script_failures(self):
        """Detect script loading failures"""
        pattern = r'Failed to load script "(.+)" with error "(.+)"'
        return self._find_pattern(pattern)
        
    def _find_pattern(self, pattern):
        """Helper to find patterns in log file"""
        matches = []
        with open(self.log_file, 'r') as f:
            content = f.read()
            matches = re.findall(pattern, content)
        return matches
        
    def generate_report(self):
        """Generate comprehensive error report"""
        report = {
            'parse_errors': self.detect_parse_errors(),
            'missing_classes': self.detect_missing_classes(), 
            'script_failures': self.detect_script_failures(),
            'total_errors': 0
        }
        
        report['total_errors'] = (len(report['parse_errors']) + 
                                 len(report['missing_classes']) +
                                 len(report['script_failures']))
                                 
        return report

# Usage
if __name__ == "__main__":
    detector = ErrorDetector("ci_output.log")
    report = detector.generate_report()
    
    print("=== PROJECT ANTARES ERROR DETECTION REPORT ===")
    print(f"Total Critical Errors: {report['total_errors']}")
    
    if report['parse_errors']:
        print("\nParse Errors:")
        for error in report['parse_errors']:
            print(f"  - {error}")
            
    if report['missing_classes']:
        print("\nMissing Classes:")  
        for cls in report['missing_classes']:
            print(f"  - {cls}")
            
    if report['script_failures']:
        print("\nScript Failures:")
        for failure in report['script_failures']:
            print(f"  - {failure}")
```

## Best Practices for Future Development

### 1. Script Organization
- **Modular Design**: Keep scripts focused on single responsibilities
- **Clear Dependencies**: Document and minimize cross-script dependencies  
- **Proper Inheritance**: Use inheritance hierarchies appropriately

### 2. Error Handling
- **Graceful Degradation**: Handle missing dependencies gracefully
- **Descriptive Errors**: Provide clear error messages for debugging
- **Validation Layers**: Add validation at multiple levels

### 3. Testing Strategy
- **Unit Tests First**: Write tests for core functionality early
- **Integration Testing**: Test script interactions thoroughly
- **Regression Prevention**: Add tests for fixed bugs

### 4. Documentation
- **Dependency Maps**: Maintain current dependency documentation
- **Error Resolution Guides**: Document solutions for common errors
- **Best Practices**: Keep coding standards updated

This comprehensive debugging approach will help systematically identify and resolve the current CI/CD pipeline issues while establishing better practices for future development.
