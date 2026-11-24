# Neon Survivor — Godot migration

This is a separate Godot 4.4.1 / GDScript migration target for the V3.5 Python/Pygame source. The existing Python game and the repository's `main` branch are preserved.

## Porting scope

The Godot implementation is intended to cover the original game's five ships, four enemy classes, four difficulty profiles, stage/subwave progression, boss fights, seven power-ups, weapon patterns, dash, touch controls, score/combo, credits, ship unlocks, achievements, settings, save data, procedural visuals, particles and sound.

## Open locally

Open the `godot/` folder in Godot 4.4.1 or newer and run `main.tscn`.

## Android APK

The `.github/workflows/android-godot.yml` workflow builds an arm64 APK on pushes to `godot-v3.5-migration` and on manual dispatch. Download the `NeonSurvivor-Android` artifact from the Actions run.

## Validation status

The port still requires a Godot editor parse/runtime run and side-by-side gameplay verification. Do not consider it feature-parity complete until those checks pass.
