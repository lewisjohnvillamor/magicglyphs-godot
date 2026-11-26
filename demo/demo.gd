extends Control
## Every free icon. Hover or click one to play it with its sound.

func _ready() -> void:
	var grid := GridContainer.new()
	grid.columns = 10
	grid.add_theme_constant_override("h_separation", 24)
	grid.add_theme_constant_override("v_separation", 24)
	grid.position = Vector2(32, 32)
	add_child(grid)
	var i := 0
	for n in MagicGlyph.names():
		var g := MagicGlyph.new()
		g.icon = n
		g.variant = i % 3
		g.color = Color("#4a35d6") if i % 2 == 0 else Color("#14122b")
		g.custom_minimum_size = Vector2(48, 48)
		g.sound = true
		g.tooltip_text = n
		grid.add_child(g)
		i += 1
