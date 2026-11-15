extends RefCounted

const FONT_PATHS := ["res://campaign/minijuegos/VT323-Regular.ttf", "res://campaign/VT323-Regular.ttf", "res://VT323-Regular.ttf"]
const FONT_SCALE := 1.4

const WHITE := Color("f4f6ff")
const BLACK := Color("07060f")
const INK := Color("0e0b24")
const BLUE := Color("3b6cff")
const LIGHT_BLUE := Color("9bb8ff")
const VIOLET := Color("8a4dff")
const LILAC := Color("c3a4ff")
const DIM := Color("2a2a55")

const TINT_SHADER := """
shader_type canvas_item;
uniform sampler2D screen_tex : hint_screen_texture, filter_linear;
uniform float strength = 0.18;
void fragment() {
	vec3 c = texture(screen_tex, SCREEN_UV).rgb;
	float l = dot(c, vec3(0.299, 0.587, 0.114));
	vec3 black = vec3(0.027, 0.024, 0.059);
	vec3 violet = vec3(0.541, 0.302, 1.0);
	vec3 blue = vec3(0.231, 0.424, 1.0);
	vec3 white = vec3(0.957, 0.965, 1.0);
	vec3 g;
	if (l < 0.35) g = mix(black, violet, l / 0.35);
	else if (l < 0.7) g = mix(violet, blue, (l - 0.35) / 0.35);
	else g = mix(blue, white, (l - 0.7) / 0.3);
	COLOR = vec4(mix(c, g, strength), 1.0);
}
"""

# Relleno del titulo neon: bandas blanco -> lila -> violeta con rayas finas
const FILL_SHADER := """
shader_type canvas_item;
uniform float line_h = 100.0;
varying float ly;
void vertex() {
	ly = VERTEX.y;
}
void fragment() {
	float t = clamp(ly / line_h, 0.0, 1.0);
	t = floor(t * 6.0) / 6.0;
	vec3 top = vec3(1.0, 1.0, 1.0);
	vec3 mid = vec3(0.765, 0.643, 1.0);
	vec3 bot = vec3(0.541, 0.302, 1.0);
	vec3 col = t < 0.5 ? mix(top, mid, t * 2.0) : mix(mid, bot, (t - 0.5) * 2.0);
	float stripe = step(0.8, fract(ly / 6.0));
	col = mix(col, vec3(0.05, 0.04, 0.2), stripe * 0.3 * t);
	COLOR = vec4(col, COLOR.a);
}
"""

static func get_font() -> Font:
	for path in FONT_PATHS:
		if ResourceLoader.exists(path):
			var f: FontFile = load(path)
			f.antialiasing = TextServer.FONT_ANTIALIASING_NONE
			f.hinting = TextServer.HINTING_NONE
			f.subpixel_positioning = TextServer.SUBPIXEL_POSITIONING_DISABLED
			return f
	return ThemeDB.fallback_font

static func box(bg: Color, border: Color, width: int = 4, margin: int = 10) -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.bg_color = bg
	s.border_color = border
	s.set_border_width_all(width)
	s.set_corner_radius_all(0)
	s.anti_aliasing = false
	s.content_margin_left = margin
	s.content_margin_right = margin
	s.content_margin_top = margin * 0.6
	s.content_margin_bottom = margin * 0.6
	return s

static func build() -> Theme:
	var t := Theme.new()
	t.default_font = get_font()
	t.default_font_size = 28
	t.set_stylebox("normal", "Button", box(INK, BLUE))
	t.set_stylebox("hover", "Button", box(Color("231a55"), WHITE))
	t.set_stylebox("pressed", "Button", box(BLUE, WHITE))
	t.set_stylebox("focus", "Button", box(Color("231a55"), VIOLET, 6))
	t.set_stylebox("disabled", "Button", box(BLACK, DIM))
	for c in ["font_color", "font_hover_color", "font_pressed_color", "font_focus_color"]:
		t.set_color(c, "Button", WHITE)
	t.set_color("font_disabled_color", "Button", Color("6f74a8"))
	t.set_color("font_color", "Label", WHITE)
	t.set_color("font_shadow_color", "Label", BLACK)
	t.set_constant("shadow_offset_x", "Label", 2)
	t.set_constant("shadow_offset_y", "Label", 2)
	return t

