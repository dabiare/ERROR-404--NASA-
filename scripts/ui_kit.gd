extends RefCounted
const INK := Color("0b1626")
const PANEL := Color("101f31")
const TEXT := Color("edf4ef")
const MUTED := Color("9fb7c4")
const GOLD := Color("f5c65b")
const CYAN := Color("73d6d2")

static func panel(color := PANEL, border := Color("314859"), radius := 12) -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.bg_color = color
	s.border_color = border
	s.set_border_width_all(1)
	s.set_corner_radius_all(radius)
	s.content_margin_left = 20
	s.content_margin_right = 20
	s.content_margin_top = 14
	s.content_margin_bottom = 14
	return s

static func label(text: String, size := 20, color := TEXT) -> Label:
	var l := Label.new()
	l.text = text
	l.add_theme_font_size_override("font_size",size)
	l.add_theme_color_override("font_color",color)
	l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return l

static func button(text: String, primary := false) -> Button:
	var b := Button.new()
	b.text = text
	b.custom_minimum_size = Vector2(0,54)
	b.add_theme_font_size_override("font_size",20)
	b.add_theme_stylebox_override("normal",panel(GOLD if primary else Color("14283a"),GOLD if primary else Color("3d5969"),8))
	b.add_theme_stylebox_override("hover",panel(Color("ffe0a1") if primary else Color("23475b"),GOLD if primary else CYAN,8))
	b.add_theme_stylebox_override("pressed",panel(Color("cda347") if primary else Color("305366"),GOLD,8))
	b.add_theme_stylebox_override("focus",panel(Color(0,0,0,0),Color("ffffff"),8))
	b.add_theme_color_override("font_color",INK if primary else TEXT)
	b.add_theme_color_override("font_focus_color",INK if primary else TEXT)
	b.add_theme_color_override("font_hover_color",INK if primary else TEXT)
	b.add_theme_color_override("font_pressed_color",INK if primary else TEXT)
	b.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	return b

static func at(control: Control, parent: Node, rect: Rect2) -> Control:
	parent.add_child(control)
	control.position = rect.position
	control.size = rect.size
	return control

static func wrap_label(text: String, size := 20, color := TEXT) -> Label:
	var l := label(text,size,color)
	l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	return l

static func portrait(id: String, parent: Node, rect: Rect2, full := false) -> TextureRect:
	var t := TextureRect.new()
	t.texture = preload("res://scripts/mission_data.gd").portrait(id,full)
	t.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	t.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	t.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	at(t,parent,rect)
	return t
