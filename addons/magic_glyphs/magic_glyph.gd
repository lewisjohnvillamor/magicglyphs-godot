@tool
@icon("res://addons/magic_glyphs/icon.svg")
class_name MagicGlyph
extends Control
## An animated Magic Glyphs icon. It springs into motion and can play its own short sound.
##
## Add a MagicGlyph node, pick its [member icon], and it plays when hovered or clicked.
## [codeblock]
## var g := MagicGlyph.new()
## g.icon = "heart"
## g.sound = true
## add_child(g)
## [/codeblock]

## Emitted each time the icon plays, with the name of its sound ("" if it has none).
signal played(sound_name: String)

enum Variant { OUTLINE, SOLID, DUOTONE }
enum Trigger { HOVER, CLICK, READY, MANUAL }

const DATA_PATH := "res://addons/magic_glyphs/glyphs.json"
const SOUND_DIR := "res://addons/magic_glyphs/sounds/"
const _STYLES := ["outline", "solid", "duotone"]
static var _data: Dictionary = {}
static var _fps := 30.0
## Set to false to mute every MagicGlyph, for a global sound switch.
static var sound_enabled := true

## The icon name, for example "heart". [method MagicGlyph.names] lists them all.
@export var icon := "heart":
	set(v):
		icon = v
		_reset()
## Outline, solid or duotone.
@export var variant := Variant.OUTLINE:
	set(v):
		variant = v
		queue_redraw()
## The icon colour.
@export var color := Color(0.08, 0.07, 0.17):
	set(v):
		color = v
		queue_redraw()
## The duotone fill colour. Leave it transparent to use [member color].
@export var secondary := Color(0, 0, 0, 0):
	set(v):
		secondary = v
		queue_redraw()
## The colour behind the icon. The solid style draws its inner details in it.
@export var backdrop := Color.WHITE:
	set(v):
		backdrop = v
		queue_redraw()
## What makes the icon play.
@export var trigger := Trigger.HOVER
## Play the icon's sound with its animation.
@export var sound := false
## Sound volume in decibels.
@export_range(-40, 6) var volume_db := 0.0
## The audio bus for its sound.
@export var bus := &"Master"

var _t := 0.0
var _playing := false
var _audio: AudioStreamPlayer


## Every icon name, sorted.
static func names() -> PackedStringArray:
	_load()
	var n := PackedStringArray(_data.keys())
	n.sort()
	return n


## The name of an icon's sound, or "" if it has none.
static func sound_of(name: String) -> String:
	_load()
	var g = _data.get(name)
	return g["s"] if g and g["s"] != null else ""


static func _load() -> void:
	if not _data.is_empty():
		return
	var parsed = JSON.parse_string(FileAccess.get_file_as_string(DATA_PATH))
	if parsed is Dictionary:
		_fps = float(parsed["fps"])
		_data = parsed["icons"]
		for g in _data.values():
			for layer in g["L"]:
				if layer["m"] != null:
					layer["m"] = PackedFloat32Array(layer["m"])
				for p in layer["p"]:
					if p["tri"] != null:
						p["tri"]["v"] = _points(p["tri"]["v"])
						p["tri"]["i"] = PackedInt32Array(p["tri"]["i"])
					for line in p["lines"]:
						line[0] = _points(line[0])
	else:
		push_error("Magic Glyphs: could not read " + DATA_PATH)


static func _points(a: Array) -> PackedVector2Array:
	var out := PackedVector2Array()
	out.resize(a.size() / 2)
	for i in out.size():
		out[i] = Vector2(a[i * 2], a[i * 2 + 1])
	return out


func _ready() -> void:
	_load()
	if custom_minimum_size == Vector2.ZERO:
		custom_minimum_size = Vector2(24, 24)
	mouse_entered.connect(func(): if trigger == Trigger.HOVER: play())
	_reset()
	if trigger == Trigger.READY and not Engine.is_editor_hint():
		play.call_deferred()


func _gui_input(event: InputEvent) -> void:
	if (trigger == Trigger.HOVER or trigger == Trigger.CLICK) and event is InputEventMouseButton and event.pressed:
		play()
	elif (trigger == Trigger.HOVER or trigger == Trigger.CLICK) and event is InputEventScreenTouch and event.pressed:
		play()


