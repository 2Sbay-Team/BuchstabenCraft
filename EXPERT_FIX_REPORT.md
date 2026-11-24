# EXPERT Fix V2 — verification

## Corrected
- No longer pretends a word-to-picture task has a picture: it is explicitly a parent-checked word-meaning task until artwork is supplied.
- Displays sentence text for reading and copying, and a letter model for tracing.
- Shows syllable segmentation for vowel-marking activities.
- Manual work requires adult judgment: correct, needs practice, or unverified. No automatic mastery for merely drawing.
- Generates answer choices for the 21 counting tasks whose JSON options are null. This avoids a runtime `.duplicate()` call on null.
- Makes the task panel responsive and scrollable to reduce content clipping.
- Keeps all 945 tasks, 379 MP3 files, pets, saved progress, and mission menu.
- Missing audio remains clearly labeled as requiring an adult; it is NOT falsely counted as fixed.

## Tests performed
`python verify_static.py`: PASS. 945 unique IDs, one world each, 379 audio files present, option checks and 300,000 selection simulations.

## Outstanding release blockers
- Godot runtime/parser was unavailable; Godot syntax and gameplay have NOT been executed.
- 745 question prompts do not match an existing MP3; adult read-aloud is required.
- The 40 former picture-matching tasks still lack licensed illustrations. Their current interaction is an explicitly labeled adult-assisted vocabulary exercise.
- Tracing shows a reference letter, not directional stroke-by-stroke tracking or handwriting recognition.
- Real Xiaomi Android stylus/palm rejection, FPS, audio playback and persistence remain untested.
- Current game world remains a prototype rather than the cinematic mockup.

Release status: NOT READY FOR FINAL APK.
