extends Node
var game: Node
var keys: Dictionary={KEY_A:"move_left",KEY_D:"move_right",KEY_W:"move_up",KEY_S:"move_down"}
var frames:=0
var branch:=0
var saved_once:=false
var captures:=false

func fail(message: String) -> void:
 push_error("KEYBOARD_TOUR: "+message)
 print("KEYBOARD_TOUR FAILED at ",Mission.current().get("id","end")," in ",Mission.room," position ",game.hero.position)
 release_motion()
 get_tree().quit(1)

func frame() -> void:
 Mission.focused=true
 frames+=1
 await get_tree().physics_frame

func press(key: int, echo:=false) -> void:
 var event:=InputEventKey.new()
 event.keycode=key
 event.physical_keycode=key
 event.pressed=true
 event.echo=echo
 Input.parse_input_event(event)
 await frame()
 event=InputEventKey.new()
 event.keycode=key
 event.physical_keycode=key
 event.pressed=false
 Input.parse_input_event(event)
 await frame()

func release_motion() -> void:
 for action in keys.values(): Input.action_release(action)

func walk_to(target: Vector2) -> bool:
 var path: PackedVector2Array=game.world.path(game.hero.position,target)
 if path.is_empty(): fail("No route to "+str(target)); return false
 for point in path:
  var n:=0
  while game.hero.position.distance_to(point)>5:
   if not game.ui.stack.is_empty():
    release_motion()
    await advance_lines()
   n+=1
   if n>200:
    fail("Movement blocked toward "+str(point)); return false
   var diff: Vector2=point-game.hero.position
   release_motion()
   if diff.x>2: Input.action_press("move_right")
   elif diff.x< -2: Input.action_press("move_left")
   if diff.y>2: Input.action_press("move_down")
   elif diff.y< -2: Input.action_press("move_up")
   await frame()
  release_motion()
 for i in 8: await frame()
 return true

func choose(text: String) -> bool:
 for i in 30:
  var focused: Control=get_viewport().gui_get_focus_owner()
  if focused is Button and focused.text==text:
   await press(KEY_ENTER)
   return true
  await press(KEY_TAB)
 fail("Cannot focus button: "+text)
 return false

func advance_lines() -> void:
 for i in 50:
  if game.ui.stack.is_empty(): return
  var panel: Control=game.ui.stack[-1].get_meta("panel")
  if not panel.has_meta("advance"): return
  await press(KEY_ENTER)
 fail("Dialogue did not finish")

func go_room(destination: String) -> bool:
 for hop in 6:
  if Mission.room==destination: return true
  var next: String="corridor"
  if Mission.room=="exterior": next="airlock"
  elif Mission.room=="hygiene": next="bedroom"
  elif Mission.room=="corridor":
   next=destination
   if destination=="exterior": next="airlock"
   elif destination=="hygiene": next="bedroom"
  elif Mission.room=="airlock" and destination=="exterior": next="exterior"
  elif Mission.room=="bedroom" and destination=="hygiene": next="hygiene"
  var found:=false
  for d in game.world.doors:
   if d.to!=next: continue
   found=true
   if not await walk_to(d.at): return false
   await press(KEY_E)
   await frame()
   await advance_lines()
   break
  if not found: fail("Missing door "+next); return false
 fail("Could not reach room "+destination)
 return false

