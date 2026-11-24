class_name WritePad
extends Control
signal finished(points: int)
var strokes: Array = []
var active_id: int = -1
var active_type: String = ""
var writing: bool = false
var last_touch_ms: int = -10000
const MAX_STROKES = 120
const MAX_POINTS_PER_STROKE = 1500

func _inside(point: Vector2) -> bool:
    return Rect2(Vector2.ZERO, size).has_point(point)

func _append_point(point: Vector2) -> void:
    if strokes.is_empty() or not _inside(point):
        return
    if strokes[-1].size() < MAX_POINTS_PER_STROKE:
        strokes[-1].append(point)
        queue_redraw()

func _ready() -> void:
    mouse_filter = Control.MOUSE_FILTER_STOP

func _gui_input(event: InputEvent) -> void:
    if event is InputEventScreenTouch:
        last_touch_ms = Time.get_ticks_msec()
        if event.pressed and not writing and _inside(event.position) and strokes.size() < MAX_STROKES:
            writing = true
            active_id = event.index
            strokes.append([event.position])
            queue_redraw()
        elif not event.pressed and event.index == active_id:
            writing = false
            active_id = -1
    elif event is InputEventScreenDrag:
        if writing and event.index == active_id and not strokes.is_empty():
            _append_point(event.position)
    elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
        # Android may synthesize mouse events from touch. Avoid a duplicate stroke.
        if Time.get_ticks_msec() - last_touch_ms < 350:
            return
        if event.pressed and not writing and _inside(event.position) and strokes.size() < MAX_STROKES:
            writing = true
            active_id = -2
            strokes.append([event.position])
        elif not event.pressed and active_id == -2:
            writing = false
            active_id = -1
    elif event is InputEventMouseMotion and writing and active_id == -2:
        _append_point(event.position)

func _draw() -> void:
    draw_rect(Rect2(Vector2.ZERO, size), Color.WHITE)
    for y in [size.y * 0.2, size.y * 0.5, size.y * 0.8]:
        draw_line(Vector2(0, y), Vector2(size.x, y), Color(0.75, 0.83, 0.9), 2)
    for stroke in strokes:
        for i in range(1, stroke.size()):
            draw_line(stroke[i-1], stroke[i], Color(0.12, 0.28, 0.55), 5, true)

func clear_pad() -> void:
    strokes.clear()
    writing = false
    active_id = -1
    queue_redraw()

func has_marks() -> bool:
    for stroke in strokes:
        if stroke.size() >= 3:
            return true
    return false
