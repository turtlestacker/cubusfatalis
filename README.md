# CubusFatalis — First Playable Demo (Godot 4)

This demo is now Godot-native and includes a **4-view layout**:
- 1 large perspective gameplay view
- 3 lower orthographic aligned views (X, Y, Z)

## Run

1. Install **Godot 4.6.x** (or current 4.x stable).
2. Open this repository as a Godot project (contains `project.godot`).
3. Run the main scene (`res://godot/scenes/Main.tscn`).

## Controls (discrete / grid-step movement)

Movement is **discrete**, one unit per key press (Tetris-like stepping):
- `A / D`: `-X / +X`
- `R / F`: `+Y / -Y`
- `W / S`: `+Z / -Z`
- `B`: boost (sheds one legal surface cube)

## Current demo scope

- Bounded 3D arena
- Player voxel-body starter shape
- Passive drifting NPMCs
- Consume gating by size + harmonic compatibility
- 12 major/minor harmonic compatibility checks
- Last-4-unique-note harmonic window
- Metabolism attrition (`24 / sqrt(volume)`)
- Contextual edible-vs-washed coloring
- HUD with resolved key, recent notes, score, volume, nearby entities
