extends Node3D

# Original 3D learning prototype. No third-party assets.
# Reading, writing and math are separate skills. Writing is NOT auto-graded.
const SYLLABLES = ["MA", "MI", "MO", "MU", "ME", "TA", "TO", "TE"]
const WORDS = ["Mama", "Oma", "Dose", "Tomate"]
const MODES = ["Silben-Obby", "Mathe-Rennen", "Supermarkt"]
const PETS = ["Fuchs", "Drache", "Roboter", "Katze", "Eule"]
const PICTURE_SYMBOLS = {
    "Auto":"🚗", "Ball":"⚽", "Banane":"🍌", "Blume":"🌼", "Brot":"🍞",
    "Buch":"📖", "Dose":"🥫", "Esel":"🐴", "Fisch":"🐟", "Hase":"🐰",
    "Haus":"🏠", "Hose":"👖", "Hund":"🐶", "Igel":"🦔", "Katze":"🐱",
    "Kind":"🧒", "Kino":"🎬", "Lampe":"💡", "Limo":"🥤", "Mama":"👩",
    "Mami":"👩", "Maus":"🐭", "Melone":"🍈", "Mimi":"👧", "Momo":"👦",
    "Mond":"🌙", "Nase":"👃", "Oma":"👵", "Omi":"👵", "Rose":"🌹",
    "Salami":"🥓", "Schule":"🏫", "Sonne":"☀️", "Tante":"👩",
    "Tinte":"🖋️", "Tisch":"🪑", "Tomate":"🍅", "Tomaten":"🍅",
    "Tonne":"🗑️", "Uhu":"🦉"
}
const SHAPE_SYMBOLS = {"Kreis": "●", "Quadrat": "■", "Dreieck": "▲", "Rechteck": "▰"}
const EGG_STEPS = 3
const MAX_VISIBLE_PETS = 8
var last_mode: String = ""
var last_targets: Array[String] = []
var pet_nodes: Array[Node3D] = []
var eggs_ready: int = 0
var pending_writing: String = ""
var player: Node3D
var camera: Camera3D
var ui: CanvasLayer
var modal: PanelContainer
var body: VBoxContainer
var status: Label
var task_label: Label
var current_mode: String = ""
var target: String = ""
var correct: String = ""
var answered: bool = false
var mission_number: int = 0
var rng := RandomNumberGenerator.new()
var pad: WritePad
var progress: Dictionary = {}
var move_dir := Vector2.ZERO
var audio_player: AudioStreamPlayer
var audio_paths: Dictionary = {}
var audio_available: bool = false
var question_bank: Array = []
var bank_by_world: Dictionary = {}
var bank_question: Dictionary = {}
var bank_world: String = ""
var bank_last_ids: Array[String] = []
const BANK_WORLDS = {
    "Lautlabor": ["choose_letter", "listen_choose", "listen_choose_word", "count_syllables", "king_vowels", "trace_letter", "write_from_audio"],
    "Zahlenstadt": ["math_choice", "compare", "story_math", "count_objects", "shape_identification"],
    "Kleine Stadt": ["read_to_picture", "read_sentence", "copy_sentence"]
}
const MANUAL_MODES = ["trace_letter", "write_from_audio", "copy_sentence", "read_sentence", "king_vowels", "read_to_picture"]
var review_complete: bool = false
var bank_answered: bool = false
var bank_pad: WritePad
var bank_audio_generation: int = 0
var audio_cache: Dictionary = {}


func _ready() -> void:
    rng.randomize()
    _load_progress()
    _init_audio()
    _init_bank()
    _make_world()
    _make_ui()
    _restore_pets()
    _show_lobby()

func _init_audio() -> void:
    audio_player = AudioStreamPlayer.new()
    add_child(audio_player)
    if not FileAccess.file_exists("res://audio_manifest.json"):
        return
    var f := FileAccess.open("res://audio_manifest.json", FileAccess.READ)
    if f == null:
        return
    var manifest = JSON.parse_string(f.get_as_text())
    if manifest is Dictionary:
        audio_paths = manifest
        audio_available = true

