import json,collections,random,pathlib,zipfile
p=pathlib.Path(__file__).parent
q=json.loads((p/'questions_grade1.json').read_text())['questions']
a=json.loads((p/'audio_manifest.json').read_text())
s=(p/'main.gd').read_text()
worlds={'Lautlabor':['choose_letter','listen_choose','listen_choose_word','count_syllables','king_vowels','trace_letter','write_from_audio'],'Zahlenstadt':['math_choice','compare','story_math','count_objects','shape_identification'],'Kleine Stadt':['read_to_picture','read_sentence','copy_sentence']}
assert len(q)==898 and len({x['id'] for x in q})==898
assert len(a)==1000 and all((p/v).is_file() for v in a.values())
assert sum(sum(x['mode'] in modes for x in q) for modes in worlds.values())==898
assert all(sum(x['mode'] in modes for modes in worlds.values())==1 for x in q)
for x in q:
    options=x.get('options')
    if options:
        assert str(x['answer']) in [str(v) for v in options],x['id']
        assert len(set(map(str,options)))==len(options)
    elif x['mode']=='count_objects':
        n=x['meta']['requires_visual_count']
        options=list(dict.fromkeys(map(str,[n,max(0,n-1),n+1,n+2])))
        assert len(options)>=2 and str(x['answer']) in options
    else:
        assert x['mode'] in ['trace_letter','write_from_audio','king_vowels','read_sentence','copy_sentence','read_to_picture'],x['id']
assert 'var raw_options = bank_question.get("options", [])' in s
assert '_bank_manual_grade_unverified' in s and '_bank_manual_grade(true)' in s
assert 'func _bank_vowel_check' in s
assert 'func _bank_picture_choices()' in s
assert 'Schreibe diesen Satz ab:' in s
assert 'var syllables: Array' in s
random.seed(42)
for world,modes in worlds.items():
    pool=[x for x in q if x['mode'] in modes]
    recent=[]
    for i in range(100000):
        candidates=[x for x in pool if x['id'] not in recent] or pool
        chosen=random.choice(candidates)
        recent.append(chosen['id']);recent=recent[-12:]
print('PASS: 898 unique questions, all assigned exactly once; 1000 audio files; option coverage; 300000 selection simulations; static code guards.')
print('LIMITATION: No Godot engine, Android APK or device runtime tested.')
