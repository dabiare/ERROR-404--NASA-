extends Node
const Story=preload("res://campaign/story.gd")
const Catalog=preload("res://campaign/catalog.gd")
const Art=preload("res://campaign/art.gd")
const Actor=preload("res://campaign/actor.gd")
var world: Node2D
var holder: Node2D
var hero: CharacterBody2D
var robot: CharacterBody2D
var camera: Camera2D
var ui: CanvasLayer
var menu: Control
var landing: Node2D
var landing_elapsed:=0.0
var landing_ship: Sprite2D
var landing_active:=false
var landing_dust:=false
var generation:=0
var conversation_counts: Dictionary={}
var last_step:=-1
var ui_script_path:='res://campaign/ui.gd'

func _ready() -> void:
 get_tree().auto_accept_quit=false
 configure_input()
 holder=Node2D.new()
 add_child(holder)
 hero=Actor.new()
 hero.identity="commander"
 hero.controlled=true
 holder.add_child(hero)
 robot=Actor.new()
 robot.identity="robot"
 robot.robot=true
 robot.speed=225
 holder.add_child(robot)
 camera=Camera2D.new()
 camera.position=Vector2(640,360)
 holder.add_child(camera)
 ui=load(ui_script_path).new()
 ui.game=self
 add_child(ui)
 Mission.changed.connect(on_changed)
 Mission.emergency_started.connect(emergency_notice)
 Mission.rescue_requested.connect(rescued)
 show_menu()
 if "--campaign-test" in OS.get_cmdline_user_args(): call_deferred("run_tests")
 if "--keyboard-tour" in OS.get_cmdline_user_args(): call_deferred("run_keyboard_tour")
 if "--presentation-test" in OS.get_cmdline_user_args(): call_deferred("run_presentation_tests")

func configure_input() -> void:
 var keys:={"move_left":[KEY_A,KEY_LEFT],"move_right":[KEY_D,KEY_RIGHT],"move_up":[KEY_W,KEY_UP],"move_down":[KEY_S,KEY_DOWN],"interact":[KEY_E],"dialogue_next":[KEY_ENTER,KEY_SPACE],"pause":[KEY_ESCAPE],"help":[KEY_R],"map":[KEY_M]}
 for action in keys:
  if not InputMap.has_action(action): InputMap.add_action(action)
  for key in keys[action]:
   for physical in [true,false]:
    var event:=InputEventKey.new()
    if physical: event.physical_keycode=key
    else: event.keycode=key
    if not InputMap.action_has_event(action,event): InputMap.action_add_event(action,event)

func clean_world() -> void:
 generation+=1
 if is_instance_valid(world): holder.remove_child(world); world.queue_free(); world=null
 if is_instance_valid(landing): holder.remove_child(landing); landing.queue_free(); landing=null
 if is_instance_valid(menu): ui.root.remove_child(menu); menu.queue_free(); menu=null

func show_menu() -> void:
 Mission.active=false
 Mission.transition=false
 landing_active=false
 clean_world()
 hero.hide(); robot.hide()
 ui.clear()
 camera.position=Vector2(640,360)
 camera.position_smoothing_enabled=false
 camera.limit_left=-100000; camera.limit_top=-100000
 camera.limit_right=100000; camera.limit_bottom=100000
 menu=Control.new()
 menu.size=Vector2(1280,720)
 ui.root.add_child(menu)
 ui.picture(menu,load("res://Base Lunar Killa Wasi con Paneles Solares.png"),Rect2(0,0,1280,720)).stretch_mode=TextureRect.STRETCH_KEEP_ASPECT_COVERED
 var shade:=ColorRect.new()
 shade.color=Color(0.025,0.055,0.11,0.62)
 shade.size=Vector2(1280,720)
 menu.add_child(shade)
 ui.label(menu,"ERROR 404  /  THREE-DAY CAMPAIGN",Rect2(70,60,800,35),18,Color("70dfdf"))
 ui.label(menu,"MISSION\nKILLA WASI",Rect2(65,135,800,210),64)
 ui.label(menu,"Five specialists. One curious robot.\nYour first three days in charge.",Rect2(70,355,720,90),25,Color("cedcea"))
 ui.label(menu,"WASD or arrows · E interact · R help · M map",Rect2(70,650,1050,35),18)
 ui.button(menu,"New mission",Rect2(870,220,310,60),new_mission_confirmation).grab_focus()
 var cont: Button=ui.button(menu,"Continue",Rect2(870,295,310,60),continue_game)
 cont.disabled=not FileAccess.file_exists(Mission.save_path) and not FileAccess.file_exists(Mission.save_path+".bak")
 ui.button(menu,"Options",Rect2(870,370,310,60),ui.show_pause)
 ui.button(menu,"Quit",Rect2(870,445,310,60),func(): get_tree().quit())

