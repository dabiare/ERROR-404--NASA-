extends Control
signal started
signal options_requested
const UI = preload("res://scripts/ui_kit.gd")
var content: Control

func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var background := TextureRect.new()
	background.texture = preload("res://assets/art/lunar_base.png")
	background.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	background.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(background)
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var gradient := Gradient.new()
	gradient.colors = PackedColorArray([Color("081323"),Color(0.03,0.07,0.13,0.9),Color(0.03,0.07,0.13,0.1)])
	gradient.offsets = PackedFloat32Array([0,0.32,0.8])
	var texture := GradientTexture2D.new()
	texture.gradient = gradient
	texture.fill_from = Vector2.ZERO
	texture.fill_to = Vector2(1,0)
	var shade := TextureRect.new()
	shade.texture = texture
	add_child(shade)
	shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	content = Control.new()
	add_child(content)
	content.size = Vector2(1280,720)
	UI.at(UI.label("ERROR 404  /  EXPLORACIÓN LUNAR",15,UI.CYAN),content,Rect2(64,48,550,24))
	UI.at(UI.label("MISIÓN",26,UI.GOLD),content,Rect2(64,137,400,40))
	var title := UI.label("KILLA\nWASI",88)
	title.add_theme_constant_override("line_spacing",-12)
	UI.at(title,content,Rect2(58,175,510,210))
	UI.at(UI.wrap_label("Nuestra casa en la Luna.\nCinco especialistas. Tu primera misión.",23,Color("bbd2d8")),content,Rect2(64,390,480,70))
	var start := UI.button("INICIAR MISIÓN    →",true)
	UI.at(start,content,Rect2(64,487,360,62))
	start.pressed.connect(func(): Sound.confirm(); started.emit())
	var options := UI.button("Opciones")
	UI.at(options,content,Rect2(64,565,176,52))
	options.pressed.connect(func(): options_requested.emit())
	var leave := UI.button("Salir")
	UI.at(leave,content,Rect2(252,565,172,52))
	leave.pressed.connect(func(): get_tree().quit())
	UI.at(UI.label("CAPÍTULO 01   ·   LLEGADA A KILLA WASI",14,UI.MUTED),content,Rect2(64,660,550,24))
	var pill := Panel.new()
	pill.add_theme_stylebox_override("panel",UI.panel(Color(0.04,0.1,0.16,0.85),Color("426875"),20))
	UI.at(pill,content,Rect2(1030,40,190,42))
	UI.at(UI.label("30 DÍAS  ·  5 TRIPULANTES",12,UI.CYAN),pill,Rect2(16,10,170,20))
	start.grab_focus()
	resized.connect(_layout)
	_layout()

func _layout() -> void:
	if not is_instance_valid(content): return
	var scale_factor := minf(size.x / 1280.0,size.y / 720.0)
	content.scale = Vector2.ONE * scale_factor
	content.position = (size - Vector2(1280,720)*scale_factor)*0.5
