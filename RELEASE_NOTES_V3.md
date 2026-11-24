# EXPERT Remediation V3

## Source fixes applied
- Typed handwriting controls using `class_name WritePad` and `WritePad.new()`, removing fragile dynamic-script method calls.
- Explicitly converted syllable metadata into `PackedStringArray` before joining it, avoiding a potentially incompatible `String.join(Array)` call.
- Added an adult-only read-aloud card for exercises whose recorded audio prompt is unavailable; it is clearly identified as adult-assisted, not self-contained.
- Retained adult assessment of reading and writing, with unverified attempts recorded separately.
- Preserved all 945 question records and all 379 MP3 files, existing progress storage and pet mechanics.

## Independent static verification
Run `python verify_v3.py`. It validates task IDs, question options, world assignment, audio file references, and 300000 simulated question selections.

## Unresolved blockers
- Godot binary unavailable in this environment. No parser, gameplay or APK execution was possible.
- 745 prompts still lack matching recorded audio keys; these are **not fixed** by the adult-assisted fallback.
- 40 original picture questions remain adult-assisted vocabulary reading tasks, not actual picture-choice exercises.
- No reliable handwriting recognition, stroke-order validation or Xiaomi stylus/palm-rejection test.
- 3D environments are a small prototype, not the cinematic mockup.

**Release decision: NO-GO until engine, Android and real-device testing.**
