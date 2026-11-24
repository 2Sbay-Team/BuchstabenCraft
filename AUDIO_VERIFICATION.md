# BuchstabenCraft EXPERT V5 — Audio coverage

- Previously unmatched question prompts: **745 / 945**.
- Newly generated distinct German speech clips: **621**.
- Existing audio clips retained: **379**.
- Total audio manifest keys: **1000**.
- Remaining unmatched question prompts: **0**.
- Missing manifest audio files: **0**.
- Generated MP3 files checked for nonempty output: **621/621**.
- Random sample of 12 generated MP3s passed ffprobe decoding/duration inspection: **12/12**.
- ZIP integrity: verified after packaging.

## Voice
Generated locally using **eSpeak German with feminine voice variant (`de+f3`)**, speed 135 words/minute, encoded as 48-kbps mono MP3. This is a robotic, synthetic voice, **not a studio-quality German female voice**. No native-speaker pronunciation review has been performed. German phonemes and letter sounds, especially single letters and syllables, must be reviewed before independent child use.

## What this fixes
Every question's `speech` key now resolves to a physical MP3. The existing Godot `_bank_audio()` uses the manifest to load the sound. Actual in-engine playback has not been tested.

## What this does not fix
Godot compilation, Android APK export, Xiaomi stylus, 3D mockup parity, handwriting recognition, and audio pronunciation accuracy. Those remain open release blockers.
