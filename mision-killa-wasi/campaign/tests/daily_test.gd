extends Node
const Daily=preload('res://campaign/daily_data.gd')
var checks:=0
var failures:Array=[]
func check(value:bool,message:String)->void:
 checks+=1
 if not value:failures.append(message);print('FAIL: '+message)
func finish(id:String,result:Dictionary={})->void:
 check(Mission.selected==id,'Selected '+id)
 check(Mission.finish_activity(id,result),'Finish '+id)
func choose(id:String)->void:check(Mission.select_task(id),'Choose '+id)
func clear_alarm()->void:Mission.optional.emergency_brief_pending=false
func run(game:Node)->void:
 Mission.emergency_started.disconnect(game.emergency_notice)
 Mission.rescue_requested.disconnect(game.rescued)
 Mission.set_process(false)
 for rank in ['Cadete','Comandante']:
  for priority in ['storage','lab']:
   for water in 2:
    Mission.reset();Mission.rank=rank;Mission.priority=priority;Mission.focused=true
    check(Mission.complete(0),'Meeting')
    check(Mission.blocks==3,'Tutorial budget')
    for id in ['meal','prepare','checkup']:
     choose(id);finish(id)
    check(Mission.selected=='air' and Mission.emergency=='air','Air incident once essentials finish')
    check(Mission.remaining==(135 if rank=='Cadete' else 90),'Rank timer')
    var before:float=Mission.remaining
    Mission.tick(5);check(Mission.remaining==before,'Brief pauses clock')
    clear_alarm();Mission.locks=1;Mission.minigame_running=true
    Mission.tick(3);check(Mission.remaining==before-3,'Minigame ticks')
    Mission.locks=2;Mission.tick(5);check(Mission.remaining==before-3,'Help pauses minigame clock')
    Mission.locks=0;Mission.minigame_running=false
    check(Mission.save_game(),'Save emergency')
    Mission.remaining=1;check(Mission.load_game(),'Load emergency')
    check(Mission.remaining==before-3,'Exact time restores')
    finish('air');check(Mission.blocks==0,'Emergency costs no blocks')
    check(not Mission.finish_activity('air',{}),'Idempotent reward')
    check(Mission.begin_night(),'Night 1');check(Mission.finish_night(),'Day 2')
    check(Mission.day()==2 and Mission.blocks==5,'Day 2 budget')
    check(not Mission.select_task('eva2'),'Suit dependency')
    choose('suit_check');finish('suit_check',{'suit':1})
    check(Mission.can_exit(),'Prepared exit')
    choose('eva2');finish('eva2')
    check(Mission.emergency=='rover','Rover incident')
    clear_alarm();finish('rover')
    check(Mission.optional_action('extra_sample'),'Optional sample')
    check(not Mission.optional_action('extra_sample'),'Sample cannot repeat')
    choose('dust_return');finish('dust_return')
    check(Mission.blocks==1,'One optional block')
    choose('lab2');finish('lab2')
    check(Mission.blocks==0,'Optional block consumed')
    check(Mission.begin_night() and Mission.finish_night(),'Day 3')
    check(not Mission.select_task('eva3'),'Science depends on water and exercise')
    choose('exercise');finish('exercise')
    choose('water');finish('water',{'water':water})
    check(Mission.inventory.cartucho_agua==0,'Water cartridge consumed')
    check(Mission.inventory.filtro_aire==(1 if priority=='storage' else 0),'Air filter distinct')
    check(Mission.inventory.agua_reserva==(2 if water==0 else 3),'Water branch effect')
    choose('grow3');finish('grow3')
    choose('eva3');finish('eva3')
    check(Mission.emergency=='solar','Solar incident')
    clear_alarm();var time:float=Mission.remaining
    finish('solar_choice',{'solar':1});check(Mission.remaining==time-30,'Solar bag costs time')
    finish('solar_lock');finish('shelter_all')
    check(Mission.required_done(),'Day 3 essentials')
    check(Mission.begin_night() and Mission.finish_night(),'Final night')
    check(Mission.phase=='complete' and Mission.optional.green_light,'Green light independent of help')
    check(Mission.inventory.muestras==2,'Samples preserved')
    check(Mission.load_game() and Mission.phase=='complete','Completed save reloads')
 for kind in ['air','rover','solar']:
  Mission.reset();Mission.complete(0);Mission.selected={'air':'air','rover':'rover','solar':'solar_choice'}[kind]
  Mission.start_emergency(kind,1);clear_alarm();Mission.tick(2)
  check(Mission.rescues==[kind],'Rescue '+kind)
  check(Mission.emergency=='' and Mission.selected=='','Rescue frees planning '+kind)
  if kind=='solar':check(Mission.room=='shelter' and 'shelter_all' in Mission.completed,'Solar safe arrival')
  Mission.tick(99);check(Mission.rescues.size()==1,'Rescue unique')
 var words_bad:Array=[]
 check(Daily.audit().is_empty(),'Dialogue and vocabulary audit: '+str(Daily.audit()))
 Mission.reset();Mission.complete(0);Mission.jornada=3;Mission.selected='water';Mission.focused=true
 game.ui.open_minigame(Daily.find('water'))
 var activity=game.ui.active_game
 activity.choose(1);activity.choose(0)
 check(Mission.save_game(),'Save intermediate puzzle')
 game.ui.clear();game.ui.active_game=null
 check(Mission.load_game(),'Load intermediate puzzle')
 game.ui.open_minigame(Daily.find('water'))
 check(game.ui.active_game.stage==1 and game.ui.active_game.pipes[0]==2,'Puzzle restores exact stage and rotation')
 game.ui.clear();game.ui.active_game=null
 var bad:Dictionary=Mission.snapshot().duplicate(true)
 bad.resources.agua=-2;check(not Mission.valid_save(bad),'Reject invalid resource bar')
 for t in Daily.tasks():
  for key in ['instruction','science']:
   check(t[key].split(' ',false).size()<=15,'Text budget '+t.id+' '+key)
  check(not t.science.to_lower().contains('psia'),'No forbidden vocabulary')
 for room in game.Catalog.ROOMS:
  Mission.optional.entered=true
  await game.change_room(room,false)
  game.ui.clear()
  for e in game.world.entries:
   var route:PackedVector2Array=game.world.path(game.hero.position,e.at)
   check(not route.is_empty(),'Reach item '+e.id)
 check(game.hero.speed==200,'Base movement preserved')
 print('DAILY_TEST: %d checks, %d failures'%[checks,failures.size()])
 Audio.shutdown();await get_tree().process_frame;OS.delay_msec(100)
 get_tree().quit(0 if failures.is_empty() else 1)