func new_mission_confirmation() -> void:
 if not FileAccess.file_exists(Mission.save_path) and not FileAccess.file_exists(Mission.save_path+".bak"): start_new(); return
 var p: Control=ui.push("NEW MISSION",Rect2(240,190,800,340))
 ui.label(p,"La nueva partida reemplazará el progreso guardado. ¿Quieres comenzar desde el alunizaje?",Rect2(35,100,730,110),23)
 ui.button(p,"Comenzar de nuevo",Rect2(35,245,350,55),func(): ui.pop(); start_new()).grab_focus()
 ui.button(p,"Conservar mi partida",Rect2(410,245,350,55),ui.pop)

func start_new() -> void:
 clean_world()
 ui.clear()
 Mission.reset()
 Mission.transition=true
 Mission.save_game()
 landing=Node2D.new()
 holder.add_child(landing)
 var bg:=Sprite2D.new()
 bg.texture=load("res://Base Lunar Killa Wasi con Paneles Solares.png")
 bg.centered=false
 bg.scale=Vector2(1280,720)/bg.texture.get_size()
 landing.add_child(bg)
 landing_ship=Sprite2D.new()
 landing_ship.texture=Art.prop(8)
 landing_ship.scale=Vector2(150,180)/landing_ship.texture.get_size()
 landing_ship.position=Vector2(420,-100)
 landing.add_child(landing_ship)
 landing_elapsed=0
 landing_dust=false
 landing_active=true
 menu=Control.new()
 ui.root.add_child(menu)
 ui.label(menu,"ARRIVING AT KILLA WASI",Rect2(55,140,800,60),36)
 ui.label(menu,"Day 1 / A 30-day mission starts with one step.",Rect2(55,205,1050,50),22)
 ui.button(menu,"Skip landing",Rect2(960,595,260,55),finish_landing).grab_focus()

func finish_landing() -> void:
 if not landing_active: return
 landing_active=false
 Mission.transition=false
 await change_room("exterior",false)
 arrival_context()

func arrival_context() -> void:
 ui.show_lines(Story.ARRIVAL,func():
  Mission.optional.arrival_seen=true
  Mission.save_game())

func continue_game() -> void:
 if Mission.load_game():
  ui.clear()
  await change_room(Mission.room,false,true)
  if Mission.optional.get("emergency_brief_pending",false) and not Mission.emergency.is_empty(): emergency_brief()
  elif not Mission.optional.get("arrival_seen",false) and Mission.room=="exterior": arrival_context()
  ui.toast("Save restored · Check Tasks for your next step.")
 else:
  var p: Control=ui.push("RECOVER SAVE")
  ui.label(p,"We could not read your save. Try the backup or start a new mission.",Rect2(35,100,900,150),23)
  ui.button(p,"Recover backup",Rect2(35,300,900,55),func():
   if Mission.load_game(true):
    ui.clear()
    await change_room(Mission.room,false,true)
    if Mission.optional.get("emergency_brief_pending",false) and not Mission.emergency.is_empty(): emergency_brief()
    elif not Mission.optional.get("arrival_seen",false) and Mission.room=="exterior": arrival_context()
   else: ui.toast("No working backup found. You can start a new mission.")).grab_focus()
  ui.button(p,"New mission",Rect2(35,375,900,55),func(): ui.clear(); start_new())
  ui.button(p,"Back",Rect2(35,440,900,45),ui.pop)

