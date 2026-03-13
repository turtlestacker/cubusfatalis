# CubusFatalis — First Playable Demo (Godot 4)

You are right: the spec + tech stack target **Godot 4** for the first playable.
This repository now includes a Godot-native first demo.

## Run

1. Install **Godot 4.x**.
2. Open this repository as a Godot project (it contains `project.godot`).
3. Run the main scene (`res://godot/scenes/Main.tscn`).

## Current demo scope

- 3D bounded arena
- player voxel-body starter shape
- passive drifting NPMCs
- consume gating by size + harmonic compatibility
- 12 major/minor harmonic compatibility checks
- last-4-unique-note harmonic window
- metabolism attrition (`24 / sqrt(volume)`)
- boost action with cube shedding
- contextual edible-vs-washed coloring
- HUD with resolved key, recent notes, score, volume, and nearby targets

## Controls

- `W/A/S/D`: move on X/Z
- `R/F`: move up/down (Y)
- `B`: boost (sheds legal surface cube)