func _init_bank() -> void:
    if not FileAccess.file_exists("res://questions_grade1.json"):
        return
    var f := FileAccess.open("res://questions_grade1.json", FileAccess.READ)
    if f == null:
        return
    var data = JSON.parse_string(f.get_as_text())
    if data is Dictionary and data.get("questions", null) is Array:
        question_bank = data["questions"]
        for world in BANK_WORLDS:
            var allowed_modes: Array = BANK_WORLDS[world]
            var indexed: Array = []
            for item in question_bank:
                if item is Dictionary and allowed_modes.has(str(item.get("mode", ""))):
                    indexed.append(item)
            bank_by_world[world] = indexed

func _bank_choose(world: String) -> void:
    _stop_audio()
    bank_world = world
    var all_questions: Array = bank_by_world.get(world, [])
    var choices: Array = []
    for item in all_questions:
        if not bank_last_ids.has(str(item.get("id", ""))):
            choices.append(item)
    if choices.is_empty():
        choices = all_questions.duplicate()
    if choices.is_empty():
        _clear_body()
        _label("Keine Aufgaben für diese Lernwelt gefunden.")
        _button("Zurück", _show_lobby)
        return
    bank_question = choices[rng.randi_range(0, choices.size() - 1)]
    bank_last_ids.append(str(bank_question.get("id", "")))
    if bank_last_ids.size() > 12:
        bank_last_ids.pop_front()
    bank_answered = false
    bank_audio_generation += 1
    mission_number += 1
    _bank_render()

func _bank_render() -> void:
    modal.visible = true
    _clear_body()
    var mode := str(bank_question.get("mode", ""))
    var prompt := str(bank_question.get("prompt", ""))
    _label("🌍 " + bank_world, 29)
    # Audio is mode-specific: decoding and reading tasks must not speak their answer.
    if _bank_is_listening_mode(mode):
        _label("🔊 Höre genau zu. Die Lösung wird vorher nicht gezeigt.")
        _button("🔊 Noch einmal hören", _bank_audio)
        _bank_queue_audio()
    elif mode == "shape_identification":
        _label("Finde die Form. Tippe auf das richtige Zeichen.")
    elif mode == "count_objects":
        _label("Zähle die Punkte:")
        var n := int(bank_question.get("meta", {}).get("requires_visual_count", 0))
        _label("● ".repeat(n) if n > 0 else "Keine Punkte", 30)
    elif mode == "read_to_picture":
        _label("📖 Lies das Wort und wähle das passende Bildzeichen.")
        _label(str(bank_question.get("answer", "")), 33)
        _label("Bildzeichen sind vorläufige Symbole, keine geprüften Illustrationen.", 16)
        _bank_picture_choices()
        return
    elif mode == "read_sentence":
        _label("📖 Lies diesen Satz laut:", 20)
        _label(str(bank_question.get("answer", "")), 32)
    elif mode == "copy_sentence":
        _label("✏️ Schreibe diesen Satz ab:", 20)
        _label(str(bank_question.get("answer", "")), 30)
    elif mode == "trace_letter":
        _label("✏️ Schreibe den Buchstaben nach. Vorlage:", 20)
        _label(str(bank_question.get("answer", "")), 42)
        _label("Schreibrichtung und Buchstabenform müssen Erwachsene prüfen.", 17)
    elif mode == "king_vowels":
        _label("👑 Tippe jeden Königsbuchstaben an.", 22)
        _label("Jede Silbe hat einen Vokal. Suche sie selbst.", 18)
        _bank_vowel_choices()
        _bank_queue_audio()
        _button("🔊 Wort hören", _bank_audio)
        return
    else:
        _label(prompt)
    # Narrate the task for non-reading modes. Never read out the answer
    # for independent word/sentence reading or copying.
    if _bank_should_narrate(mode):
        _button("🔊 Aufgabe anhören", _bank_audio)
        _bank_queue_audio()
    if MANUAL_MODES.has(mode):
        _bank_manual_ui(mode)
        return
    var raw_options = bank_question.get("options", [])
    var options: Array = raw_options.duplicate() if raw_options is Array else []
    if mode == "count_objects" and options.size() < 2:
        var n := int(bank_question.get("meta", {}).get("requires_visual_count", 0))
        for candidate in [n, max(0, n - 1), n + 1, n + 2]:
            var v := str(candidate)
            if not options.has(v):
                options.append(v)
    if options.size() < 2:
        _label("Für diese Aufgabe fehlen Antwortmöglichkeiten.")
        _button("Zurück", _show_lobby)
        return
    options.shuffle()
    for option in options:
        var value := str(option)
        var display_text := (str(SHAPE_SYMBOLS.get(value, "?")) + "  " + value) if mode == "shape_identification" else value
        _button(display_text, func(): _bank_answer(value))
    _button("Zurück", _show_lobby)