## Plays the animation, and the sound when [member sound] is on.
func play() -> void:
	_load()
	var g = _data.get(icon)
	if g == null:
		return
	_t = 0.0
	_playing = true
	set_process(true)
	var s: String = g["s"] if g["s"] != null else ""
	if sound and sound_enabled and s != "":
		if _audio == null:
			_audio = AudioStreamPlayer.new()
			add_child(_audio)
		_audio.stream = load(SOUND_DIR + s + ".wav")
		_audio.volume_db = volume_db
		_audio.bus = bus
		_audio.play()
	played.emit(s)
	queue_redraw()


## True while the animation is running.
func is_playing() -> bool:
	return _playing


## Shows the icon as it is [param seconds] into its motion, without playing it.
func seek(seconds: float) -> void:
	_playing = false
	_t = maxf(seconds, 0.0) * _fps
	queue_redraw()


func _reset() -> void:
	var g = _data.get(icon)
	_t = float(g["f"] - 1) if g else 0.0
	_playing = false
	queue_redraw()


func _process(delta: float) -> void:
	if not _playing:
		set_process(false)
		return
	var g = _data.get(icon)
	_t += delta * _fps
	if g == null or _t >= g["f"] - 1:
		_playing = false
		if g:
			_t = float(g["f"] - 1)
	queue_redraw()


func _matrix(a, frames: int) -> Transform2D:
	if a == null:
		return Transform2D.IDENTITY
	var t := minf(_t, frames - 1)
	var k := int(t)
	var j := mini(k + 1, frames - 1)
	var f := t - k
	var v := func(n: int) -> float: return lerpf(a[k * 6 + n], a[j * 6 + n], f)
	return Transform2D(Vector2(v.call(0), v.call(1)), Vector2(v.call(2), v.call(3)), Vector2(v.call(4), v.call(5)))


func _role(role: String) -> Color:
	if role == "bg":
		return backdrop
	if role == "sec":
		return secondary if secondary.a > 0.0 else color
	return color


func _draw() -> void:
	_load()
	var g = _data.get(icon)
	if g == null:
		return
	var k := minf(size.x, size.y) / 24.0
	var origin := (size - Vector2(24, 24) * k) / 2.0
	var w := 1.75 * k
	var style: String = _STYLES[variant]
	for layer in g["L"]:
		var m := Transform2D(0.0, Vector2(k, k), 0.0, origin) * _matrix(layer["m"], g["f"])
		var paint: Array = layer["st"][style]
		for p in layer["p"]:
			var fill_role: String = paint[0]
			if (p["fill"] != null or fill_role != "") and p["tri"] != null:
				var fc: Color = Color(p["fill"]) if p["fill"] != null else _role(fill_role)
				fc.a *= paint[1]
				var pts: PackedVector2Array = m * p["tri"]["v"]
				var idx: PackedInt32Array = p["tri"]["i"]
				if idx.size() >= 3:
					var cols := PackedColorArray()
					cols.resize(pts.size())
					cols.fill(fc)
					RenderingServer.canvas_item_add_triangle_array(get_canvas_item(), idx, pts, cols)
			if paint[2] != "":
				var sc := _role(paint[2])
				for line in p["lines"]:
					var pts: PackedVector2Array = m * line[0]
					if pts.size() < 2:
						continue
					if line[1]:
						pts.append(pts[0])
					draw_polyline(pts, sc, w, true)
					draw_circle(pts[0], w / 2.0, sc)
					draw_circle(pts[pts.size() - 1], w / 2.0, sc)
					for i in range(1, pts.size() - 1):
						var a := (pts[i] - pts[i - 1]).normalized()
						var b := (pts[i + 1] - pts[i]).normalized()
						if a.dot(b) < 0.95:
							draw_circle(pts[i], w / 2.0, sc)


func _validate_property(property: Dictionary) -> void:
	if property.name == "icon":
		property.hint = PROPERTY_HINT_ENUM_SUGGESTION
		property.hint_string = ",".join(names())
