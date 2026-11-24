import json,zipfile,pathlib,collections,random
root=pathlib.Path(__file__).parent
bank=json.loads((root/'questions_grade1.json').read_text())['questions']
manifest=json.loads((root/'audio_manifest.json').read_text())
code=(root/'main.gd').read_text()
assert len(bank)==898 and len({q['id'] for q in bank})==898
assert len(manifest)==1000 and all((root/v).is_file() for v in manifest.values())
worlds={'Lautlabor':['choose_letter','listen_choose','listen_choose_word','count_syllables','king_vowels','trace_letter','write_from_audio'],'Zahlenstadt':['math_choice','compare','story_math','count_objects','shape_identification'],'Kleine Stadt':['read_to_picture','read_sentence','copy_sentence']}
for q in bank:
    assert sum(q['mode'] in modes for modes in worlds.values())==1, q['id']
    opts=q.get('options')
    if isinstance(opts,list):
        assert str(q['answer']) in [str(x) for x in opts]
        assert len(opts)==len({str(x) for x in opts})
for world,modes in worlds.items():
    pool=[q for q in bank if q['mode'] in modes]
    last=[]
    for i in range(100000):
        choices=[q for q in pool if q['id'] not in last] or pool
        selected=random.choice(choices)
        assert selected['id'] in {q['id'] for q in pool}
        last.append(selected['id']);last=last[-12:]
assert 'class_name WritePad' in (root/'write_pad.gd').read_text()
assert 'WritePad.new()' in code and 'func _bank_vowel_choices' in code
assert '_bank_audio_for_question' in code
print('PASS: 898 unique tasks, 1000 audio files, 300000 randomized selection simulations, source-pattern checks')
print('LIMIT: Godot runtime, APK, audio playback, handwriting and Xiaomi device NOT tested')
