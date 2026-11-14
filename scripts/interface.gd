extends CanvasLayer
signal priority_selected(value: String)
signal explore_requested
signal restart_requested
signal menu_requested
const UI = preload("res://scripts/ui_kit.gd")
const Data = preload("res://scripts/mission_data.gd")
var root: Control
var canvas: Control
var hud: Control
var objective_label: Label
var room_label: Label
var status_label: Label
var direction_label: Label
var hint_label: Label
var dialog_panel: Panel
var speaker_label: Label
var role_label: Label
var body_label: Label
var portrait: TextureRect
var control_icon: Label
var counter_label: Label
var dialogue: Array = []
var page := 0
var done := Callable()
var modal_layer: Control
var pause_layer: Control
var fade: ColorRect
var fade_label: Label
var hint := ""
var focus_before_pause: Control

func _ready() -> void:
	root = Control.new()
	add_child(root)
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	canvas = Control.new()
	root.add_child(canvas)
	canvas.size = Vector2(1280,720)
	canvas.mouse_filter = Control.MOUSE_FILTER_IGNORE
	build_hud()
	build_dialogue()
	modal_layer = Control.new()
	UI.at(modal_layer,canvas,Rect2(0,0,1280,720))
	modal_layer.hide()
	pause_layer = Control.new()
	UI.at(pause_layer,canvas,Rect2(0,0,1280,720))
	pause_layer.hide()
	fade = ColorRect.new()
	fade.color = Color("071323")
	UI.at(fade,canvas,Rect2(0,0,1280,720))
	fade_label = UI.label("",25,UI.CYAN)
	fade_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	UI.at(fade_label,fade,Rect2(200,320,880,60))
	fade.hide()
	root.resized.connect(layout)
	layout()
	Session.changed.connect(update_hud)
	update_hud()

func layout() -> void:
	var factor := minf(root.size.x/1280.0,root.size.y/720.0)
	canvas.scale = Vector2.ONE * factor
	canvas.position = (root.size-Vector2(1280,720)*factor)/2

func build_hud() -> void:
	hud = Control.new()
	UI.at(hud,canvas,Rect2(0,0,1280,720))
	hud.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var panel := Panel.new()
	panel.add_theme_stylebox_override("panel",UI.panel(Color(0.035,0.075,0.12,0.95),Color("355467")))
	UI.at(panel,hud,Rect2(28,24,630,90))
	UI.at(UI.label("◈",33,UI.GOLD),panel,Rect2(18,23,48,45))
	room_label = UI.label("KILLA WASI   /   PRIMEROS PASOS",13,UI.CYAN)
	UI.at(room_label,panel,Rect2(70,13,520,24))
	objective_label = UI.label("",23)
	UI.at(objective_label,panel,Rect2(70,39,544,35))
	var stats := Panel.new()
	stats.add_theme_stylebox_override("panel",UI.panel(Color(0.035,0.075,0.12,0.95),Color("355467")))
	UI.at(stats,hud,Rect2(920,24,332,90))
	UI.at(UI.label("DÍA 01 / 30",22,UI.GOLD),stats,Rect2(20,12,200,32))
	status_label = UI.label("5 TRIPULANTES  ·  SISTEMAS ESTABLES",12,UI.CYAN)
	UI.at(status_label,stats,Rect2(20,53,292,22))
	var pause := UI.button("Ⅱ")
	UI.at(pause,hud,Rect2(1164,36,66,44))
	pause.pressed.connect(show_pause)
	direction_label = UI.label("",16,UI.GOLD)
	UI.at(direction_label,hud,Rect2(38,121,650,25))
	var strip := Panel.new()
	strip.add_theme_stylebox_override("panel",UI.panel(Color(0.035,0.075,0.12,0.94),Color("294454"),8))
	UI.at(strip,hud,Rect2(28,650,1224,44))
	UI.at(UI.label("WASD / FLECHAS   Moverte      E   Interactuar",15,UI.MUTED),strip,Rect2(18,10,630,25))
	hint_label = UI.label("",18,UI.GOLD)
	hint_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	UI.at(hint_label,strip,Rect2(610,8,590,28))

