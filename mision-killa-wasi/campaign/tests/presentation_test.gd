extends Node
const Story=preload("res://campaign/story.gd")
var game: Node
var suffix:=""
var checks:=0
var failures: Array=[]

func check(value: bool, text: String) -> void:
 checks+=1
 if not value: failures.append(text); print("FAIL: "+text)

func _process(_delta: float) -> void:
 Mission.focused=true

func run(g: Node) -> void:
 game=g
 Mission.reset()
 Mission.optional.entered=true
 Mission.optional.arrival_seen=true
 for resolution in [Vector2i(1280,720),Vector2i(1920,1080)]:
  DisplayServer.window_set_size(resolution)
  suffix="_%dx%d" % [resolution.x,resolution.y]
  await get_tree().create_timer(0.4).timeout
  game.show_menu()
  await capture("menu")
  Mission.active=true
  Mission.completed.clear()
  Mission.step=0
  await game.change_room("shelter",false)
  await capture("meeting_room")
  game.hero.position=Vector2(640,435)
  game.ui.show_lines(Story.MEETING,Callable(),true)
  await capture("dialogue")
  game.ui.clear()
  for id in ["priority","water_choice","solar_choice"]:
   set_task(id)
   await game.change_room(Mission.current().room,false)
   game.ui.show_task()
   await capture(id)
   game.ui.show_help()
   await capture(id+"_robot")
   game.ui.clear()
  Mission.start_emergency("solar",180)
  game.emergency_brief()
  await capture("alarm")
  game.ui.clear()
  Mission.emergency=""
  game.ui.show_map()
  await capture("map")
  game.ui.clear()
  game.ui.show_pause()
  await capture("options")
  game.ui.clear()
  for room in ["bedroom","hygiene","engineering","crops","gym","airlock","exterior"]:
   await game.change_room(room,false)
   await capture(room)
  game.ui.show_report()
  await capture("report")
  game.ui.clear()
 # Check the game-facing rescue callbacks as well as the model tests.
 for kind in ["air","rover","solar"]:
  Mission.reset()
  Mission.optional.entered=true
  var starts:={"air":"air_read","rover":"rover_patch","solar":"solar_choice"}
  set_task(starts[kind])
  await game.change_room(Mission.current().room,false)
  Mission.start_emergency(kind,1)
  Mission.optional.emergency_brief_pending=false
  Mission.tick(2)
  await get_tree().process_frame
  check(kind in Mission.rescues,"Rescue callback records "+kind)
  check(not game.ui.stack.is_empty(),"Rescue explains consequence "+kind)
  if kind=="solar": check(Mission.room=="shelter" and game.world.room_id=="shelter","Solar rescue loads shelter")
  await capture("rescue_"+kind)
  game.ui.clear()
 # Exercise actual audio playback on the graphics/audio backend.
 set_task("water_read")
 await game.change_room("engineering",false)
 await get_tree().create_timer(1.4).timeout
 check(Audio.indoor.playing and not Audio.indoor.stream_paused,"Indoor track plays")
 var time_before: float=Audio.indoor.get_playback_position()
 await game.change_room("medical",false)
 await get_tree().create_timer(0.3).timeout
 check(Audio.indoor.get_playback_position()>=time_before,"Indoor track does not restart between rooms")
 for key in ["music","effects","voice"]:
  Mission.settings[key]=0
 Audio.set_levels()
 for bus in ["Music","Effects","Voice"]: check(AudioServer.is_bus_mute(AudioServer.get_bus_index(bus)),"Volume mute "+bus)
 Mission.settings={"music":0.55,"effects":0.65,"voice":0.4,"reduced_motion":false}
 Audio.set_levels()
 Mission.start_emergency("air",90)
 await get_tree().create_timer(1.3).timeout
 check(Audio.tension.playing and not Audio.tension.stream_paused,"Emergency soundtrack plays")
 check(Audio.indoor.stream_paused,"Normal music pauses after fade")
 Audio.blip()
 check(Audio.voice.playing,"Robot voice plays")
 check(Audio.voice.stream.get_length()>0,"Robot sound has samples")
 Audio.voice.stop()
 Mission.emergency=""
 Mission.completed=Story.tasks().map(func(t): return t.id)
 Mission.step=Story.tasks().size()
 await game.change_room("exterior",false)
 await get_tree().create_timer(1.3).timeout
 check(Audio.outside_wait>=13 and Audio.outside_wait<=35,"Random exterior first interval")
 # Wait the real randomly chosen first interval; no fake playback or timer override.
 var wait_budget:=40.0
 while not Audio.outdoor.playing and wait_budget>0:
  await get_tree().create_timer(0.5).timeout
  wait_budget-=0.5
 check(Audio.outdoor.playing,"Exterior music begins after silence")
 Audio.outdoor.finished.emit()
 check(Audio.outside_wait>=45 and Audio.outside_wait<=90,"Exterior subsequent interval")
 Mission.reduced_motion=true
 game.ui.refresh_icon(true)
 check(game.ui.current_icon.scale.is_equal_approx(Vector2.ONE),"Reduced motion stops HUD pulse")
 await get_tree().process_frame
 await get_tree().process_frame
 check(not game.camera.position_smoothing_enabled,"Reduced motion stops camera smoothing")
 # Record the mix for the team's listening review, using the real audio backend.
 var record:=AudioEffectRecord.new()
 AudioServer.add_bus_effect(0,record)
 record.set_recording_active(true)
 Audio.alarm_once()
 await get_tree().create_timer(2.0).timeout
 record.set_recording_active(false)
 var sample:=record.get_recording()
 sample.save_to_wav("res://artifacts/audio_mix_test.wav")
 check(sample.data.size()>0,"Audio mix captured")
 AudioServer.remove_bus_effect(0,0)
 print("PRESENTATION_TEST: %d checks, %d failures; captures at 1280x720 and 1920x1080" % [checks,failures.size()])
 Audio.shutdown()
 await get_tree().create_timer(0.15).timeout
 get_tree().quit(0 if failures.is_empty() else 1)

func set_task(id: String) -> void:
 Mission.step=0
 Mission.completed.clear()
 for task in Story.tasks():
  if task.id==id: break
  Mission.completed.append(task.id)
  Mission.step+=1

func capture(name: String) -> void:
 if not game.ui.stack.is_empty():
  var p: Control=game.ui.stack[-1].get_meta("panel")
  if p.has_meta("typing"): p.get_meta("typing").visible_characters=-1
 await get_tree().process_frame
 await RenderingServer.frame_post_draw
 DirAccess.make_dir_recursive_absolute("res://artifacts")
 var result:=get_viewport().get_texture().get_image().save_png("res://artifacts/qa_"+name+suffix+".png")
 check(result==OK,"Capture "+name+suffix)
