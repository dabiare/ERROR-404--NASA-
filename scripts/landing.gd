extends Node2D
signal finished
const UI = preload("res://scripts/ui_kit.gd")
var clock := 0.0
var completed := false
var overlay: CanvasLayer
var status: Label

func _ready() -> void:
	overlay = CanvasLayer.new()
	add_child(overlay)
	var root := Control.new()
	overlay.add_child(root)
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	UI.at(UI.label("KILLA WASI   /   SECUENCIA DE ALUNIZAJE",18,UI.CYAN),root,Rect2(52,45,650,32))
	UI.at(UI.label("UN NUEVO HOGAR,\nA UN PASO.",48),root,Rect2(52,105,700,130))
	status = UI.label("Descenso final · Motores activos",20)
	UI.at(status,root,Rect2(52,626,800,45))
	var skip := UI.button("Omitir animación  →")
	UI.at(skip,root,Rect2(973,626,255,54))
	skip.pressed.connect(complete)
	skip.grab_focus()

func _process(delta: float) -> void:
	if completed or Session.paused: return
	clock += delta
	status.text = "Contacto confirmado · Bienvenida, comandante" if clock > 7.0 else "Descenso final · Motores activos"
	queue_redraw()
	if clock >= 10: complete()

func complete() -> void:
	if completed: return
	completed = true
	finished.emit()

func _draw() -> void:
	var view := get_viewport_rect().size
	draw_set_transform(Vector2.ZERO,0,view / Vector2(1280,720))
	draw_rect(Rect2(0,0,1280,720),Color("091426"))
	var rng := RandomNumberGenerator.new()
	rng.seed = 123
	for i in 130:
		var p := Vector2(rng.randf_range(0,1280),rng.randf_range(0,480))
		draw_rect(Rect2(p,Vector2(2,2)),Color(0.65,0.85,0.9,rng.randf_range(0.2,0.7)))
	draw_circle(Vector2(1110,140),46,Color("5aa8c4"))
	draw_arc(Vector2(1110,140),41,0.2,4.2,40,Color("b1d4a0"),14)
	draw_colored_polygon(PackedVector2Array([Vector2(0,510),Vector2(230,420),Vector2(410,480),Vector2(670,400),Vector2(850,460),Vector2(1100,430),Vector2(1280,500),Vector2(1280,720),Vector2(0,720)]),Color("333f50"))
	draw_rect(Rect2(0,555,1280,165),Color("525e6d"))
	for i in 30:
		var p := Vector2(rng.randf_range(0,1280),rng.randf_range(562,720))
		draw_set_transform(p,0,Vector2(1,0.25))
		draw_circle(Vector2.ZERO,rng.randf_range(15,55),Color("414c5b"))
	draw_set_transform(Vector2.ZERO,0,view / Vector2(1280,720))
	var progress := clampf(clock / 7.0,0,1)
	var lander_y := lerpf(120.0,475.0,1.0-pow(1.0-progress,2.0))
	var pos := Vector2(850,lander_y)
	if clock < 7:
		var flame := 38.0 if Session.reduced_motion else 38.0+sin(clock*25)*10
		draw_colored_polygon(PackedVector2Array([pos+Vector2(-20,48),pos+Vector2(20,48),pos+Vector2(0,48+flame)]),Color("f5c65b"))
	draw_line(pos+Vector2(-38,25),pos+Vector2(-72,79),Color("cba965"),10)
	draw_line(pos+Vector2(38,25),pos+Vector2(72,79),Color("cba965"),10)
	draw_rect(Rect2(pos+Vector2(-88,74),Vector2(38,9)),Color("172c3a"))
	draw_rect(Rect2(pos+Vector2(50,74),Vector2(38,9)),Color("172c3a"))
	draw_colored_polygon(PackedVector2Array([pos+Vector2(-37,-60),pos+Vector2(37,-60),pos+Vector2(58,45),pos+Vector2(-58,45)]),Color("c8d5d8"))
	draw_rect(Rect2(pos+Vector2(-34,-38),Vector2(68,32)),Color("233f55"))
	draw_rect(Rect2(pos+Vector2(-29,-33),Vector2(57,5)),UI.CYAN)
	draw_rect(Rect2(pos+Vector2(-25,10),Vector2(50,34)),Color("81949c"))
	draw_rect(Rect2(pos+Vector2(-8,14),Vector2(16,25)),UI.GOLD)
	if clock > 6.5 and clock < 9 and not Session.reduced_motion:
		for i in 12:
			var offset := (clock-6.5)*45+float(i)*10
			draw_circle(Vector2(850+(1 if i%2 else -1)*offset,550+sin(i)*8),12,Color(0.7,0.72,0.72,(9-clock)*0.15))