func _bank_picture_choices() -> void:
    var answer := str(bank_question.get("answer", ""))
    var symbol := str(PICTURE_SYMBOLS.get(answer, ""))
    if symbol.is_empty():
        _label("Für dieses Wort fehlt ein Bildzeichen. Bitte gemeinsam lesen.")
        _bank_manual_ui("read_to_picture")
        return
    var distractors: Array[String] = []
    var used_symbols: Dictionary = {}
    used_symbols[symbol] = true
    var pool := PICTURE_SYMBOLS.keys()
    pool.shuffle()
    for word in pool:
        var candidate := str(PICTURE_SYMBOLS[word])
        if not used_symbols.has(candidate):
            distractors.append(candidate)
            used_symbols[candidate] = true
        if distractors.size() >= 3:
            break
    var choices: Array[String] = distractors
    choices.append(symbol)
    choices.shuffle()
    for picture in choices:
        var selected := picture
        _button(selected, func(): _bank_picture_answer(selected, symbol))
    _button("Zurück", _show_lobby)


func _bank_picture_answer(selected: String, expected: String) -> void:
    if bank_answered:
        return
    bank_answered = true
    _stop_audio()
    var ok := selected == expected
    _bank_record(ok)
    _add_egg_energy()
    _clear_body()
    _label("🌟 Richtiges Bildzeichen!" if ok else "🌤️ Wir schauen das Wort noch einmal an.", 27)
    _button("Nächste Aufgabe", func(): _bank_choose(bank_world))
    _button("Zur Insel", _show_lobby)


var vowel_selected: Dictionary = {}
func _bank_vowel_choices() -> void:
    vowel_selected.clear()
    var syllables: Array = bank_question.get("meta", {}).get("syllables", [])
    var word := ""
    for syl in syllables:
        word += str(syl)
    if word.is_empty():
        word = str(bank_question.get("answer", ""))
    var letters := HBoxContainer.new()
    body.add_child(letters)
    for i in range(word.length()):
        var index := i
        var b := Button.new()
        b.text = word.substr(i, 1)
        b.custom_minimum_size = Vector2(58, 72)
        letters.add_child(b)
        b.pressed.connect(func():
            if vowel_selected.has(index):
                vowel_selected.erase(index)
                b.modulate = Color.WHITE
            else:
                vowel_selected[index] = true
                b.modulate = Color(1.0, 0.84, 0.3)
        )
    _button("👑 Fertig", func(): _bank_vowel_check(word))
    _button("Zurück", _show_lobby)


func _bank_vowel_check(word: String) -> void:
    if bank_answered:
        return
    bank_answered = true
    _stop_audio()
    var expected := {}
    for i in range(word.length()):
        if "aeiouAEIOU".contains(word.substr(i, 1)):
            expected[i] = true
    var ok := expected.size() == vowel_selected.size()
    if ok:
        for index in expected:
            if not vowel_selected.has(index):
                ok = false
                break
    _bank_record(ok)
    _add_egg_energy()
    _clear_body()
    _label("👑 Alle Königsbuchstaben gefunden!" if ok else "🌤️ Suche beim nächsten Mal jeden Vokal.", 25)
    _button("Nächste Aufgabe", func(): _bank_choose(bank_world))
    _button("Zur Insel", _show_lobby)


func _bank_manual_ui(mode: String) -> void:
    if mode != "read_sentence" and mode != "read_to_picture":
        bank_pad = WritePad.new()
        bank_pad.custom_minimum_size = Vector2(240, 180)
        body.add_child(bank_pad)
        _button("🧽 Löschen", func(): bank_pad.clear_pad())
    _label("Ein Erwachsener überprüft die Leistung. Kein automatisches Richtig/Falsch.", 17)
    _button("👩‍🏫 Zur gemeinsamen Kontrolle", _bank_manual_finish)
    _button("Später", func(): _bank_choose(bank_world))
    _button("Zurück", _show_lobby)


