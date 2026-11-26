extends SceneTree
# Headless check of the Magic Glyphs add-on: data loads, every icon and style draws without errors, play and sounds work.
var fails := 0
func check(ok: bool, msg: String) -> void:
	print(("PASS " if ok else "FAIL ") + msg)
	if not ok: fails += 1

func _initialize() -> void:
	var names := MagicGlyph.names()
	check(names.size() == 120, "120 icons listed (%d)" % names.size())
	check(MagicGlyph.sound_of("bell") != "", "bell has a sound")
	var box := Control.new()
	root.add_child(box)
	var made := 0
	for n in names:
		for v in 3:
			var g := MagicGlyph.new()
			g.icon = n
			g.variant = v
			g.custom_minimum_size = Vector2(48, 48)
			g.size = Vector2(48, 48)
			box.add_child(g)
			made += 1
	check(made == 360, "360 icon nodes created")
	await process_frame
	await process_frame
	var g: MagicGlyph = box.get_child(0)
	var heard := []
	g.played.connect(func(s): heard.append(s))
	g.sound = true
	g.play()
	check(g.is_playing(), "play() starts the animation")
	check(heard.size() == 1 and heard[0] == MagicGlyph.sound_of(g.icon), "played signal carries the sound name")
	await create_timer(5.0).timeout
	check(not g.is_playing(), "the animation finishes")
	var missing := 0
	for n in names:
		var s := MagicGlyph.sound_of(n)
		if s != "" and load(MagicGlyph.SOUND_DIR + s + ".wav") == null: missing += 1
	check(missing == 0, "every icon's sound loads as an AudioStream")
	print("RESULT %d failed" % fails)
	quit(1 if fails else 0)
