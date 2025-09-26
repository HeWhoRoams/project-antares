rules:
  - Always generate valid, typed GDScript compatible with Godot 4.x.
  - Never introduce undocumented global variables or singletons.
  - Every class or function you propose must include a minimal unit test using GUT.
  - Ensure style compliance: snake_case for variables/functions, PascalCase for classes.
  - Avoid unnecessary performance costs: prefer signals, avoid deep nesting in _process(), and cache nodes.
  - Validate integration: if code depends on another file, mock or stub interactions in test coverage.