func _bank_manual_finish() -> void:
    if bank_answered:
        return
    var mode := str(bank_question.get("mode", ""))
    if mode != "read_sentence" and mode != "read_to_picture" and (bank_pad == null or not bank_pad.has_marks()):
        _label("Bitte erst etwas schreiben oder markieren.")
        return
    bank_answered = true
    _stop_audio()
    _clear_body()
    _label("👩‍🏫 Gemeinsam überprüfen", 27)
    if mode != "read_to_picture":
        _label("Vergleiche mit: " + str(bank_question.get("answer", "")), 25)
    else:
        _label("Hat das Kind das Wort selbst gelesen und seine Bedeutung erklärt?")
    _label("Nur Erwachsene bestätigen die Richtigkeit.", 18)
    _button("✓ Richtig / selbstständig", func(): _bank_manual_grade(true))
    _button("↻ Noch üben", func(): _bank_manual_grade(false))
    _button("Nicht beurteilt", func(): _bank_manual_grade_unverified())


func _bank_manual_grade(ok: bool) -> void:
    _bank_record(ok, true)
    _add_egg_energy()
    _clear_body()
    _label("🌟 Gut gemacht!" if ok else "🌤️ Wir üben das später noch einmal.", 26)
    _button("Nächste Übung", func(): _bank_choose(bank_world))
    _button("Zur Insel", _show_lobby)


func _bank_manual_grade_unverified() -> void:
    _bank_record(false, true, true)
    _add_egg_energy()
    _clear_body()
    _label("Versuch gespeichert, nicht bewertet.", 25)
    _button("Nächste Übung", func(): _bank_choose(bank_world))
    _button("Zur Insel", _show_lobby)


func _bank_is_listening_mode(mode: String) -> bool:
    return mode in ["listen_choose", "listen_choose_word", "count_syllables", "write_from_audio"]


func _bank_should_narrate(mode: String) -> bool:
    # Narrate instructions / word problems, never the written answer in
    # tasks explicitly testing independent reading or copying.
    return mode in ["choose_letter", "math_choice", "compare", "story_math", "count_objects", "shape_identification", "trace_letter"]


func _bank_queue_audio() -> void:
    # Defer until after the UI is built. Stale calls must not play for
    # the next question if the child navigates quickly.
    var question_id := str(bank_question.get("id", ""))
    var generation := bank_audio_generation
    call_deferred("_bank_audio_for_question", question_id, generation)


func _bank_audio_for_question(question_id: String, generation: int) -> void:
    if generation != bank_audio_generation or str(bank_question.get("id", "")) != question_id or not modal.visible:
        return
    _bank_audio()


func _bank_audio() -> void:
    var key := str(bank_question.get("speech", ""))
    if audio_paths.has(key):
        _play_clip(key)
    elif audio_paths.has(key.to_lower()):
        _play_clip(key.to_lower())
    else:
        _label("🔇 Keine Aufnahme. Bitte einen Erwachsenen um Hilfe.", 16)
        _button("👩‍🏫 Vorlesekarte", _bank_adult_read_card)


func _bank_adult_read_card() -> void:
    _stop_audio()
    # This is intentionally not a child-facing solution. An adult must
    # shield the screen, read the word, and return to the exercise.
    var answer_text := str(bank_question.get("answer", ""))
    _clear_body()
    _label("👩‍🏫 NUR FÜR ERWACHSENE", 30)
    _label("Bitte Adam den Bildschirm kurz nicht zeigen.", 19)
    _label("Vorlesen: " + answer_text, 30)
    _button("Zur Aufgabe zurück", _bank_render)


func _bank_record(ok: bool, manual: bool = false, unverified: bool = false) -> void:
    var qid := str(bank_question.get("id", ""))
    var records: Dictionary = progress.get("bank_records", {})
    var rec: Dictionary = records.get(qid, {"attempts": 0, "correct_first": 0, "manual": 0, "unverified": 0})
    rec["attempts"] = int(rec.get("attempts", 0)) + 1
    if manual:
        rec["manual"] = int(rec.get("manual", 0)) + 1
    if unverified:
        rec["unverified"] = int(rec.get("unverified", 0)) + 1
    elif ok:
        rec["correct_first"] = int(rec.get("correct_first", 0)) + 1
    records[qid] = rec
    progress["bank_records"] = records
    _save_progress()

