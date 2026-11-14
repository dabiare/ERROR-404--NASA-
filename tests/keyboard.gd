extends Node
## Drives real InputEvents through the game and walks the collision-aware routes.
var game: Node
var failed := false

func verify(value: bool, description: String) -> void:
	if not value:
		failed = true
		push_error("KEYBOARD CHECK: "+description)

func event(code: Key, pressed: bool) -> void:
	var e := InputEventKey.new()
	e.keycode=code
	e.physical_keycode=code
	e.pressed=pressed
	Input.parse_input_event(e)

func tap(code: Key) -> void:
	event(code,true)
	await get_tree().process_frame
	event(code,false)
	await get_tree().process_frame

func read_dialogue() -> void:
	for i in 40:
		if not game.ui.dialog_panel.visible: break
		await tap(KEY_ENTER)

func walk_to(id: String) -> void:
	var station: Node2D
	for object in game.world.interactions:
		if object.interaction_id==id: station=object
	if not station:
		verify(false,"Missing station "+id)
		return
	var from := Vector2i(game.world.player.position/32)
	var to := Vector2i(station.position/32)
	var path: PackedVector2Array = game.world.navigator.get_point_path(from,to)
	verify(not path.is_empty(),"Path to "+id)
	var steps := 0
	var held: Key=KEY_NONE
	for point in path:
		while game.world.player.position.distance_to(point)>5.0:
			var diff: Vector2=point-game.world.player.position
			var key: Key
			if absf(diff.x)>absf(diff.y): key=KEY_D if diff.x>0 else KEY_A
			else: key=KEY_S if diff.y>0 else KEY_W
			if key!=held:
				if held!=KEY_NONE: event(held,false)
				event(key,true)
				held=key
			await get_tree().physics_frame
			steps+=1
			if steps>1800:
				event(held,false)
				verify(false,"Walk timeout to "+id)
				return
	if held!=KEY_NONE: event(held,false)
	await get_tree().process_frame
	await get_tree().process_frame
	verify(game.world.nearest!=null and game.world.nearest.interaction_id==id,"Nearest interaction is "+id)
	await tap(KEY_E)

func run(root: Node) -> void:
	game=root
	await get_tree().process_frame
	await tap(KEY_ENTER)
	verify(Session.stage==Session.Stage.LANDING,"Menu starts using Enter")
	for branch in ["storage","lab"]:
		if branch=="lab":
			game.start_mission()
			await get_tree().process_frame
		await tap(KEY_ENTER)
		verify(Session.stage==Session.Stage.ENTRY,"Skip works using Enter")
		await read_dialogue()
		await walk_to("airlock")
		await get_tree().create_timer(1.3).timeout
		await read_dialogue()
		verify(Session.stage==Session.Stage.COMMUNICATIONS,"Walk and enter airlock using keys")
		await walk_to("radio")
		await read_dialogue()
		verify(Session.stage==Session.Stage.CHOICE,"Radio and all reports using keys")
		if branch=="lab": await tap(KEY_TAB)
		await tap(KEY_ENTER)
		await tap(KEY_ENTER)
		verify(Session.choice==branch,"Choose and confirm "+branch+" using keys")
		await read_dialogue()
		if branch=="storage":
			await walk_to("shelf_a")
			await read_dialogue()
			await walk_to("shelf_b")
			await read_dialogue()
		else:
			await walk_to("lab_console")
			await read_dialogue()
			await walk_to("sample")
			await read_dialogue()
		verify(Session.stage==Session.Stage.REPORT,"Complete "+branch+" using keyboard")
		await tap(KEY_ENTER)
		verify(Session.stage==Session.Stage.EXPLORE,"Report exits using keyboard")
		print("KEYBOARD BRANCH COMPLETE: "+branch)
	Sound.shutdown()
	await get_tree().create_timer(0.4).timeout
	print("KEYBOARD RESULT: "+("FAIL" if failed else "PASS · both complete branches"))
	get_tree().quit(1 if failed else 0)
