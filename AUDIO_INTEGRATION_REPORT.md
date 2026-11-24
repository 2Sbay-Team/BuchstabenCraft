# EXPERT V6: Audio integration repair

## Corrected
- Updated both regression scripts to expect 1,000 audio manifest entries, not 379.
- Added automatic and replayable audio for listening modes: `listen_choose`, `listen_choose_word`, `count_syllables`, `write_from_audio`.
- Added automatic and replayable spoken task instructions for `choose_letter`, `math_choice`, `compare`, `story_math`, `count_objects`, `shape_identification`, `trace_letter`.
- Added audio for `king_vowels` to support vowel listening without giving away the answer.
- Protected independent reading tasks: `read_to_picture`, `read_sentence`, `copy_sentence` do not automatically play recordings that might replace reading.
- Added deferred playback guard to avoid playing a previous question after rapid navigation.
- Stops audio on next bank question or return to lobby.

## Checks
Run `python verify_static.py` and `python verify_v3.py` to validate the bank and the updated 1,000-file manifest. The separate `verify_audio_integration.py` tests mode coverage and static dispatch policy.

## Important limitations
- This is **source-level integration**, not a runtime-verified Godot fix. Godot compilation and playback have not been tested in this environment.
- New speech is synthetic eSpeak, and German pronunciation still needs human review.
- Automatic narration for 12 of 15 exercise modes is intentional. The remaining 3 are independent-reading/copying modes and should not narrate the target.
- The simple 3D prototype is not the cinematic Roblox-like world. Android APK and Xiaomi stylus remain untested.
