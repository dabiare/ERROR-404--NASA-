extends Node
const Catalog=preload("res://campaign/catalog.gd")
const Story=preload("res://campaign/story.gd")
var failures: Array[String]=[]
var checks:=0
var game: Node

func check(value: bool, message: String) -> void:
 checks+=1
 if not value:
  failures.append(message)
  print("FAIL: "+message)

func run(g: Node) -> void:
 game=g
 Mission.emergency_started.disconnect(game.emergency_notice)
 Mission.rescue_requested.disconnect(game.rescued)
 Mission.set_process(false)
 Mission.reset()
 Mission.optional.entered=true
 Mission.focused=true
 check(Catalog.items().size()==26,"26 systems in catalog")
 var ids: Array=[]
 for e in Catalog.items():
  check(not e.id in ids,"Unique item "+e.id)
  ids.append(e.id)
 var reached: Array=[]
 for room in Catalog.ROOMS:
  await game.change_room(room,false)
  game.ui.clear()
  Mission.optional.entered=true
  await get_tree().physics_frame
  check(game.hero.position.distance_to(game.world.safe_position(game.hero.position))<2,"Safe spawn "+room)
  for e in game.world.entries:
   var path: PackedVector2Array=game.world.path(game.hero.position,e.at)
   check(not path.is_empty(),"Reachable item "+e.id)
   if path.is_empty(): print("route ",game.hero.position," -> ",e.at," safe ",game.world.safe_position(e.at))
   if not path.is_empty(): check(path[-1].distance_to(e.at)<80,"Interactable distance "+e.id)
   if e.id in ids: reached.append(e.id)
  for d in game.world.doors:
   var path: PackedVector2Array=game.world.path(game.hero.position,d.at)
   check(not path.is_empty(),"Reachable door "+room+" -> "+d.to)
   if not path.is_empty(): check(path[-1].distance_to(d.at)<80,"Door activation distance "+d.to)
   var other=load("res://campaign/rooms/"+d.to+".tscn").instantiate()
   add_child(other)
   check(other.doors.any(func(back): return back.to==room),"Reciprocal door "+room+" -> "+d.to)
   other.free()
  if "--capture" in OS.get_cmdline_user_args(): await capture(room)
  if room=="exterior" and not failures.is_empty():
   for y in range(20,36):
    var row:=""
    for x in range(40,90): row+="#" if game.world.nav.is_point_solid(Vector2i(x,y)) else "."
    print(row)
 check(reached.size()==26,"All 26 items available in rooms")
 game.ui.clear()
 Mission.transition=false
 for priority in 2:
  for water in 2:
   for solar in 2:
    Mission.reset()
    var guard:=0
    while not Mission.current().is_empty() and guard<100:
     guard+=1
     var t:=Mission.current()
     var answer:=maxi(0,int(t.correct))
     if t.id=="priority": answer=priority
     if t.id=="water_choice": answer=water
     if t.id=="solar_choice": answer=solar
     if t.correct>=0 and t.choices.size()>1:
      var before:=Mission.step
      check(not Mission.complete((answer+1)%t.choices.size()) and Mission.step==before,"Wrong answer doesn't progress "+t.id)
     check(Mission.complete(answer),"Complete "+t.id)
     if t.id=="prepare":
      var key: String="storage_later" if priority==1 else "lab_later"
      check(Mission.optional_action(key),"Pending preparation")
      check(not Mission.optional_action(key),"No duplicate preparation")
     if t.id=="sample2":
      check(Mission.optional_action("extra_sample"),"Optional science")
      check(not Mission.optional_action("extra_sample"),"No duplicate sample")
    check(guard==Story.tasks().size(),"Full campaign reaches final report")
    check(Mission.inventory.cartucho_agua==0 and Mission.inventory.filtro_aire==1,"Water and air parts remain distinct")
    check(Mission.inventory.agua_reserva==(2 if water==0 else 3),"Water decision consequence")
    check(Mission.inventory.muestras==(3 if solar==1 else 2),"Solar samples consequence")
    check(Mission.rescues.is_empty(),"No spurious rescue")
    check(not Mission.complete(0),"Final reward cannot repeat")
    check(Mission.emergency.is_empty(),"No final alarm")
    check(Mission.load_game(),"Reload complete campaign")
    check(Mission.current().is_empty(),"Completion persisted")
 for kind in ["air","rover","solar"]:
  Mission.reset()
  while Mission.emergency!=kind:
   var t:=Mission.current()
   check(not t.is_empty(),"Reach rescue setup")
   if t.is_empty(): break
   Mission.complete(maxi(0,int(t.correct)))
  var before:=Mission.remaining
  Mission.tick(20)
  check(Mission.remaining==before,"Timer waits for briefing "+kind)
  Mission.optional.emergency_brief_pending=false
  Mission.locks=1
  Mission.tick(20)
  check(Mission.remaining==before,"Timer pauses for dialogue "+kind)
  Mission.locks=0
  Mission.transition=true
  Mission.tick(20)
  check(Mission.remaining==before,"Timer pauses for transition "+kind)
  Mission.transition=false
  Mission.focused=false
  Mission.tick(20)
  check(Mission.remaining==before,"Timer pauses for lost focus "+kind)
  Mission.focused=true
  Mission.tick(7.25)
  check(is_equal_approx(Mission.remaining,before-7.25),"Timer advances "+kind)
  check(Mission.save_game(),"Save during emergency "+kind)
  Mission.remaining=1
  check(Mission.load_game(),"Load during emergency "+kind)
  check(is_equal_approx(Mission.remaining,before-7.25),"Exact remaining time restored "+kind)
  Mission.tick(1000)
  check(Mission.rescues==[kind],"One rescue "+kind)
  Mission.tick(1000)
  check(Mission.rescues.size()==1,"Rescue cannot repeat "+kind)
  check(Mission.emergency.is_empty(),"Rescue stops timer "+kind)
  check(Mission.current().id=={"air":"day1_report","rover":"sample2","solar":"dose_check"}[kind],"Rescue advances safely "+kind)
  if kind=="rover": check(not Mission.optional_action("extra_sample"),"Rescue cancels optional sample")
  while not Mission.current().is_empty():
   Mission.complete(maxi(0,int(Mission.current().correct)))
  check(Mission.current().is_empty(),"Can finish after rescue "+kind)
 var bad: Dictionary=Mission.snapshot().duplicate(true)
 bad.inventory.cartucho_agua=-1
 check(not Mission.valid_save(bad),"Reject invalid inventory")
 check(not Mission.valid_save({"version":999}),"Reject incompatible save")
 Mission.save_game()
 var file:=FileAccess.open(Mission.save_path,FileAccess.WRITE)
 file.store_string("broken save")
 file.close()
 check(not Mission.load_game(),"Corruption detected")
 check(Mission.load_game(true),"Backup recovery")
 Mission.reset()
 check(Mission.completed.is_empty() and Mission.inventory.muestras==0 and Mission.priority=="","New mission resets all progress")
 check(game.hero.speed==200,"Improved base speed preserved")
 check(game.hero.sprite.sprite_frames.get_frame_count("walk")==3,"Improved walking frames preserved")
 check(game.hero.sprite.sprite_frames.get_animation_speed("walk")==8,"Walking cadence preserved")
 print("CAMPAIGN_TEST: %d checks, %d failures" % [checks,failures.size()])
 var words:=0
 for t in Story.tasks():
  for text in [t.intro,t.question,t.success]+t.choices: words+=str(text).split(" ",false).size()
 for e in Catalog.items(): words+=e.description.split(" ",false).size()
 for line in Story.ARRIVAL+Story.MEETING: words+=line[1].split(" ",false).size()
 print("READING_BUDGET: ",words," words in primary dialogue, questions, choices and 26 item descriptions; optional pages excluded")
 Audio.shutdown()
 await get_tree().process_frame
 OS.delay_msec(100)
 get_tree().quit(0 if failures.is_empty() else 1)

func capture(name: String) -> void:
 await get_tree().process_frame
 await RenderingServer.frame_post_draw
 var dir:="res://artifacts"
 DirAccess.make_dir_recursive_absolute(dir)
 get_viewport().get_texture().get_image().save_png(dir+"/"+name+".png")