func _bank_answer(value: String) -> void:
    if bank_answered:
        return
    bank_answered = true
    _stop_audio()
    var ok := value == str(bank_question.get("answer", ""))
    _bank_record(ok)
    _add_egg_energy()
    _clear_body()
    _label("🌟 Geschafft!" if ok else "🌦️ Robo übt diese Fähigkeit später erneut.", 27)
    _label("Nur der erste Versuch zählt.")
    _button("Nächste Abenteueraufgabe", func(): _bank_choose(bank_world))
    _button("Zur Insel", _show_lobby)

func _stop_audio() -> void:
    bank_audio_generation += 1
    if audio_player != null:
        audio_player.stop()


func _play_clip(key: String) -> void:
    if not audio_available or audio_player == null:
        return
    var relative_path := str(audio_paths.get(key, ""))
    if relative_path.is_empty():
        return
    var path := "res://" + relative_path
    var stream: AudioStream = null
    if audio_cache.has(key):
        stream = audio_cache[key]
    else:
        # Direct byte decoding also works for MP3 files bundled as non-resource
        # assets, avoiding reliance on dynamic imported-resource discovery.
        if FileAccess.file_exists(path):
            var bytes := FileAccess.get_file_as_bytes(path)
            if not bytes.is_empty():
                var mp3 := AudioStreamMP3.new()
                mp3.data = bytes
                stream = mp3
        if stream == null:
            var resource := load(path)
            if resource is AudioStream:
                stream = resource
        if stream != null:
            if audio_cache.size() >= 48:
                audio_cache.clear()
            audio_cache[key] = stream
    if stream != null:
        audio_player.stop()
        audio_player.stream = stream
        audio_player.play()
    else:
        push_warning("Audio unavailable for key: " + key)

func _replay_prompt() -> void:
    if current_mode == "Mathe-Rennen":
        if audio_paths.has("#mathgate"):
            _play_clip("#mathgate")
    elif not target.is_empty():
        _play_clip(target.to_lower() if current_mode == "Silben-Obby" else target)

func _box(parent: Node3D, position: Vector3, scale_value: Vector3, color: Color) -> MeshInstance3D:
    var n := MeshInstance3D.new()
    var mesh := BoxMesh.new()
    mesh.size = scale_value
    n.mesh = mesh
    var mat := StandardMaterial3D.new()
    mat.albedo_color = color
    n.material_override = mat
    n.position = position
    parent.add_child(n)
    return n

func _make_world() -> void:
    _box(self, Vector3(0, -0.4, 0), Vector3(32, 0.8, 32), Color(0.32, 0.72, 0.37))
    for i in range(12):
        _box(self, Vector3(-14 + i * 2.5, 0.25, -12), Vector3(1.4, 1.5, 1.4), Color(0.92, 0.71, 0.35))
    for i in range(3):
        _box(self, Vector3(-8 + i * 8, 0.4, -4), Vector3(3, 1, 3), [Color.CORNFLOWER_BLUE, Color.ORANGE, Color.MEDIUM_PURPLE][i])
    player = Node3D.new()
    add_child(player)
    _box(player, Vector3(0, 1.1, 0), Vector3(0.8, 1.3, 0.6), Color(0.94, 0.25, 0.18))
    _box(player, Vector3(0, 2.0, 0), Vector3(0.6, 0.6, 0.6), Color(0.94, 0.76, 0.56))
    player.position = Vector3(0, 0, 6)
    camera = Camera3D.new()
    add_child(camera)
    camera.current = true
    var light := DirectionalLight3D.new()
    light.rotation_degrees = Vector3(-50, 20, 0)
    add_child(light)
    var env := WorldEnvironment.new()
    var environment := Environment.new()
    environment.background_mode = Environment.BG_COLOR
    environment.background_color = Color(0.49, 0.76, 0.97)
    env.environment = environment
    add_child(env)