func build_dialogue() -> void:
	dialog_panel = Panel.new()
	dialog_panel.add_theme_stylebox_override("panel",UI.panel(Color("101f30"),Color("60858f"),14))
	UI.at(dialog_panel,canvas,Rect2(28,454,1224,240))
	var portrait_bg := Panel.new()
	portrait_bg.add_theme_stylebox_override("panel",UI.panel(Color("1a3143"),Color("304f5b"),8))
	UI.at(portrait_bg,dialog_panel,Rect2(20,20,164,196))
	portrait = UI.portrait("commander",dialog_panel,Rect2(23,23,158,190))
	control_icon = UI.label("◎",92,UI.CYAN)
	control_icon.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	UI.at(control_icon,dialog_panel,Rect2(20,48,164,135))
	speaker_label = UI.label("",18,UI.GOLD)
	UI.at(speaker_label,dialog_panel,Rect2(210,21,820,28))
	role_label = UI.label("",14,UI.MUTED)
	UI.at(role_label,dialog_panel,Rect2(210,49,820,23))
	body_label = UI.wrap_label("",23)
	UI.at(body_label,dialog_panel,Rect2(210,84,980,94))
	counter_label = UI.label("",13,UI.MUTED)
	UI.at(counter_label,dialog_panel,Rect2(210,193,390,22))
	var next := UI.button("Continuar   ↵",true)
	UI.at(next,dialog_panel,Rect2(970,180,228,43))
	next.pressed.connect(advance_dialogue)
	dialog_panel.hide()

func show_dialogue(lines: Array, callback := Callable()) -> void:
	if lines.is_empty():
		if callback.is_valid(): callback.call()
		return
	dialogue = lines.duplicate(true)
	page = 0
	done = callback
	Session.modal = true
	dialog_panel.show()
	show_page()

func show_page() -> void:
	var id: String = dialogue[page][0]
	var who: Dictionary = Data.CREW[id]
	speaker_label.text = who.name
	speaker_label.add_theme_color_override("font_color",who.color)
	role_label.text = who.tag + "  /  RADIO DE LA MISIÓN"
	body_label.text = dialogue[page][1]
	portrait.texture = Data.portrait(id)
	portrait.visible = id != "control"
	control_icon.visible = id == "control"
	counter_label.text = "%02d / %02d     ·     ENTER / ESPACIO / CLIC" % [page+1,dialogue.size()]
	Sound.beep()

func advance_dialogue() -> void:
	if not dialog_panel.visible or Session.paused or Session.transition: return
	page += 1
	if page < dialogue.size():
		show_page()
		return
	dialog_panel.hide()
	Session.modal = false
	var callback := done
	done = Callable()
	if callback.is_valid(): callback.call()

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.echo: return
	if event.is_action_pressed("pause"):
		get_viewport().set_input_as_handled()
		if Session.transition: return
		if pause_layer.visible: close_pause()
		else: show_pause()
		return
	if dialog_panel.visible and not Session.paused and not Session.transition:
		if event.is_action_pressed("dialogue_next"):
			get_viewport().set_input_as_handled()
			advance_dialogue()

func update_hud() -> void:
	objective_label.text = Session.objective()
	hud.visible = Session.stage not in [Session.Stage.MENU,Session.Stage.LANDING]
	if Session.stage == Session.Stage.EXPLORE:
		status_label.text = "FILTROS +%d   ·   REGISTROS +%d" % [Session.filters,Session.records]
	else: status_label.text = "5 TRIPULANTES  ·  SISTEMAS ESTABLES"

func set_hint(value: String) -> void:
	hint_label.text = value

