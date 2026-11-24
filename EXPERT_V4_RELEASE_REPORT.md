# EXPERT V4 critical remediation (2026-11-22)

## Source changes
1. **Confirmed blocker:** `write_pad.gd` contained the literal text `class_name WritePad\\nextends Control` on one line. This is now two proper GDScript lines.
2. Replaced the 40 misleading `read_to_picture` adult-only exercises with interactive four-choice pictogram matching. The 40 source words all have an assigned pictogram. Pictograms are temporary, and some concepts (Mama/Mami/Tante, Tomate/Tomaten) share the same symbol. Distractors are guaranteed to have different symbols. This is **not equivalent to a validated illustrated vocabulary exercise**.
3. Added interactive letter-position selection for the `king_vowels` mode. Every selected vowel position is compared to the actual vowel positions in the displayed word; only one scored submission is allowed.
4. Kept the adult-review requirement for handwriting. Neither handwriting recognition nor stroke order is claimed.
5. Kept explicit adult-read-aloud fallback when a matching recording is absent. The missing 745 recordings were **not** synthesized or claimed as fixed.
6. Preserved the 945-question bank, all 379 existing MP3s, pets and existing progress data format.

## Static verification performed
- 945 unique question IDs.
- 379 referenced MP3s all present.
- All 40 picture questions have pictogram mappings.
- Fixed literal newline in handwriting script.
- Vowel choice and scoring functions present.
- Archive CRC checked.

## Release blockers / limitations
- No Godot runtime in the environment, so this source has not been compiled or executed.
- No APK produced or Xiaomi touchscreen/stylus test.
- No production-grade Roblox-style 3D world. This remains a simple 3D prototype.
- 745 question prompts have no matching MP3, so many tasks require adult assistance.
- Pictograms are stand-ins, not actual 40 validated illustrations.
- Letter tracing still requires adult assessment; no automatic recognition.

Release status: **NO-GO** for final Android distribution.