func _process(delta: float) -> void:
    if modal.visible:
        return
    var movement := Vector3(move_dir.x, 0, move_dir.y)
    player.position += movement * delta * 6.0
    player.position.x = clamp(player.position.x, -14.0, 14.0)
    player.position.z = clamp(player.position.z, -14.0, 14.0)
    camera.position = camera.position.lerp(player.position + Vector3(0, 7, 11), min(1.0, delta * 5.0))
    camera.look_at(player.position + Vector3(0, 1, 0))
    for i in range(pet_nodes.size()):
        var follower := pet_nodes[i]
        var offset := Vector3(1.6 + float(i % 3) * 0.8, 0.5, 1.0 + (float(i) / 3.0) * 0.8)
        follower.position = follower.position.lerp(player.position + offset, min(1.0, delta * 2.5))

func _make_ui() -> void:
    ui = CanvasLayer.new()
    add_child(ui)
    var layer := Control.new()
    layer.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    ui.add_child(layer)
    status = Label.new()
    status.position = Vector2(20, 18)
    status.add_theme_font_size_override("font_size", 24)
    layer.add_child(status)
    var controls := HBoxContainer.new()
    controls.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_LEFT)
    controls.position = Vector2(20, -95)
    layer.add_child(controls)
    for entry in [["◀", Vector2(-1, 0)], ["▲", Vector2(0, -1)], ["▼", Vector2(0, 1)], ["▶", Vector2(1, 0)]]:
        var b := Button.new()
        b.text = entry[0]
        b.custom_minimum_size = Vector2(76, 76)
        controls.add_child(b)
        var d: Vector2 = entry[1]
        b.button_down.connect(func(): move_dir = d)
        b.button_up.connect(func(): move_dir = Vector2.ZERO)
    var mission := Button.new()
    mission.text = "🎮 Missionen"
    mission.position = Vector2(20, 75)
    mission.custom_minimum_size = Vector2(210, 64)
    layer.add_child(mission)
    mission.pressed.connect(_show_lobby)
    modal = PanelContainer.new()
    modal.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    modal.offset_left = 24
    modal.offset_top = 140
    modal.offset_right = -24
    modal.offset_bottom = -20
    layer.add_child(modal)
    var margin := MarginContainer.new()
    margin.add_theme_constant_override("margin_left", 22)
    margin.add_theme_constant_override("margin_top", 18)
    margin.add_theme_constant_override("margin_right", 22)
    margin.add_theme_constant_override("margin_bottom", 18)
    modal.add_child(margin)
    var scroll := ScrollContainer.new()
    scroll.custom_minimum_size = Vector2(0, 0)
    scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
    margin.add_child(scroll)
    body = VBoxContainer.new()
    body.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    body.add_theme_constant_override("separation", 12)
    scroll.add_child(body)
    _update_status()

func _clear_body() -> void:
    bank_pad = null
    pad = null
    for c in body.get_children():
        body.remove_child(c)
        c.queue_free()

func _label(t: String, size_px: int = 25) -> void:
    var l := Label.new()
    l.text = t
    l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    l.add_theme_font_size_override("font_size", size_px)
    body.add_child(l)

func _button(t: String, callback: Callable) -> void:
    var b := Button.new()
    b.text = t
    b.custom_minimum_size = Vector2(0, 56)
    body.add_child(b)
    b.pressed.connect(callback)

func _show_lobby() -> void:
    _stop_audio()
    modal.visible = true
    _clear_body()
    _label("BuchstabenCraft Adventure", 32)
    _label("Wähle ein Abenteuer. Jedes Mal eine neue Aufgabe.")
    _label("🥚 Eier: %d   🐾 Tiere: %d   ✨ Energie: %d/%d" % [eggs_ready, progress.get("pets", []).size(), int(progress.get("egg_energy", 0)), EGG_STEPS], 20)
    if eggs_ready > 0:
        _button("🥚 Ei ausbrüten", _hatch_egg)
    _button("🎲 Überraschungsmission", _random_mission)
    _label("🌍 Lernwelten · eigene Aufgabenbank", 22)
    for world in BANK_WORLDS.keys():
        var chosen_world: String = world
        _button("🌍 " + chosen_world, func(): _bank_choose(chosen_world))
    for mode in MODES:
        var selected_mode := mode
        _button(mode, func(): _start_mode(selected_mode))
    _button("🌳 Frei erkunden", _enter_exploration)

func _enter_exploration() -> void:
    _stop_audio()
    move_dir = Vector2.ZERO
    modal.visible = false


func _random_mission() -> void:
    var choices := MODES.duplicate()
    if choices.size() > 1:
        choices.erase(last_mode)
    _start_mode(choices[rng.randi_range(0, choices.size() - 1)])

