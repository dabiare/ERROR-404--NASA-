extends Node
const Data = preload("res://scripts/mission_data.gd")
var content: Node
var ui: CanvasLayer
var world: Node2D
var generation := 0

func _ready() -> void:
	configure_input()
	content = Node.new()
	content.name = "Content"
	add_child(content)
	ui = preload("res://scenes/interface.tscn").instantiate()
	add_child(ui)
	ui.priority_selected.connect(select_priority)
	ui.explore_requested.connect(explore)
	ui.restart_requested.connect(start_mission)
	ui.menu_requested.connect(show_menu)
	show_menu()
	if "--smoke-test" in OS.get_cmdline_user_args():
		call_deferred("run_smoke_tests")
	elif "--keyboard-test" in OS.get_cmdline_user_args():
		call_deferred("run_keyboard_tests")

func configure_input() -> void:
	var keys := {
		"move_left":[KEY_A,KEY_LEFT],"move_right":[KEY_D,KEY_RIGHT],
		"move_up":[KEY_W,KEY_UP],"move_down":[KEY_S,KEY_DOWN],
		"interact":[KEY_E],"dialogue_next":[KEY_ENTER,KEY_SPACE],"pause":[KEY_ESCAPE]
	}
	for action in keys:
		if not InputMap.has_action(action): InputMap.add_action(action)
		for code in keys[action]:
			var e := InputEventKey.new()
			e.physical_keycode = code
			InputMap.action_add_event(action,e)

func clear_content() -> void:
	generation += 1
	world = null
	for child in content.get_children():
		content.remove_child(child)
		child.queue_free()

func show_menu() -> void:
	clear_content()
	Session.reset()
	ui.clear_all()
	var menu := preload("res://scenes/menu.tscn").instantiate()
	content.add_child(menu)
	menu.started.connect(start_mission)
	menu.options_requested.connect(ui.show_pause)

func start_mission() -> void:
	clear_content()
	Session.reset()
	ui.clear_all()
	Session.advance(Session.Stage.MENU,Session.Stage.LANDING)
	var landing := preload("res://scenes/landing.tscn").instantiate()
	content.add_child(landing)
	landing.finished.connect(landed)

func landed() -> void:
	if not Session.advance(Session.Stage.LANDING,Session.Stage.ENTRY): return
	clear_content()
	world = preload("res://scenes/exterior.tscn").instantiate()
	content.add_child(world)
	ui.show_dialogue(Data.ARRIVAL)

func enter_base() -> void:
	if Session.stage != Session.Stage.ENTRY or Session.transition: return
	Session.transition = true
	ui.transition_text("ESCLUSA 01  /  Comprobando presión…")
	var token := generation
	await get_tree().create_timer(1.1).timeout
	if token != generation: return
	clear_content()
	world = preload("res://scenes/interior.tscn").instantiate()
	content.add_child(world)
	Session.advance(Session.Stage.ENTRY,Session.Stage.COMMUNICATIONS)
	Session.transition = false
	ui.hide_transition()
	ui.show_dialogue([["commander","Esclusa comprobada. Ya estoy dentro: iré al centro de mando para hablar con el equipo."]])

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.echo: return
	if event.is_action_pressed("interact") and Session.can_move() and is_instance_valid(world) and world.nearest:
		get_viewport().set_input_as_handled()
		interact(world.nearest.interaction_id)