func change_room(next: String, through_door:=true, loading:=false) -> void:
 if not Catalog.ROOMS.has(next): return
 Mission.transition=true
 var previous:=Mission.room
 var old_position:=Mission.position
 if not Mission.test_mode:
  var tween:=create_tween()
  tween.tween_property(ui.fade,"color:a",1.0,0.18)
  await tween.finished
 clean_world()
 Mission.room=next
 world=load("res://campaign/rooms/"+next+".tscn").instantiate()
 holder.add_child(world)
 if through_door: Mission.position=world.destination_spawn(previous)
 elif loading: Mission.position=old_position
 elif next=="exterior": Mission.position=Vector2(960,545)
 else: Mission.position=Vector2(640,560)
 world.bind_actors(hero,robot)
 if next=="exterior":
  world.meteor.finished.connect(func():
   if Mission.active and Mission.room=="exterior":
    ui.show_lines([["geologist","A distant flash! A rock hit the surface. The Moon has no thick atmosphere to slow it."],["geologist","We will stay on our safe route. Rock impacts and solar particle alerts are different."]]))
 hero.show(); robot.show()
 hero.velocity=Vector2.ZERO
 robot.route=PackedVector2Array()
 camera.position_smoothing_enabled=next=="exterior" and not Mission.reduced_motion
 camera.position_smoothing_speed=5
 camera.limit_left=0; camera.limit_top=0
 camera.limit_right=2172 if next=="exterior" else 1280
 camera.limit_bottom=724 if next=="exterior" else 720
 camera.position=hero.position if next=="exterior" else Vector2(640,360)
 camera.reset_smoothing()
 Mission.position=hero.position
 Mission.save_game()
 if not Mission.test_mode:
  var tween:=create_tween()
  tween.tween_property(ui.fade,"color:a",0.0,0.18)
  await tween.finished
 Mission.transition=false
 ui.fade.color.a=0
 if next=="airlock" and not Mission.optional.get("entered",false):
  Mission.optional.entered=true
  ui.show_lines([["commander","Pressure checked. The crew is waiting to meet me in the common room."]],func():
   await change_room("shelter",false)
   hero.position=Vector2(640,435)
   robot.position=Vector2(600,450)
   begin_task())

func _unhandled_input(event: InputEvent) -> void:
 if event is InputEventKey and event.echo: return
 if event.is_action_pressed("interact") and Mission.movable() and is_instance_valid(world):
  get_viewport().set_input_as_handled()
  if not world.nearest.is_empty(): interact(world.nearest)

func interact(entry: Dictionary) -> void:
 if not Mission.movable(): return
 if entry.get("door",false):
  if entry.to=="exterior" and not Mission.can_exit():
   ui.show_lines([["engineer","Antes de salir necesitamos traje, enlace y preparación de presión. Sigue el objetivo y volveremos aquí cuando todo esté listo."]]); return
  change_room(entry.to)
 elif entry.get("npc",false):
  var id: String=entry.id
  var n:=int(conversation_counts.get(id,0))
  conversation_counts[id]=n+1
  for npc in world.npc_actors:
   if npc.identity==id: npc.facing=signf(hero.position.x-npc.position.x)
  ui.show_lines([[id,Catalog.CHATS[id][n%Catalog.CHATS[id].size()]]])
 else:
  if not Catalog.find_item(entry.id).is_empty() and not entry.id in Mission.visited:
   Mission.visited.append(entry.id)
   Mission.save_game()
  ui.show_item(entry)

func begin_task() -> void:
 var t:=Mission.current()
 if t.is_empty(): ui.show_report(); return
 if Mission.room!=t.room: return
 if t.id=="meeting":
  ui.show_lines(Story.MEETING,func(): Mission.complete(0); refresh_npcs(),true)
 else: ui.show_lines([[t.speaker,t.intro]],ui.show_task)