func _pick_fresh(values: Array) -> String:
    var candidates := values.duplicate()
    for recent in last_targets:
        candidates.erase(recent)
    if candidates.is_empty():
        candidates = values.duplicate()
    var chosen := str(candidates[rng.randi_range(0, candidates.size() - 1)])
    last_targets.append(chosen)
    if last_targets.size() > 3:
        last_targets.pop_front()
    return chosen

func _start_mode(mode: String) -> void:
    _stop_audio()
    last_mode = mode
    current_mode = mode
    mission_number += 1
    answered = false
    if mode == "Silben-Obby":
        correct = _pick_fresh(SYLLABLES)
        target = correct
        _choices("🔊 Hör die Silbe. Tippe einmal auf die passende Plattform.", correct, SYLLABLES)
    elif mode == "Mathe-Rennen":
        var a := rng.randi_range(1, 5)
        var b := rng.randi_range(1, 5)
        correct = str(b)
        target = str(a) + " + □ = " + str(a+b)
        _choices(target, correct, [str(b), str(max(0,b-1)), str(b+1), str(b+2)])
    else:
        correct = _pick_fresh(WORDS)
        target = correct
        _choices("🔊 Hör das Wort. Lies die Schilder und wähle das richtige.", correct, WORDS)

func _choices(prompt: String, answer: String, pool: Array) -> void:
    modal.visible = true
    _clear_body()
    _label(current_mode, 29)
    _label(prompt)
    var opts := pool.duplicate()
    opts.erase(answer)
    opts.shuffle()
    opts = opts.slice(0, 3)
    opts.append(answer)
    opts.shuffle()
    var used := {}
    var count := 0
    for option in opts:
        if used.has(option):
            continue
        used[option] = true
        var value := str(option)
        _button(value, func(): _answer(value))
        count += 1
        if count == 4:
            break
    if current_mode != "Mathe-Rennen":
        _button("🔊 Noch einmal hören", _replay_prompt)
    _replay_prompt()

func _answer(value: String) -> void:
    if answered:
        return
    answered = true
    _stop_audio()
    var ok := value == correct
    _clear_body()
    if ok:
        _label("🌟 Richtige Antwort!", 31)
        _label("Du hast die Mission geschafft.")
    else:
        _label("🌧️ Robo braucht Hilfe.", 31)
        _label("Nur der erste Versuch zählt. Wir üben diese Fähigkeit später erneut.")
    _record(current_mode, ok)
    _add_egg_energy()
    if current_mode != "Mathe-Rennen":
        _button("✏️ Jetzt schreiben", _show_write)
    _button("Nächste Mission", func(): _start_mode(current_mode))
    _button("Zurück zur Insel", _show_lobby)

func _show_write() -> void:
    _stop_audio()
    _clear_body()
    _label("✏️ Schreibwerkstatt", 30)
    _label("Schreibe nach Gehör. Die Schrift wird nicht automatisch bewertet.")
    _label("Höre genau hin und schreibe ohne sichtbare Vorlage.", 18)
    _button("🔊 Wort hören", _replay_prompt)
    pad = WritePad.new()
    pad.custom_minimum_size = Vector2(240, 210)
    pad.mouse_filter = Control.MOUSE_FILTER_STOP
    body.add_child(pad)
    _button("🧽 Löschen", func(): pad.clear_pad())
    _button("✓ Fertig (mit Erwachsenen prüfen)", _complete_write)
    _button("Später schreiben", func(): _start_mode(current_mode))
    _replay_prompt()

func _complete_write() -> void:
    if pad == null or not is_instance_valid(pad) or not pad.has_marks():
        _label("Schreibe zuerst etwas auf die Tafel.")
        return
    progress["writing_attempts"] = int(progress.get("writing_attempts", 0)) + 1
    _save_progress()
    _clear_body()
    _label("✏️ Schreibversuch gespeichert", 30)
    _label("Nur der Schreibversuch wurde gespeichert. Bitte gemeinsam prüfen.")
    _button("Nächste Mission", func(): _start_mode(current_mode))