func interact(id: String) -> void:
	if not Session.can_move(): return
	match id:
		"airlock": enter_base()
		"radio":
			if Session.stage == Session.Stage.COMMUNICATIONS:
				ui.show_dialogue(Data.RADIO,func():
					Session.presented.assign(["commander","engineer","botanist","doctor","geologist"])
					Session.advance(Session.Stage.COMMUNICATIONS,Session.Stage.CHOICE)
					ui.show_choice())
			elif Session.stage == Session.Stage.CHOICE: ui.show_choice()
			elif Session.stage == Session.Stage.EXPLORE: ui.show_report()
			else: ui.show_dialogue([["commander","Mi prioridad ya está elegida. Completaré esa preparación antes de enviar el informe."]])
		"shelf_a","shelf_b": inspect_storage(id)
		"lab_console":
			if Session.power_lab():
				Sound.confirm()
				ui.show_dialogue([["geologist","Consola encendida: ahora podemos comprobar los instrumentos. Acércate a la mesa de la muestra, a tu derecha."]])
			else: ui.show_dialogue([["geologist","La consola necesita una tarea asignada para comenzar. Si ya está encendida, el siguiente paso es registrar la muestra."]])
		"sample":
			if Session.register_sample():
				Sound.confirm()
				ui.show_dialogue([["geologist","¡Primer registro completado! La muestra conocida nos ayuda a comprobar que el instrumento mide como esperamos."],["commander","El laboratorio está preparado para las próximas muestras. La revisión del almacén quedará para otro turno."]],ui.show_report)
			else: ui.show_dialogue([["geologist","Esta es nuestra muestra de calibración. Para registrarla, primero debemos asignar la tarea y encender la consola."]])
		"exit": ui.show_dialogue([["commander","La próxima salida necesita una ruta, un compañero y una revisión del traje. Por ahora, terminemos nuestra preparación dentro de la base."]])
		_:
			if Data.GREETINGS.has(id):
				if Session.stage == Session.Stage.COMMUNICATIONS:
					ui.show_dialogue([[id,"Ya estoy comprobando mi área. Haremos el reporte del equipo cuando actives la radio del centro de mando."]])
				else: ui.show_dialogue([[id,Data.GREETINGS[id]]])

func select_priority(value: String) -> void:
	if not Session.select_priority(value): return
	Sound.confirm()
	if value=="storage":
		ui.show_dialogue([["engineer","Vamos a revisar el almacén, al suroeste de la base. Comprueba los dos estantes marcados: algo no coincide con el inventario."]])
	else:
		ui.show_dialogue([["geologist","El laboratorio está al sureste de la base. Enciende la consola y después registra la muestra de la mesa."]])

func inspect_storage(id: String) -> void:
	if not Session.inspect_shelf(id):
		var line := "Este estante ya está revisado." if id in Session.inspected else "Revisaremos estos estantes cuando asignemos la tarea del almacén."
		ui.show_dialogue([["engineer",line]])
		return
	Sound.confirm()
	if Session.stage == Session.Stage.REPORT:
		ui.show_dialogue([["engineer","¡Encontramos la diferencia! Esta caja tenía un filtro de repuesto guardado en el lugar equivocado."],["commander","Ahora sabemos dónde está el filtro cuando lo necesitemos. Activar el laboratorio quedará para otro turno."]],ui.show_report)
	else:
		ui.show_dialogue([["engineer","Primer estante comprobado: las etiquetas y el registro no coinciden. Revisemos el otro para encontrar la caja que falta."]])

func explore() -> void:
	if Session.stage == Session.Stage.REPORT: Session.advance(Session.Stage.REPORT,Session.Stage.EXPLORE)
	ui.set_hint("Habla con tu equipo o vuelve a mando para ver el informe")

func _process(_delta: float) -> void:
	if not is_instance_valid(world): return
	ui.set_hint("E   " + world.nearest.caption if world.nearest and Session.can_move() else "ESC   Pausa y opciones")
	var target := Vector2.ZERO
	var caption := ""
	var distance := INF
	for object in world.interactions:
		if object.target and object.position.distance_to(world.player.position) < distance:
			target = object.position
			caption = object.caption
			distance = object.position.distance_to(world.player.position)
	ui.set_navigation(world.player.position,target,caption)
	ui.room_label.text = "SUPERFICIE LUNAR   /   ACCESO A LA BASE" if world.kind=="exterior" else "KILLA WASI   /   HÁBITAT 01"
	if world.kind=="interior":
		for room in world.rooms:
			if room.rect.has_point(world.player.position): ui.room_label.text = "KILLA WASI   /   " + room.name

func run_smoke_tests() -> void:
	var harness := preload("res://tests/smoke.gd").new()
	add_child(harness)
	await harness.run(self)

func run_keyboard_tests() -> void:
	var harness := preload("res://tests/keyboard.gd").new()
	add_child(harness)
	await harness.run(self)