func perform_task(answer: int) -> void:
 var t:=Mission.current()
 if t.is_empty(): return
 var physical: Dictionary={
  "prepare":["Leer etiqueta","Comparar con el registro","Guardar el resultado"],
  "air_clear":["Modo seguro","Retirar obstrucción","Revisar el filtro"],
  "air_on":["Activar ventilador","Observar flujo","Comparar CO₂"],
  "rover_patch":["Seleccionar lámina","3 · Secure and check the clamps","Comprobar distancia a la rueda"],
  "rover_test":["Comprobar cobertura","Comprobar sujeción","Verificar que no roce"],
  "sample2":["Anotar ubicación","Tomar registro","Etiquetar muestra"],
  "dust_return":["Aislar zona sucia","Retirar y contener polvo","Comprobar limpieza"],
  "water_filter":["Aislar circuito","Instalar cartucho de agua","Restablecer circuito"],
  "water_test":["Tomar lectura","Comprobar calidad","Habilitar suministro"],
  "exercise_force":["Ajustar resistencia","Movimiento controlado","Registrar la sesión"],
  "exercise_cardio":["Ajustar bicicleta","Observar el pulso","Descansar y registrar"],
  "shelter_all":["Contar cinco tripulantes","Cerrar refugio","Confirmar comunicación"]
 }
 if physical.has(t.id): activity(t,physical[t.id],func(): finish_task(t,answer))
 else: finish_task(t,answer)

func activity(t: Dictionary, actions: Array, done: Callable) -> void:
 var p: Control=ui.push("PUESTA EN PRÁCTICA · "+t.title)
 var count: Array=[0]
 p.set_meta("next_action",actions[0])
 ui.label(p,"Completa las acciones en orden.\nPuedes pedir ayuda con R en cualquier momento.",Rect2(35,95,890,70),22)
 var status_label: Label=ui.label(p,"0 / 3 pasos comprobados",Rect2(35,175,890,35),22,Color("74e1c6"))
 var order: Array=[2,0,1]
 for i in 3:
  var action_index: int=order[i]
  var b: Button=ui.button(p,actions[action_index],Rect2(35,235+i*65,895,52),func():
   if action_index!=count[0]:
    ui.show_lines([[t.speaker,"Primero necesitamos: «%s». El orden evita dejar algo sin comprobar." % actions[count[0]]]])
    return
   count[0]+=1
   if count[0]<actions.size(): p.set_meta("next_action",actions[count[0]])
   Audio.confirm()
   status_label.text="%d / 3 pasos comprobados" % count[0]
   if count[0]>=3: ui.pop(); done.call())
  b.set_meta("action_index",action_index)
  if i==1: b.grab_focus()
 ui.button(p,"Volver a la tarea",Rect2(35,445,895,40),func(): ui.pop(); ui.show_task())

func finish_task(t: Dictionary, answer: int) -> void:
 if Mission.current().get("id","")!=t.id: return
 if not Mission.complete(answer): return
 Audio.confirm()
 refresh_npcs()
 ui.show_lines([[t.speaker,t.success]],func():
  if t.id=="final_report": ui.show_report()
  elif t.id in ["day1_report","day2_report"]:
   ui.show_lines([["control","Día %d. Una nueva jornada comienza; consulta tu objetivo y al equipo." % Mission.day()]])
  if t.id in ["bedtime","rover_notice","survey3"] and not Mission.emergency.is_empty(): emergency_brief())

func emergency_notice(_kind: String) -> void:
 hero.surprise(); robot.surprise()
 if is_instance_valid(world):
  for npc in world.npc_actors: npc.surprise()