func run(g: Node) -> void:
 game=g
 captures="--capture" in OS.get_cmdline_user_args()
 var start:=Time.get_ticks_msec()
 for selected in 2:
  branch=selected
  saved_once=false
  game.start_new()
  if not await choose("Omitir alunizaje"): return
  await advance_lines()
  # Only movement and E open the entrance; the first meeting then happens in person.
  if not await go_room("shelter"): return
  await advance_lines()
  if Mission.current().id!="checkup": fail("First entry did not present crew"); return
  while not Mission.current().is_empty():
   var task:=Mission.current()
   print("TOUR ",branch," ",task.id)
   if not await go_room(task.room): return
   var entry: Dictionary={}
   for item in game.world.entries:
    if item.id==task.target: entry=item; break
   if entry.is_empty(): fail("Missing task element "+task.target); return
   if not await walk_to(entry.at): return
   await press(KEY_E)
   var depth: int=game.ui.stack.size()
   await press(KEY_E,true)
   if game.ui.stack.size()!=depth: fail("Held E duplicated panel"); return
   if not await choose("Realizar tarea: "+task.title): return
   await advance_lines()
   if task.id in ["priority","water_filter","solar_choice"]:
    var old_remaining:=Mission.remaining
    await press(KEY_R)
    if captures: await capture(task.id+"_robot")
    await advance_lines()
    if absf(old_remaining-Mission.remaining)>0.1: fail("Help consumed emergency time"); return
   if captures and task.id in ["priority","water_choice","rover_patch"]: await capture(task.id)
   var answer:=maxi(0,int(task.correct))
   if task.id=="priority": answer=branch
   if task.id=="water_choice": answer=branch
   if task.id=="solar_choice": answer=1-branch
   if not await choose(task.choices[answer]): return
   if int(task.correct)<0:
    if not await choose("Confirmar"): return
   if not game.ui.stack.is_empty():
    var panel: Control=game.ui.stack[-1].get_meta("panel")
    var actions: Array=[]
    for child in panel.get_children():
     if child is Button and child.has_meta("action_index"): actions.append(child)
    if not actions.is_empty():
     if task.id=="water_filter":
      await press(KEY_R)
      await advance_lines()
     for action in 3:
      for button in actions:
       if is_instance_valid(button) and button.get_meta("action_index")==action:
        if not await choose(button.text): return
        break
   await advance_lines()
   if not game.ui.stack.is_empty() and not Mission.emergency.is_empty():
    if captures: await capture(task.id+"_alert")
    if not await choose("Entendido · comenzar respuesta"): return
   if task.id=="air_read" and not saved_once:
    saved_once=true
    var old_time:=Mission.remaining
    await press(KEY_ESCAPE)
    if not await choose("Guardar y salir al menú"): return
    if not await choose("Continuar"): return
    if absf(old_time-Mission.remaining)>0.3: fail("Emergency time changed across menu/save/load"); return
   if task.id=="water_test":
    await press(KEY_M)
    if captures: await capture("map")
    if not await choose("Cerrar mapa"): return
   if Mission.current().get("id","")==task.id: fail("Task did not advance"); return
  if Mission.rescues.size()>0: fail("Unexpected timeouts "+str(Mission.rescues)); return
  if captures: await capture("report")
  game.ui.clear()
  # Explore every system after campaign, including nonessential rooms.
  for room in ["hygiene","medical","engineering","command","crops","minerals","shelter","bedroom","gym","airlock"]:
   if not await go_room(room): return
   for item in game.world.entries:
    if item.id in Mission.visited or item.id=="vent": continue
    if not await walk_to(item.at): return
    await press(KEY_E)
    await press(KEY_ESCAPE)
  if Mission.visited.size()!=26: fail("Not all 26 systems reachable by keyboard"); return
  print("KEYBOARD_BRANCH ",branch," PASS; simulated_seconds=",snappedf(Mission.play_seconds,0.1))
 print("KEYBOARD_TOUR PASS: two campaigns, all 26 items; frames=",frames," elapsed_seconds=",(Time.get_ticks_msec()-start)/1000.0)
 Audio.shutdown()
 await get_tree().process_frame
 OS.delay_msec(100)
 get_tree().quit()

func capture(name: String) -> void:
 if branch!=0: return
 await get_tree().process_frame
 await RenderingServer.frame_post_draw
 DirAccess.make_dir_recursive_absolute("res://artifacts")
 get_viewport().get_texture().get_image().save_png("res://artifacts/tour_"+name+".png")
