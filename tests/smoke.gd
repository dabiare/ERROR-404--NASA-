extends Node
## Integration checks exercise scene lifecycle, modal input, branches and physics.
var checks := 0
var failures: Array[String] = []
var capture := false

func check(value: bool, message: String) -> void:
	checks += 1
	if not value:
		failures.append(message)
		push_error("CHECK FAILED: " + message)

func finish_dialogue(game: Node) -> void:
	for i in 100:
		if not game.ui.dialog_panel.visible: break
		game.ui.advance_dialogue()

func shot(name: String) -> void:
	if not capture: return
	await RenderingServer.frame_post_draw
	get_viewport().get_texture().get_image().save_png("res://artifacts/"+name+".png")

func run(game: Node) -> void:
	capture = "--capture" in OS.get_cmdline_user_args()
	if capture: DirAccess.make_dir_recursive_absolute("res://artifacts")
	await get_tree().process_frame
	await shot("01-menu-1280")
	check(Session.stage==Session.Stage.MENU,"Initial state is menu")
	var menu_focus: Control = get_viewport().gui_get_focus_owner()
	game.ui.show_pause()
	game.ui.close_pause()
	check(get_viewport().gui_get_focus_owner()==menu_focus,"Options restore keyboard focus")
	game.start_mission()
	var landing: Node = game.content.get_child(0)
	Session.paused = true
	var old_clock: float = landing.clock
	await get_tree().process_frame
	check(landing.clock==old_clock,"Pause freezes landing")
	Session.paused = false
	landing.complete()
	landing.complete()
	check(Session.stage==Session.Stage.ENTRY,"Skipping lands once")
	check(game.content.get_child_count()==1,"Only one exterior exists")
	check(game.ui.dialogue[0][1].contains("30 días"),"Skipping preserves mission context")
	await shot("02-arrival-1280")
	var old_page: int = game.ui.page
	game.ui.show_pause()
	game.ui.advance_dialogue()
	check(game.ui.page==old_page,"Pause prevents dialogue advance")
	Sound.set_volume(0)
	check(AudioServer.is_bus_mute(0),"Volume zero mutes audio")
	Sound.set_volume(0.65)
	check(not AudioServer.is_bus_mute(0),"Volume restores audio")
	await shot("03-options-1280")
	game.ui.close_pause()
	finish_dialogue(game)
	var before: Vector2 = game.world.player.position
	game.world.player.walking_override = Vector2.RIGHT
	await get_tree().create_timer(0.4).timeout
	game.world.player.walking_override = Vector2.ZERO
	check(game.world.player.position.x>before.x+30,"Physics moves commander")
	game.enter_base()
	game.enter_base()
	await get_tree().create_timer(1.25).timeout
	check(Session.stage==Session.Stage.COMMUNICATIONS,"Airlock reaches communications once")
	check(game.content.get_child_count()==1,"Only one interior exists")
	finish_dialogue(game)
	check(game.world.is_floor(game.world.player.position),"Interior spawn is walkable")
	# Test a real collision against the north wall of command.
	game.world.player.position = Vector2(960,155)
	game.world.player.walking_override = Vector2.UP
	await get_tree().create_timer(0.4).timeout
	game.world.player.walking_override = Vector2.ZERO
	check(game.world.player.position.y>=140,"Walls prevent crossing")
	game.world.player.position = Vector2(960,402)
	await get_tree().physics_frame
	await shot("04-command-1280")
	# All stations must be reachable on the floor graph (including doorway cells).
	var visited := {}
	var queue: Array[Vector2i] = [Vector2i(30,32)]
	while not queue.is_empty():
		var cell: Vector2i = queue.pop_front()
		if visited.has(cell) or not game.world.grid.has(cell): continue
		visited[cell] = true
		for direction in [Vector2i.UP,Vector2i.DOWN,Vector2i.LEFT,Vector2i.RIGHT]: queue.append(cell+direction)
	for station in game.world.interactions:
		check(visited.has(Vector2i(station.position/32)),"Reachable floor: "+station.interaction_id)
		if station.interaction_id in ["radio","shelf_a","shelf_b","lab_console","sample"]:
			var path: PackedVector2Array = game.world.navigator.get_point_path(Vector2i(30,32),Vector2i(station.position/32))
			check(not path.is_empty(),"Obstacle-aware route: "+station.interaction_id)
	game.interact("radio")
	check(not Session.can_move(),"Radio locks movement")
	game.interact("radio")
	check(game.ui.page==0,"Repeated interaction cannot restart dialogue")
	game.ui.page=4
	game.ui.show_page()
	await shot("05-botanist-1280")
	finish_dialogue(game)
	check(Session.presented.size()==5,"Exactly five crew introduced")
	check(Session.stage==Session.Stage.CHOICE,"Reports unlock choice")
	await shot("06-choice-1280")
	game.ui.show_confirmation("storage")
	await shot("07-confirmation-1280")
	game.ui.modal_layer.hide()
	Session.modal=false
	game.select_priority("storage")
	check(Session.choice=="storage","Storage choice recorded")
	check(not Session.select_priority("lab"),"Priority cannot be changed")
	finish_dialogue(game)
	game.interact("shelf_b")
	finish_dialogue(game)
	game.interact("shelf_b")
	finish_dialogue(game)
	check(Session.inspected.size()==1 and Session.filters==0,"Repeated shelf gives no reward")
	game.interact("shelf_a")
	finish_dialogue(game)
	check(Session.filters==1 and Session.records==0,"Storage grants exactly one filter")
	check(Session.stage==Session.Stage.REPORT,"Storage ends with report")
	check(not Session.inspect_shelf("shelf_a"),"Reward is idempotent")
	await shot("08-storage-report-1280")
	game.ui.modal_layer.hide()
	Session.modal=false
	game.explore()
	check(Session.can_move(),"Exploration unlocks after report")
	Session.reduced_motion=true
	await get_tree().process_frame
	await get_tree().process_frame
	for npc in game.world.npcs:
		check(npc.position==npc.get_meta("origin"),"Reduced motion freezes NPC bob")
	Session.reduced_motion=false
	game.start_mission()
	check(Session.filters==0 and Session.choice.is_empty() and Session.presented.is_empty(),"Restart clears progress")
	# Natural ending follows the same lifecycle as Skip.
	landing=game.content.get_child(0)
	landing.clock=9.99
	await get_tree().create_timer(0.1).timeout
	check(Session.stage==Session.Stage.ENTRY,"Natural landing ends correctly")
	finish_dialogue(game)
	game.enter_base()
	await get_tree().create_timer(1.25).timeout
	finish_dialogue(game)
	game.interact("radio")
	finish_dialogue(game)
	game.ui.modal_layer.hide()
	Session.modal=false
	game.select_priority("lab")
	finish_dialogue(game)
	game.interact("sample")
	finish_dialogue(game)
	check(Session.records==0,"Sample requires powered console")
	game.interact("lab_console")
	finish_dialogue(game)
	check(Session.lab_power,"Console powers on")
	game.world.player.position=Vector2(1560,860)
	await get_tree().physics_frame
	await shot("09-laboratory-1280")
	game.interact("sample")
	finish_dialogue(game)
	check(Session.records==1 and Session.filters==0,"Lab gives only scientific record")
	check(not Session.register_sample(),"Sample reward cannot duplicate")
	await shot("10-lab-report-1280")
	if capture:
		DisplayServer.window_set_size(Vector2i(1920,1080))
		get_window().size=Vector2i(1920,1080)
		await get_tree().create_timer(0.2).timeout
		await shot("11-report-1920")
		game.show_menu()
		await get_tree().process_frame
		await shot("12-menu-1920")
	print("KILLA WASI: %d checks, %d failures" % [checks,failures.size()])
	for failure in failures: print("FAIL: "+failure)
	game.ui.clear_all()
	Sound.shutdown()
	await get_tree().create_timer(0.4).timeout
	get_tree().quit(0 if failures.is_empty() else 1)