func emergency_brief() -> void:
 var kind:=Mission.emergency
 var messages:={"air":"Ventilación reducida en el dormitorio: revisa el sensor, despeja la rejilla y comprueba el flujo.","rover":"Reparación del rover: elige el parche, sujétalo y verifica que no roce la rueda.","solar":"Alerta de partículas solares: vuelve por la esclusa y reúne a todos en el refugio."}
 var p: Control=ui.push("ALERTA · EL EQUIPO ESTÁ RESPONDIENDO")
 p.set_meta("required_ack",true)
 for i in 6:
  var id: String=["commander","engineer","botanist","doctor","geologist","robot"][i]
  var pic: TextureRect=ui.picture(p,Art.face(id),Rect2(40+i*150,90,120,140))
  ui.label(p,"!",Rect2(130+i*150,95,25,35),30,Color("f6ca68"))
  if not Mission.reduced_motion:
   var tw:=create_tween()
   tw.tween_property(pic,"position:y",82.0,0.15)
   tw.tween_property(pic,"position:y",90.0,0.2)
 ui.label(p,messages[kind],Rect2(35,250,900,100),24)
 ui.label(p,"El reloj es un reto del juego. Se detiene al leer, pedir ayuda o pausar.",Rect2(35,355,900,45),17,Color("bad0e3"))
 ui.button(p,"Entendido · comenzar respuesta",Rect2(35,425,900,55),func():
  Mission.optional.emergency_brief_pending=false
  Mission.save_game()
  ui.pop()).grab_focus()

func rescued(kind: String) -> void:
 ui.clear()
 var messages:={"air":"El ingeniero restableció la ventilación usando un repuesto de reserva. Revisaremos juntos el procedimiento en el informe.","rover":"El equipo completó la reparación con material de reserva. Documentaremos la muestra principal y cancelamos la muestra extra para regresar a tiempo.","solar":"Control coordinó el regreso asistido. Llegamos al refugio, dejamos las muestras de esta salida y usamos una reserva para la atención del equipo."}
 if kind=="solar": await change_room("shelter",false)
 ui.show_lines([["control",messages[kind]]])
 refresh_npcs()

func refresh_npcs() -> void:
 if not is_instance_valid(world): return
 for npc in world.npc_actors:
  world.remove_child(npc)
  npc.queue_free()
 world.npc_actors.clear()
 world.populate_npcs()

func on_changed() -> void:
 if last_step!=Mission.step:
  last_step=Mission.step
  if is_instance_valid(ui): ui.toast("Objetivo actualizado")

func _process(delta: float) -> void:
 if landing_active and Mission.focused and Mission.locks==0:
  landing_elapsed+=delta
  landing_ship.position=Vector2(420,lerpf(-100,510,smoothstep(0,1,minf(1,landing_elapsed/8))))
  if landing_elapsed>=8 and not landing_dust:
   landing_dust=true
   if not Mission.reduced_motion:
    var dust:=CPUParticles2D.new()
    dust.position=Vector2(420,570)
    dust.amount=18
    dust.lifetime=1.5
    dust.one_shot=true
    dust.explosiveness=1.0
    dust.direction=Vector2(0,-1)
    dust.spread=85
    dust.gravity=Vector2(0,25)
    dust.initial_velocity_min=35
    dust.initial_velocity_max=85
    dust.scale_amount_min=2
    dust.scale_amount_max=5
    dust.color=Color(0.67,0.69,0.75,0.65)
    landing.add_child(dust)
    dust.emitting=true
  if landing_elapsed>=10: finish_landing()
 if not Mission.active or not is_instance_valid(world): return
 if Mission.room=="exterior": camera.position=hero.position
 camera.position_smoothing_enabled=Mission.room=="exterior" and not Mission.reduced_motion
 Mission.position=hero.position
 var target: String=Mission.current().get("room","")
 var prompt: String="E · "+world.nearest.title if not world.nearest.is_empty() else "WASD / Flechas · Mover"
 if target!=Mission.room and target!="": prompt+="   →   "+Catalog.ROOMS[target]
 ui.hint.text=prompt

func _notification(what: int) -> void:
 if what==NOTIFICATION_WM_CLOSE_REQUEST:
  if Mission.active:
   Mission.position=hero.position
   Mission.save_game()
  get_tree().quit()

func run_tests() -> void:
 var suite=load("res://campaign/tests/campaign_test.gd").new()
 add_child(suite)
 await suite.run(self)

func run_keyboard_tour() -> void:
 var suite=load("res://campaign/tests/keyboard_tour.gd").new()
 add_child(suite)
 await suite.run(self)

func _exit_tree() -> void:
 Audio.shutdown()

func run_presentation_tests() -> void:
 var suite=load("res://campaign/tests/presentation_test.gd").new()
 add_child(suite)
 await suite.run(self)