func set_navigation(player_pos: Vector2, target_pos: Vector2, caption: String) -> void:
	if target_pos == Vector2.ZERO or Session.modal:
		direction_label.text = ""
		return
	var diff := target_pos - player_pos
	if diff.length() < 90:
		direction_label.text = "ESTÁS EN EL LUGAR INDICADO  ·  Pulsa E"
		return
	var horizontal := "este" if diff.x > 0 else "oeste"
	var vertical := "sur" if diff.y > 0 else "norte"
	var direction := horizontal if absf(diff.x)>absf(diff.y)*2 else vertical
	if absf(diff.x)>60 and absf(diff.y)>60 and absf(diff.x)<absf(diff.y)*2 and absf(diff.y)<absf(diff.x)*2:
		direction = vertical + horizontal
	direction_label.text = "OBJETIVO AL %s  ·  %s" % [direction.to_upper(),caption]

func clear_layer(layer: Control) -> void:
	for child in layer.get_children():
		layer.remove_child(child)
		child.queue_free()

func modal_base(layer: Control, title: String, subtitle: String, rect := Rect2(235,120,810,480)) -> Panel:
	clear_layer(layer)
	layer.show()
	var shade := ColorRect.new()
	shade.color = Color(0.015,0.03,0.05,0.84)
	UI.at(shade,layer,Rect2(0,0,1280,720))
	var panel := Panel.new()
	panel.add_theme_stylebox_override("panel",UI.panel(Color("102334"),Color("527580"),16))
	UI.at(panel,layer,rect)
	UI.at(UI.label(title,34),panel,Rect2(32,26,rect.size.x-64,52))
	UI.at(UI.wrap_label(subtitle,19,UI.MUTED),panel,Rect2(32,85,rect.size.x-64,66))
	return panel

func show_choice() -> void:
	Session.modal = true
	var panel := modal_base(modal_layer,"Tu primera decisión","Hay tiempo para una preparación antes del informe inicial. ¿Qué priorizarás?",Rect2(140,108,1000,508))
	for i in 2:
		var x := 32+i*480
		var card := Panel.new()
		card.add_theme_stylebox_override("panel",UI.panel(Color("193248"),Color("426173"),10))
		UI.at(card,panel,Rect2(x,164,456,232))
		UI.at(UI.label("01  /  PREPARACIÓN" if i==0 else "02  /  INVESTIGACIÓN",13,UI.GOLD),card,Rect2(20,16,410,22))
		UI.at(UI.label("Revisar el almacén" if i==0 else "Activar el laboratorio",24),card,Rect2(20,48,410,36))
		var description := "Localiza los repuestos y comprueba dos estantes.\nBeneficio: un filtro de reserva disponible." if i==0 else "Comprueba los instrumentos con una muestra.\nBeneficio: el primer registro científico."
		UI.at(UI.wrap_label(description,19,UI.MUTED),card,Rect2(20,98,410,100))
		var b := UI.button("Elegir almacén" if i==0 else "Elegir laboratorio",i==0)
		UI.at(b,panel,Rect2(x,414,456,58))
		var choice := "storage" if i==0 else "lab"
		b.pressed.connect(func(): show_confirmation(choice))
		if i==0: b.grab_focus()

func show_confirmation(value: String) -> void:
	var storage := value == "storage"
	var panel := modal_base(modal_layer,"¿Confirmamos esta prioridad?","Revisar el almacén" if storage else "Activar el laboratorio",Rect2(270,150,740,420))
	var text := "Recuperarás un filtro de repuesto. Activar el laboratorio quedará pendiente para otro turno." if storage else "Obtendrás un registro científico. Revisar el almacén quedará pendiente para otro turno."
	UI.at(UI.wrap_label(text+"\n\nLos sistemas esenciales siguen funcionando.",22),panel,Rect2(32,146,676,150))
	var back := UI.button("Volver a las opciones")
	UI.at(back,panel,Rect2(32,330,316,58))
	back.pressed.connect(show_choice)
	var confirm := UI.button("Confirmar prioridad",true)
	UI.at(confirm,panel,Rect2(366,330,342,58))
	confirm.pressed.connect(func():
		modal_layer.hide()
		Session.modal = false
		priority_selected.emit(value))
	confirm.grab_focus()