func _record(mode: String, ok: bool) -> void:
    var k := mode.replace(" ", "_")
    var r: Dictionary = progress.get(k, {"attempts": 0, "first_try": 0})
    r["attempts"] += 1
    if ok:
        r["first_try"] += 1
    progress[k] = r
    _save_progress()
    _update_status()

func _update_status() -> void:
    status.text = "💎 BuchstabenCraft   |   Missionen: " + str(mission_number)

func _save_progress() -> void:
    var serialized := JSON.stringify(progress)
    var tmp_path := "user://progress.tmp"
    var f := FileAccess.open(tmp_path, FileAccess.WRITE)
    if f == null:
        push_warning("Cannot open temporary progress file")
        return
    f.store_string(serialized)
    f.flush()
    f.close()
    var absolute_tmp := ProjectSettings.globalize_path(tmp_path)
    var absolute_main := ProjectSettings.globalize_path("user://progress.json")
    var absolute_backup := ProjectSettings.globalize_path("user://progress.backup.json")
    if FileAccess.file_exists("user://progress.json"):
        var old_file := FileAccess.open("user://progress.json", FileAccess.READ)
        if old_file != null and JSON.parse_string(old_file.get_as_text()) is Dictionary:
            DirAccess.copy_absolute(absolute_main, absolute_backup)
    var err := DirAccess.rename_absolute(absolute_tmp, absolute_main)
    if err != OK:
        push_warning("Progress save rename failed: " + str(err))


func _load_progress() -> void:
    for path in ["user://progress.json", "user://progress.backup.json"]:
        if not FileAccess.file_exists(path):
            continue
        var f := FileAccess.open(path, FileAccess.READ)
        if f == null:
            continue
        var data = JSON.parse_string(f.get_as_text())
        if data is Dictionary:
            progress = data
            return
    progress = {}


func _add_egg_energy() -> void:
    # Energy reflects participation, not a child's reading ability.
    var energy := int(progress.get("egg_energy", 0)) + 1
    if energy >= EGG_STEPS:
        energy -= EGG_STEPS
        eggs_ready += 1
    progress["egg_energy"] = energy
    progress["eggs_ready"] = eggs_ready
    _save_progress()

func _hatch_egg() -> void:
    if eggs_ready < 1:
        return
    eggs_ready -= 1
    progress["eggs_ready"] = eggs_ready
    var species := PETS[rng.randi_range(0, PETS.size()-1)]
    var pets: Array = progress.get("pets", [])
    if pets.size() >= 250:
        eggs_ready += 1
        progress["eggs_ready"] = eggs_ready
        _save_progress()
        _clear_body()
        _label("🐾 Deine Tier-Sammlung ist voll!", 27)
        _button("Zur Insel", _show_lobby)
        return
    pets.append(species)
    progress["pets"] = pets
    if pet_nodes.size() < MAX_VISIBLE_PETS:
        _spawn_pet(species, pet_nodes.size())
    _save_progress()
    _clear_body()
    _label("🥚 Dein Ei ist geschlüpft!", 30)
    _label("🐾 Neues Tier: " + species)
    _label("Es begleitet dich jetzt auf der Insel.")
    _button("🌳 Zur Insel", func(): modal.visible = false)
    _button("Weitere Abenteuer", _show_lobby)

func _spawn_pet(species: String, index: int) -> void:
    var pet := Node3D.new()
    add_child(pet)
    var colors: Dictionary = {
        "Fuchs": Color(1.0, 0.48, 0.15),
        "Drache": Color(0.35, 0.8, 0.4),
        "Roboter": Color(0.4, 0.65, 0.95),
        "Katze": Color(0.8, 0.6, 0.9),
        "Eule": Color(0.7, 0.5, 0.3)
    }
    _box(pet, Vector3(0, 0.3, 0), Vector3(0.55, 0.55, 0.55), colors.get(species, Color.WHITE))
    _box(pet, Vector3(0, 0.67, 0), Vector3(0.35, 0.3, 0.35), colors.get(species, Color.WHITE))
    pet.position = player.position + Vector3(1.5 + index * 0.5, 0, 1.0)
    pet_nodes.append(pet)

func _restore_pets() -> void:
    eggs_ready = int(progress.get("eggs_ready", 0))
    var pets: Array = progress.get("pets", [])
    for i in range(min(pets.size(), MAX_VISIBLE_PETS)):
        _spawn_pet(str(pets[i]), i)
