# OpenSCAD Agent

This project provides Claude Code skills for creating and iterating on OpenSCAD 3D models.

## Available Skills

### `/openscad` - Create Versioned 3D Models

Creates versioned OpenSCAD files with automatic version numbering and preview rendering.

**Workflow:**
1. Use `version-scad.sh <name>` to find the next version number
2. Write the .scad file with that version (e.g., `piano_001.scad`)
3. Render to PNG with matching version (e.g., `piano_001.png`)
4. Compare with previous versions to evaluate changes
5. Iterate until the design meets requirements

### `/preview-scad` - Render OpenSCAD to PNG

Renders .scad files to PNG images for visual verification.

## File Naming Convention

```
<model-name>_<version>.scad  ->  <model-name>_<version>.png
```

- Use underscores in model names
- Use 3-digit zero-padded version numbers (001, 002, etc.)
- Each .scad file gets a matching .png preview

Examples:
- `phone_stand_001.scad` -> `phone_stand_001.png`
- `gear_002.scad` -> `gear_002.png`

## Iterative Design Process

When creating 3D models:

1. **Start simple** - Create a basic version first
2. **Render and inspect** - Always preview after changes
3. **Compare versions** - Read both current and previous PNGs to see what changed
4. **Document changes** - Tell the user what improved between versions
5. **Iterate** - Keep refining until the design matches requirements

## OpenSCAD Tips

- Use `$fn` to control curve smoothness (higher = smoother, slower)
- Use `module` to create reusable components
- Use `difference()` to subtract shapes, `union()` to combine
- Use `translate()`, `rotate()`, `scale()` for positioning
- Add tolerances (0.2-0.5mm) for parts that need to fit together