func show_report() -> void:
	Session.modal = true
	var storage := Session.choice == "storage"
	var panel := modal_base(modal_layer,"Un buen comienzo, comandante","INFORME DE MISIÓN   /   DÍA 01   /   KILLA WASI",Rect2(170,62,940,596))
	UI.at(UI.label("PREPARACIÓN COMPLETADA",14,UI.CYAN),panel,Rect2(32,144,876,26))
	UI.at(UI.label("Almacén revisado" if storage else "Laboratorio activado",30,UI.GOLD),panel,Rect2(32,177,876,45))
	var body := "+1 filtro de repuesto localizado\nAhora el equipo sabe dónde encontrarlo si lo necesita.\n\nPendiente: activar el laboratorio." if storage else "+1 registro científico\nLos instrumentos están listos para estudiar nuevas muestras.\n\nPendiente: revisar el almacén."
	UI.at(UI.wrap_label(body,23),panel,Rect2(32,237,590,170))
	UI.portrait("commander",panel,Rect2(680,160,200,240))
	UI.at(UI.wrap_label("Dirigir una base significa elegir prioridades. Tu decisión aporta un beneficio y deja otra tarea para después.",20,UI.MUTED),panel,Rect2(32,420,876,70))
	var explore := UI.button("Seguir explorando",true)
	UI.at(explore,panel,Rect2(32,514,427,55))
	explore.pressed.connect(func(): modal_layer.hide(); Session.modal=false; explore_requested.emit())
	var restart := UI.button("Reiniciar introducción")
	UI.at(restart,panel,Rect2(481,514,427,55))
	restart.pressed.connect(func(): modal_layer.hide(); Session.modal=false; restart_requested.emit())
	explore.grab_focus()

func show_pause() -> void:
	if Session.transition: return
	focus_before_pause = get_viewport().gui_get_focus_owner()
	Session.paused = true
	var panel := modal_base(pause_layer,"Opciones" if Session.stage==Session.Stage.MENU else "Misión en pausa","Tómate tu tiempo. La misión puede esperar.",Rect2(350,80,580,560))
	UI.at(UI.label("Volumen",21),panel,Rect2(32,160,420,30))
	var slider := HSlider.new()
	slider.min_value = 0
	slider.max_value = 1
	slider.step = 0.05
	slider.value = Session.volume
	UI.at(slider,panel,Rect2(32,210,516,36))
	slider.value_changed.connect(Sound.set_volume)
	var check := CheckButton.new()
	check.text = "Movimiento reducido"
	check.add_theme_font_size_override("font_size",21)
	check.button_pressed = Session.reduced_motion
	UI.at(check,panel,Rect2(32,267,516,50))
	check.toggled.connect(func(value: bool): Session.reduced_motion=value)
	UI.at(UI.wrap_label("Desactiva el movimiento ambiental y los efectos de polvo.",17,UI.MUTED),panel,Rect2(32,319,516,50))
	var resume := UI.button("Volver",true)
	UI.at(resume,panel,Rect2(32,390,516,55))
	resume.pressed.connect(close_pause)
	resume.grab_focus()
	if Session.stage!=Session.Stage.MENU:
		var restart := UI.button("Reiniciar")
		UI.at(restart,panel,Rect2(32,463,248,55))
		restart.pressed.connect(func(): close_pause(); restart_requested.emit())
		var menu := UI.button("Menú principal")
		UI.at(menu,panel,Rect2(300,463,248,55))
		menu.pressed.connect(func(): close_pause(); menu_requested.emit())

func close_pause() -> void:
	pause_layer.hide()
	Session.paused = false
	if is_instance_valid(focus_before_pause) and focus_before_pause.is_visible_in_tree():
		focus_before_pause.grab_focus()
		return
	# Restore keyboard focus to the active modal, if present.
	var buttons: Array = modal_layer.find_children("*","Button",true,false) if modal_layer.visible else []
	if not buttons.is_empty(): buttons[0].grab_focus()

func transition_text(text: String) -> void:
	fade_label.text = text
	fade.show()

func hide_transition() -> void: fade.hide()

func clear_all() -> void:
	dialog_panel.hide()
	modal_layer.hide()
	pause_layer.hide()
	fade.hide()
	dialogue.clear()
	done = Callable()