static func add_grade(parent: Node, layer_index: int = 5) -> CanvasLayer:
	var layer := CanvasLayer.new()
	layer.layer = layer_index
	var rect := ColorRect.new()
	rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var sh := Shader.new()
	sh.code = TINT_SHADER
	var mat := ShaderMaterial.new()
	mat.shader = sh
	rect.material = mat
	layer.add_child(rect)
	parent.add_child(layer)
	return layer

# ---------- Ayudas para crear controles con el estilo del juego ----------
static func make_label(parent: Control, text: String, rect: Rect2, size: int, color: Color) -> Label:
	var l := Label.new()
	l.text = text
	l.position = rect.position
	l.size = rect.size
	l.set_meta("polished", true)
	l.add_theme_font_override("font", get_font())
	l.add_theme_font_size_override("font_size", size)
	l.add_theme_color_override("font_color", color)
	l.add_theme_color_override("font_shadow_color", BLACK)
	l.add_theme_constant_override("shadow_offset_x", 2)
	l.add_theme_constant_override("shadow_offset_y", 2)
	l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(l)
	return l

static func make_button(parent: Control, text: String, rect: Rect2, cb: Callable, size: int = 30) -> Button:
	var b := Button.new()
	b.text = text
	b.position = rect.position
	b.size = rect.size
	b.focus_mode = Control.FOCUS_NONE
	b.set_meta("polished", true)
	b.add_theme_font_override("font", get_font())
	b.add_theme_font_size_override("font_size", size)
	for c in ["font_color", "font_hover_color", "font_pressed_color"]:
		b.add_theme_color_override(c, WHITE)
	b.add_theme_stylebox_override("normal", box(INK, BLUE))
	b.add_theme_stylebox_override("hover", box(Color("231a55"), WHITE))
	b.add_theme_stylebox_override("pressed", box(BLUE, WHITE))
	b.add_theme_stylebox_override("focus", box(INK, BLUE))
	b.pressed.connect(cb)
	parent.add_child(b)
	return b

# ---------- Titulo neon (capas: resplandor violeta, contorno celeste, contorno negro, relleno degradado) ----------
static func neon_title(parent: Control, lines: Array, pos: Vector2, font_size: int = 110) -> float:
	var font: Font = get_font()
	var line_h: float = font.get_height(font_size)
	var holder := Control.new()
	holder.position = pos
	holder.mouse_filter = Control.MOUSE_FILTER_IGNORE
	holder.set_meta("polished", true)
	parent.add_child(holder)
	var glow := Control.new()
	glow.mouse_filter = Control.MOUSE_FILTER_IGNORE
	glow.set_meta("polished", true)
	holder.add_child(glow)
	var layers: Array = [
		{"outline": 36, "color": Color(VIOLET, 0.32), "glow": true},
		{"outline": 18, "color": LIGHT_BLUE, "glow": false},
		{"outline": 9, "color": BLACK, "glow": false},
		{"outline": 0, "color": WHITE, "glow": false, "fill": true},
	]
	for layer in layers:
		for i in lines.size():
			var l := Label.new()
			l.text = str(lines[i])
			l.position = Vector2(0, i * (line_h + 6.0))
			l.mouse_filter = Control.MOUSE_FILTER_IGNORE
			l.set_meta("polished", true)
			l.add_theme_font_override("font", font)
			l.add_theme_font_size_override("font_size", font_size)
			l.add_theme_color_override("font_color", layer["color"])
			l.add_theme_color_override("font_outline_color", layer["color"])
			l.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0))
			l.add_theme_constant_override("outline_size", layer["outline"])
			if layer.get("fill", false):
				var sh := Shader.new()
				sh.code = FILL_SHADER
				var mat := ShaderMaterial.new()
				mat.shader = sh
				mat.set_shader_parameter("line_h", line_h)
				l.material = mat
			if layer["glow"]:
				glow.add_child(l)
			else:
				holder.add_child(l)
	if not Mission.reduced_motion:
		var tw := glow.create_tween().set_loops()
		tw.tween_property(glow, "modulate:a", 0.35, 1.2).set_trans(Tween.TRANS_SINE)
		tw.tween_property(glow, "modulate:a", 1.0, 1.2).set_trans(Tween.TRANS_SINE)
		var tb := holder.create_tween().set_loops()
		tb.tween_property(holder, "position:y", pos.y - 4.0, 1.8).set_trans(Tween.TRANS_SINE)
		tb.tween_property(holder, "position:y", pos.y + 2.0, 1.8).set_trans(Tween.TRANS_SINE)
	return pos.y + lines.size() * (line_h + 6.0)

