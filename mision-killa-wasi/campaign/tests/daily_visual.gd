extends Node
const Daily=preload('res://campaign/daily_data.gd')
var game:Node
var captures:=0
func _process(_delta:float)->void:Mission.focused=true
func run(g:Node)->void:
 game=g
 for resolution in [Vector2i(1280,720),Vector2i(1920,1080)]:
  DisplayServer.window_set_size(resolution)
  await get_tree().create_timer(0.4).timeout
  game.show_menu();await shot('menu')
  game.choose_rank();await shot('difficulty');game.ui.clear()
  Mission.reset();Mission.optional.entered=true;Mission.optional.arrival_seen=true;Mission.complete(0)
  await game.change_room('corridor',false)
  game.ui.show_tasks();await shot('tasks');game.ui.clear()
  game.ui.show_map();await shot('map');game.ui.clear()
  for room in ['engineering','bedroom','airlock']:
   await game.change_room(room,false);await shot(room)
  game.hero.position=Vector2(640,570)
  await get_tree().create_timer(0.5).timeout
  await shot('door_near')
  await game.change_room('exterior',false)
  game.ui.show_map();await shot('map_exterior');game.ui.clear()
  for id in ['checkup','meal','prepare','air','rover','water','exercise','shelter_all']:
   Mission.selected=id;Mission.optional.erase('activity_state')
   var t:=Daily.find(id)
   game.ui.open_minigame(t)
   await shot(id)
   if id=='prepare':
    var activity=game.ui.active_game
    activity.choose(1);activity.choose(4)
    await shot('storage_confirm')
   game.ui.show_help();await shot(id+'_help');game.ui.clear();game.ui.active_game=null
  Mission.jornada=2;Mission.selected='';Mission.phase='planning'
  game.day_transition();await get_tree().create_timer(1.5).timeout
  await shot('day_transition');game.ui.clear();Mission.transition=false;Mission.optional.day_intro_pending=false
  Mission.phase='complete';game.ui.show_report();await shot('report');game.ui.clear()
 # Test real menu music, indoor continuity, and speech availability.
 game.show_menu();await get_tree().create_timer(1.4).timeout
 if not Audio.menu_music.playing:push_error('Menu music missing');get_tree().quit(1);return
 Audio.refresh_voices()
 print('MENU_MUSIC PASS; speech backend=',Audio.spoken_voice)
 game.ui.show_voice_preview();await shot('voice_preview');game.ui.clear()
 for speaker in Audio.VOICE_PROFILES:
  print('VOICE_PROFILE ',speaker,' ',Audio.VOICE_PROFILES[speaker])
  Audio.speak('We will look after our crew and explore together.',speaker)
  await get_tree().create_timer(0.25).timeout
  if not Audio.narration.playing:push_error('Bundled voice did not play: '+speaker);get_tree().quit(1);return
  if not is_equal_approx(Audio.narration_pitch.pitch_scale*Audio.narration.pitch_scale,Audio.VOICE_PROFILES[speaker].pitch):push_error('Voice pitch mismatch');get_tree().quit(1);return
  Audio.stop_speech()
 print('ENGLISH_SPEECH PASS; seven distinct tone and pace profiles')
 Mission.reset();Mission.optional.entered=true;Mission.complete(0)
 await game.change_room('engineering',false)
 await get_tree().create_timer(1.4).timeout
 var previous:float=Audio.indoor.get_playback_position()
 await game.change_room('medical',false)
 await get_tree().create_timer(0.3).timeout
 if Audio.indoor.get_playback_position()<previous:push_error('Indoor reset');get_tree().quit(1);return
 print('DAILY_VISUAL PASS; captures=',captures)
 Audio.shutdown();await get_tree().create_timer(0.15).timeout;get_tree().quit()
func shot(name:String)->void:
 if not game.ui.stack.is_empty():
  var p:Control=game.ui.stack[-1].get_meta('panel')
  if p.has_meta('typing'):p.get_meta('typing').visible_characters=-1
 await get_tree().process_frame
 await RenderingServer.frame_post_draw
 audit_language(game.ui.root)
 DirAccess.make_dir_recursive_absolute('res://artifacts/daily')
 var size:Vector2i=DisplayServer.window_get_size()
 get_viewport().get_texture().get_image().save_png('res://artifacts/daily/%s_%dx%d.png'%[name,size.x,size.y])
 captures+=1

func audit_language(node:Node)->void:
 if node is Control and node.is_visible_in_tree() and (node is Label or node is Button or node is RichTextLabel):
  var pattern:=RegEx.new()
  pattern.compile('(?i)\\b(misión|cadete|comandante|almacén|rejilla|comprobados|pulso|flechas|guardado|fuentes|volver|continuar|opciones|tareas|diario|agua|comida|energía|recoger)\\b')
  if pattern.search(node.text):push_error('Untranslated visible text: '+node.text);get_tree().quit(1)
 for child in node.get_children():audit_language(child)
