# BuchstabenCraft V10 — work completed and verification

## Actual source changes
- Pre-indexed 898 tasks by world to avoid repeated full-bank scans on each selection.
- Corrected exploration transition to clear movement and stop audio.
- Writing pad suppresses Android's duplicate touch-to-mouse input for 350 ms and bounds stroke point counts; **not full palm rejection**.
- Save backup now copies only valid JSON rather than potentially replacing a good backup with corrupted data.
- Pets: cap 8 rendered followers and 250 stored pets; egg restored when collection is full.
- Added engine smoke test covering 15 exercise modes, audio MP3 stream load, save/load round trip and exploration.
- Moved Godot CI workflow to `.github/workflows/godot-smoke.yml` at project root.

## Executed locally
- `python verify_static.py` PASS (898 unique tasks, 300,000 selection simulations).
- `python verify_v3.py` PASS.
- `python verify_audio_integration.py` PASS (898/898 audio mappings; 1000/1000 MP3 files).
- ZIP CRC check PASS.

## Not executed / release blockers
- Godot 4.4.1 not available; DNS access to download host failed. **No actual GDScript compilation or gameplay run.**
- GitHub Actions workflow added but NOT run in this environment.
- Android SDK and export templates not available; **no APK built**.
- Xiaomi Pad 8 Pro touch/stylus and FPS not tested.
- Full Roblox-style cinematic 3D worlds, independent handwriting assessment, German audio pronunciation review and full Grade 1 curriculum completeness not delivered.

## Next gate
Run `.github/workflows/godot-smoke.yml` in a repository with GitHub Actions, resolve actual parser errors if any, then Android export and on-device validation. Do not label this as finished.
