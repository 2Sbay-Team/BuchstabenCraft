# EXPERT V9 Remediation and double audit

## Source and scope
Derived from the actual V8 Godot project. No new 3D mockup is represented as playable.

## Critical issues addressed
1. **Semantic duplicates:** removed 47 duplicate records (same mode, prompt, answer and metadata) from the active bank. Active bank now has 898 distinct records with unique IDs. Original duplicate records preserved in `duplicates_removed.json` for audit. All three regression scripts and headless smoke expected count updated.
2. **Unbounded visible pets:** render cap of 8 pets while preserving the complete owned-pet collection in saved progress.
3. **Progress recovery:** save to temporary file, back up previous valid file, rename into place, and load backup if the primary JSON is missing or invalid. This is more resilient than direct overwrite; atomicity and Android filesystem behavior remain untested.
4. **Reward equity:** both correct and incorrect completed responses earn egg-energy participation credit. Manual-review outcomes also earn participation credit, while correctness metrics remain separate.
5. **Audio/data preservation:** 1,000 referenced MP3s retained, all active question speech keys resolve.
6. **Regression maintenance:** scripts updated to expect 898 active questions rather than 945.

## Verification performed
- Three Python regression suites executed successfully in container.
- 300,000 simulated selections pass.
- 898 unique active IDs and 0 semantic duplicate keys.
- 1,000 referenced MP3s present.
- ZIP CRC integrity checked.
- Additional invariants verified for pet cap, backup and reward source paths.

## Not fixed / not proven
- No Godot binary was found in the available environment. Godot parser, scene load and real gameplay are **not verified**.
- No Android SDK/export templates and no Xiaomi device test; **no APK**.
- Full cinematic Roblox-style 3D worlds, collision-based obstacle/racing/shop gameplay, animations and performance remain unimplemented.
- Handwriting recognition and palm rejection remain unimplemented.
- German phoneme and synthetic speech quality remain unreviewed by a native-speaker educator.
- 898 active questions are not a proof of full ANTON or Zebra curriculum coverage.

## EXPERT decision
**DATA/STATIC: PASS. GODOT/ANDROID/GAMEPLAY: NO-GO pending actual execution.**
