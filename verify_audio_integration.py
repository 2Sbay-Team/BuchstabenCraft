from pathlib import Path
import json, re, subprocess, random
p=Path(__file__).resolve().parent
bank=json.loads((p/'questions_grade1.json').read_text())['questions']
manifest=json.loads((p/'audio_manifest.json').read_text())
s=(p/'main.gd').read_text()
assert len(bank)==898 and len({q['id'] for q in bank})==898
assert len(manifest)==1000
assert all((p/v).is_file() for v in manifest.values())
assert all(q['speech'] in manifest or q['speech'].lower() in manifest for q in bank)
listening={'listen_choose','listen_choose_word','count_syllables','write_from_audio'}
spoken={'choose_letter','math_choice','compare','story_math','count_objects','shape_identification','trace_letter'}
extra={'king_vowels'}
silent={'read_to_picture','read_sentence','copy_sentence'}
assert {q['mode'] for q in bank}==listening|spoken|extra|silent
assert 'return mode in ["listen_choose", "listen_choose_word", "count_syllables", "write_from_audio"]' in s
assert 'return mode in ["choose_letter", "math_choice", "compare", "story_math", "count_objects", "shape_identification", "trace_letter"]' in s
assert '_bank_queue_audio()' in s and 'func _bank_audio_for_question' in s
assert 'func _bank_audio()' in s and 'func _play_clip(' in s
print('PASS: 898/898 audio keys resolve; 1000/1000 audio files exist')
print('PASS: 12/15 exercise modes have intentional audio dispatch; 3 reading/copying modes stay silent')
print('NOTE: Static policy check only. Godot playback not executed.')
