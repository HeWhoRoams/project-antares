# 🛰️ CLINE Rules & Workflows for Godot Game Development

This document defines rules and best practices for AI-assisted development in **Godot**, targeting a cross-platform game (Windows, iOS, Android). It ensures clean code, reliable behavior, strong testing discipline, and consistent UI/UX.  

---

## ⚙️ Code Standards & Quality
- All scripts must follow Godot’s [GDScript style guide](https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/gdscript_styleguide.html).  
- All code must adhere to the Godot engine and class documentation [Godot Docs](https://docs.godotengine.org/en/stable/index.html)
- Functions must be small, single-responsibility, and named descriptively.  
- Signals and autoloads must be documented at their declaration point.  
- No “magic numbers”: use constants or configuration files.  
- Error handling must be explicit; no silent failures.  

---

## 🧪 Unit Testing Rules
- Every non-trivial function must have at least one unit test.  
- Tests must run with Godot’s **GUT** (Godot Unit Test) or equivalent.  
- Mocks/stubs should be used to isolate logic from rendering or networking.  
- Test edge cases, not just happy paths.  
- All PRs must include updated tests before merging.  

---

## 🔗 Integration & Functional Testing
- **Integration Tests** must validate interactions between scripts, e.g., AI logic + diplomacy UI.  
- **Functional Tests** must validate core gameplay features behave as expected:  
  - Races generate with correct attributes and ranges.  
  - Dialog generation reflects attribute values consistently.  
  - Treaty violations update trust and diplomacy state correctly.  
  - Player and AI fleets behave consistently across platforms.  
- Every feature should include at least one functional test case simulating a real player interaction.  
- Automated test runs must be part of the build workflow.  

---

## 🧩 Godot-Specific Rules
- Never access nodes with absolute paths (`$"/root/..."`); use relative or `get_node()` with constants.  
- Avoid deep node hierarchies; prefer composition over inheritance.  
- Autoload scripts must be treated as singletons and documented clearly.  
- Use signals instead of polling for state changes.  
- Always clean up timers, tweens, and coroutines when nodes are freed.  

---

## 🎨 UI, Themes & Visuals
- All UI elements must use **themes**, not hardcoded styles.  
- Layouts must use `Container` nodes (VBoxContainer, HBoxContainer, GridContainer, etc.) for responsiveness.  
- No absolute positioning unless unavoidable.  
- Fonts and UI scales must adjust automatically for desktop/mobile.  
- Use `Control`’s anchors and margins properly for adaptive layouts.  
- Support both light/dark themes if applicable.  
- All interactable elements must support keyboard, mouse, and touch.  

---

## 📱 Cross-Platform Compatibility
- File handling: use `res://` for resources, `user://` for saves.  
- Input: only through **InputMap**, never raw keycodes.  
- Touch UI: minimum 48px tap targets; no hover-only interactions.  
- Use `viewport` stretch mode with `keep` or `expand`; UI must scale to multiple resolutions.  
- Avoid assets unsupported on mobile (e.g., BMP, WAV uncompressed).  
- Always wrap platform-specific code in `if OS.get_name()`.  
- Test suspend/resume behavior for Android/iOS.  
- All text must be localizable (`TranslationServer`).  
- Networking: must support unstable connections; include reconnection logic.  

---

## 🧪 Functional Testing Scenarios (Examples)
1. **War Declaration Logic**  
   - AI with Aggression ≥ 8 must declare war within N turns of violation.  
   - AI with Patience ≤ 2 declares war immediately after repeated nagging.  

2. **Treaty Violation**  
   - Trust decreases by the correct banded amount.  
   - Vindictive AI remembers violation for ≥ 50 turns.  

3. **Attribute-driven Dialog**  
   - Eloquence 1–2 generates 2–3 word blunt messages.  
   - Eloquence 9–10 generates 20+ word ornate messages.  

4. **Cross-Platform UI**  
   - iOS notch-safe layout validated.  
   - Android back button returns to previous menu.  
   - Windows scaling handles 4K monitors.  

---

## 🚀 Build & Workflow Rules
- All builds must pass unit, integration, and functional tests.  
- Exported projects must be tested on all three targets (Windows, iOS, Android).  
- CI/CD pipeline must include:  
  - Static analysis (linting, unused variable checks).  
  - Automated test runs.  
  - Platform compatibility validation (file paths, input handling).  

---

This document ensures code consistency, gameplay integrity, and a unified look-and-feel across platforms, while reducing risk of regressions.  
