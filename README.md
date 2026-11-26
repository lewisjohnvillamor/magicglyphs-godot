# Magic Glyphs for Godot 4

Animated icons with sound. Each icon springs into motion when it is hovered, clicked or appears, and can play its own short sound.

- **120 free icons** in outline, solid and duotone.
- **One node, `MagicGlyph`**, drawn as vectors, so it stays sharp at any size. No other plugins.
- **Sound, off by default**, through Godot's own audio, on any bus you choose.

## Install

From the Asset Library (search "Magic Glyphs"), or copy `addons/magic_glyphs` into your project. Then enable **Magic Glyphs** under Project Settings → Plugins.

## Use

Add a **MagicGlyph** node and set its **Icon**, **Variant** and **Color** in the Inspector. Or from code:

```gdscript
var g := MagicGlyph.new()
g.icon = "heart"
g.variant = MagicGlyph.Variant.DUOTONE
g.color = Color("#e11d48")
g.custom_minimum_size = Vector2(48, 48)
g.sound = true
add_child(g)
```

| Property | Default | |
|---|---|---|
| `icon` | `heart` | The icon name. `MagicGlyph.names()` lists them all |
| `variant` | `OUTLINE` | `OUTLINE`, `SOLID` or `DUOTONE` |
| `color` | near black | The icon colour |
| `secondary` | transparent | The duotone fill colour; transparent uses `color` |
| `backdrop` | white | The colour behind the icon; the solid style draws its inner details in it |
| `trigger` | `HOVER` | `HOVER` (hover or click), `CLICK`, `READY` or `MANUAL` |
| `sound` | false | Play the icon's sound |
| `volume_db`, `bus` | 0, Master | Sound volume and audio bus |

Call `play()` to play an icon yourself, and connect `played` to react to it. Mute every icon with `MagicGlyph.sound_enabled = false`. The node's size sets the icon size. The `demo` folder shows every icon.

## The full library

The full Magic Glyphs library has more than 8,000 icons, an icon maker for your own artwork, and 528 sounds. Export any of them for Godot with the command line tool: see [magicglyphs.com/docs/godot](https://magicglyphs.com/docs/godot/).

## Licence

MIT: the code, icons and sounds in this add-on. The paid Magic Glyphs icons have their own licence.
