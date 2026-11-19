# Neon Survivor — Android

A touch-first Android adaptation of the supplied **NEON SURVIVOR** Pygame prototype.

## Play
- Drag on the left half of the screen to move.
- Tap the right half to dash.
- The game auto-targets the nearest enemy and fires automatically.
- Collect shield, triple-shot and nova power-ups.
- Tap the screen to start/restart; use the pause button in the top-right.

## Project layout
- `main.py`: Kivy application shell and Android back-key handling.
- `game.py`: gameplay, enemies, collision, effects, HUD and touch controls.
- `buildozer.spec`: Android package/build configuration.
- `.github/workflows/android.yml`: CI build for a release Android App Bundle.

## Build
The GitHub Actions workflow builds a release AAB on pushes to `main` or manually from Actions. Download the generated artifact from the workflow run.

For local builds, install Buildozer and run:
```bash
buildozer android debug
buildozer android release
```

## Google Play checklist
Before production submission:
1. Set a unique permanent application ID in `buildozer.spec`.
2. Configure a secure upload keystore and signing credentials; never commit them.
3. Verify the target API level against the current Play Console requirement.
4. Test on multiple Android devices, including touch, pause/resume, audio, performance and saved records.
5. Prepare store listing, privacy policy (if applicable), screenshots, icon and content rating.
6. Upload the signed AAB to an internal testing track before production.

This repository provides the game source and CI packaging workflow; a successful build alone does not guarantee Play Store approval.
