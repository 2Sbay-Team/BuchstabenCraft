# BuchstabenCraft EXPERT V7 — Bugfix verification

## Confirmed fixes in source
- Fixed picture distractor tracking: dictionary is now indexed by the actual emoji value, not an identifier-shaped key.
- Stale deferred audio calls are invalidated by a generation counter when changing questions or leaving the mission.
- MP3 files can be decoded from bundled bytes using `AudioStreamMP3`, with resource loading fallback. This improves portability of dynamic paths but is not an Android playback test.
- Audio stops on submission and navigation.
- Shape tasks now show shape symbols.
- Retained the 945 questions, 1,000 MP3s, pets and progress format.

## Executed checks
- Three bundled Python checks passed, including 300,000 simulated question selections.
- Ten additional source/data assertions passed.
- Audio manifest: all 945 question speech keys resolve and all 1,000 referenced files exist.
- ZIP integrity checked.

## Still unverified
- Godot compiler/runtime, real MP3 playback, Android APK, Xiaomi stylus and frame rate.
- Natural German pronunciation, especially phoneme accuracy, needs human review.
- No cinematic Roblox-like 3D gameplay, no automatic handwriting recognition.

**Status: source-level bugfix candidate, not an approved Android release.**