# Estrellitas que titilan
static func twinkle(parent: Control, count: int = 36) -> void:
	var rng := RandomNumberGenerator.new()
	rng.randomize()
	var colors: Array = [WHITE, LIGHT_BLUE, LILAC]
	for i in count:
		var s := ColorRect.new()
		var big: bool = rng.randf() < 0.25
		s.size = Vector2(6, 6) if big else Vector2(3, 3)
		s.position = Vector2(rng.randf_range(10.0, 1270.0), rng.randf_range(10.0, 340.0))
		s.color = colors[rng.randi() % 3]
		s.mouse_filter = Control.MOUSE_FILTER_IGNORE
		parent.add_child(s)
		if Mission.reduced_motion: continue
		var tw := s.create_tween().set_loops()
		tw.tween_interval(rng.randf_range(0.0, 2.0))
		tw.tween_property(s, "modulate:a", 0.1, rng.randf_range(0.5, 1.4))
		tw.tween_property(s, "modulate:a", 1.0, rng.randf_range(0.5, 1.4))

# Opcion de menu estilo juego retro: texto plano con cursor "> "
static func menu_item(b: Button, label: String) -> void:
	b.set_meta("polished", true)
	b.flat = true
	b.alignment = HORIZONTAL_ALIGNMENT_LEFT
	b.text = "  " + label
	var empty := StyleBoxEmpty.new()
	for sname in ["normal", "hover", "pressed", "focus", "disabled"]:
		b.add_theme_stylebox_override(sname, empty)
	b.add_theme_font_override("font", get_font())
	b.add_theme_font_size_override("font_size", 46)
	b.add_theme_color_override("font_color", LILAC)
	b.add_theme_color_override("font_hover_color", WHITE)
	b.add_theme_color_override("font_focus_color", WHITE)
	b.add_theme_color_override("font_pressed_color", WHITE)
	b.add_theme_color_override("font_disabled_color", DIM)
	b.focus_entered.connect(func(): b.text = "> " + label)
	b.focus_exited.connect(func(): b.text = "  " + label)
	b.mouse_entered.connect(func(): if not b.disabled: b.grab_focus())

# Se aplica a cada Control que crea ui.gd: fuente mas grande, esquinas rectas y animacion
static func polish(c: Control) -> void:
	if not is_instance_valid(c) or c.has_meta("polished"): return
	c.set_meta("polished", true)
	if (c is Label or c is Button) and c.has_theme_font_size_override("font_size"):
		var size: int = c.get_theme_font_size("font_size")
		c.add_theme_font_size_override("font_size", int(round(size * FONT_SCALE)))
	for sname in ["panel", "normal", "hover", "pressed", "focus", "disabled"]:
		if c.has_theme_stylebox_override(sname):
			var sb: StyleBox = c.get_theme_stylebox(sname)
			if sb is StyleBoxFlat:
				sb.set_corner_radius_all(0)
				sb.anti_aliasing = false
	if c is Button:
		c.mouse_entered.connect(func(): _pop(c, 1.05))
		c.focus_entered.connect(func(): _pop(c, 1.05))
	elif (c is Panel or c is PanelContainer) and c.size.x > 600 and not Mission.reduced_motion:
		c.pivot_offset = c.size / 2
		c.scale = Vector2(0.92, 0.92)
		c.modulate.a = 0.0
		var tw := c.create_tween().set_parallel(true)
		tw.tween_property(c, "scale", Vector2.ONE, 0.22).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		tw.tween_property(c, "modulate:a", 1.0, 0.15)

static func _pop(c: Control, s: float) -> void:
	if Mission.reduced_motion or not is_instance_valid(c) or not c.is_inside_tree(): return
	c.pivot_offset = c.size / 2
	var tw := c.create_tween()
	tw.tween_property(c, "scale", Vector2(s, s), 0.08)
	tw.tween_property(c, "scale", Vector2.ONE, 0.12)
