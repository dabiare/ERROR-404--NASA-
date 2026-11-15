extends "res://campaign/mission.gd"
const Daily=preload('res://campaign/daily_data.gd')
var jornada:=1
var phase:='arrival'
var selected:=''
var blocks:=3
var rank:="Cadet"
var robot_name:="Guide robot"
var resources:Dictionary={'oxigeno':100,'agua':100,'comida':100,'energia':100}
var morale:Dictionary={'commander':75,'engineer':75,'botanist':75,'doctor':75,'geologist':75}
var cards:Array=[]
var badges:Array=[]
var results:Dictionary={}
var minigame_running:=false
var unread_tasks:=true
var selected_on_map:=''

func _ready()->void:
 super._ready()
 test_mode='--daily-test' in OS.get_cmdline_user_args() or '--daily-tour' in OS.get_cmdline_user_args() or '--daily-visual' in OS.get_cmdline_user_args()
 save_path='user://test_daily_v2.json' if test_mode else 'user://campaign_v2.json'
 if '--daily-tour' in OS.get_cmdline_user_args():save_path='user://test_daily_tour_v2.json'
 elif '--daily-visual' in OS.get_cmdline_user_args():save_path='user://test_daily_visual_v2.json'

func reset()->void:
 super.reset()
 jornada=1;phase='arrival';selected='';blocks=3;robot_name="Guide robot"
 resources={'oxigeno':100,'agua':100,'comida':100,'energia':100}
 morale={'commander':75,'engineer':75,'botanist':75,'doctor':75,'geologist':75}
 cards.clear();badges.clear();results.clear();minigame_running=false;unread_tasks=true

func day()->int: return jornada

func current()->Dictionary:
 if phase=='arrival': return {'id':'meeting','room':'shelter','target':'shield','title':"Meet the crew",'speaker':'commander','choices':['Saludar'],'correct':0}
 if not selected.is_empty(): return Daily.find(selected,priority)
 if phase=='night': return {'id':'night','room':'shelter','target':'food','title':"Dinner and a mysterious signal",'speaker':'robot','choices':['Cenar'],'correct':0}
 if phase=='complete': return {}
 return {'id':'planning','room':'command','target':'command','title':"Choose a task on the board",'speaker':'commander','choices':['Planificar'],'correct':0}

func available()->Array:
 var list:Array=[]
 if phase!='planning': return list
 for t in Daily.tasks():
  if t.day!=jornada or t.cost==0 or t.id in completed or t.cost>blocks: continue
  if t.optional and t.verb==optional.get('last_verb',''):continue
  if t.needs.any(func(id):return not id in completed): continue
  if t.id=='lab2' and inventory.muestras==0: continue
  list.append(t)
 return list

func select_task(id:String)->bool:
 if not selected.is_empty() or not available().any(func(t):return t.id==id): return false
 selected=id;unread_tasks=true;step+=1;save_game();changed.emit();return true

func required_done()->bool:
 return Daily.essentials(jornada).all(func(id):return id in completed)

func begin_night()->bool:
 if not required_done() or not selected.is_empty() or phase!='planning': return false
 phase='night';step+=1;unread_tasks=true;save_game();changed.emit();return true

func finish_night()->bool:
 if phase!='night': return false
 if jornada==3:
  phase='complete';badges.append("Green light");optional.green_light=true
 else:
  jornada+=1;blocks=5;phase='planning'
 selected='';step+=1;unread_tasks=true;save_game();changed.emit();return true

func complete(answer:int)->bool:
 if phase=='arrival':
  if 'meeting' in completed:return false
  completed.append('meeting');phase='planning';step+=1;save_game();changed.emit();return true
 var t:=current()
 if selected.is_empty() or selected in completed:return false
 return finish_activity(selected,{'answer':answer,'grade':'bien'})

func finish_activity(id:String,result:Dictionary)->bool:
 if selected!=id or id in completed:return false
 var t:=Daily.find(id,priority)
 if t.is_empty():return false
 completed.append(id);results[id]=result.duplicate(true);blocks=maxi(0,blocks-int(t.cost))
 optional.last_verb=t.verb
 if not id in cards:cards.append(id)
 if cards.size()>=5:optional.robot_accessory=true
 if cards.size()>=10:optional.bedroom_drawings=true
 for key in resources:resources[key]=clampi(int(resources[key])-({'oxigeno':1,'agua':2,'comida':1,'energia':3}[key] if t.cost>0 else 0),20,100)
 match id:
  'meal':
   choices.meal=int(result.get('season',0));resources.comida-=8
   for person in morale:morale[person]=mini(100,int(morale[person])+5)
  'prepare':
   if priority=='lab':optional.calibrated=true
   else:inventory.filtro_aire+=1
  'air':
   emergency='';remaining=0;completed.append('air_on');badges.append("Clean air")
  'suit_check':
   choices.suit=int(result.get('suit',0));completed.append('prebreathe')
   if choices.suit==1:resources.energia-=8
  'eva2':inventory.registros+=1;optional.instrument_moved=true
  'rover':
   emergency='';remaining=0;completed.append('rover_test');badges.append("Rover repaired")
  'dust_return':optional.seals_clean=true
  'water':
   choices.water_choice=int(result.get('water',0));inventory.cartucho_agua-=1
   if choices.water_choice==0:inventory.agua_reserva-=1;resources.agua-=12
   else:optional.irrigation_paused=true
   completed.append('water_test')
  'exercise':
   for person in morale:morale[person]=mini(100,int(morale[person])+4)
  'solar_choice':
   choices.solar_choice=int(result.get('solar',0));optional.solar_bag=choices.solar_choice==1
   if optional.solar_bag:remaining=maxf(1,remaining-30)
  'shelter_all':
   emergency='';remaining=0;badges.append("Crew safe")
   if optional.get('solar_bag',false):inventory.muestras+=1
  'grow2','grow3':optional.irrigation_paused=false;optional.plant_growth=true
  'chat2','chat3':
   for person in morale:morale[person]=mini(100,int(morale[person])+10)
  'lab2':inventory.registros+=1
 selected='';step+=1;unread_tasks=true
 if id=='eva2':selected='rover';start_emergency('rover',60)
 elif id=='eva3':selected='solar_choice';start_emergency('solar',180)
 elif id=='solar_choice':selected='solar_lock'
 elif id=='solar_lock':selected='shelter_all'
 elif jornada==1 and required_done() and not 'air' in completed:
  selected='air';start_emergency('air',90)
 save_game();changed.emit();return true

func start_emergency(kind:String,seconds:float)->void:
 super.start_emergency(kind,seconds*(1.5 if rank=="Cadet" else 1.0))

func clock_running()->bool:
 return active and focused and not transition and not optional.get('emergency_brief_pending',false) and (locks==0 or minigame_running and locks==1)

func _process(delta:float)->void:
 if active and focused and not transition and locks==0:play_seconds+=delta
 tick(delta)

func tick(delta:float)->void:
 if emergency.is_empty() or not clock_running():return
 remaining=maxf(0,remaining-delta)
 if remaining<=0:rescue()

func rescue()->void:
 if emergency.is_empty():return
 var kind:=emergency
 optional.erase('activity_state')
 rescues.append(kind);emergency='';remaining=0;optional.emergency_brief_pending=false;minigame_running=false
 for person in morale:morale[person]=maxi(50,int(morale[person])-8)
 if kind=='air':
  inventory.repuesto_reserva=maxi(0,inventory.repuesto_reserva-1);completed.append('air');completed.append('air_on');selected=''
 elif kind=='rover':
  inventory.repuesto_reserva=maxi(0,inventory.repuesto_reserva-1);completed.append('rover');completed.append('rover_test');optional.sample_cancelled=true;selected=''
 else:
  for id in ['solar_choice','solar_lock','shelter_all']:
   if not id in completed:completed.append(id)
  optional.solar_bag=false;inventory.agua_reserva=maxi(0,inventory.agua_reserva-1);resources.agua=maxi(20,resources.agua-12)
  room='shelter';position=Vector2(640,430);selected=''
 step+=1;save_game();changed.emit();rescue_requested.emit(kind)

func can_exit()->bool:
 return phase=='complete' or jornada==2 and 'suit_check' in completed or jornada==3 and selected in ['eva3','solar_choice','solar_lock','shelter_all']

func optional_action(id:String)->bool:
 if id=='extra_sample':
  if jornada!=2 or not 'rover' in completed or optional.get('sample_cancelled',false) or optional.get(id,false):return false
  optional[id]=true;inventory.muestras+=1;inventory.registros+=1;save_game();changed.emit();return true
 return super.optional_action(id)

func snapshot()->Dictionary:
 var data:=super.snapshot()
 data.merge({'version':2,'jornada':jornada,'phase':phase,'selected':selected,'blocks':blocks,'rank':rank,'robot_name':robot_name,'resources':resources,'morale':morale,'cards':cards,'badges':badges,'results':results,'unread_tasks':unread_tasks},true)
 return data

func valid_save(data:Variant)->bool:
 if not data is Dictionary or data.get('version',0)!=2:return false
 for key in ['jornada','phase','selected','blocks','rank','robot_name','resources','morale','cards','badges','results']:
  if not data.has(key):return false
 if not (data.jornada is float or data.jornada is int) or int(data.jornada)<1 or int(data.jornada)>3 or not data.phase in ['arrival','planning','night','complete']:return false
 if not normalize_rank(str(data.rank)) in ["Cadet","Commander"] or not data.robot_name is String:return false
 if not data.blocks is float and not data.blocks is int:return false
 if data.blocks<0 or data.blocks>5:return false
 if not data.selected is String or data.selected!='' and Daily.find(data.selected).is_empty():return false
 for key in ['resources','morale','results']:
  if not data[key] is Dictionary:return false
 for key in ['cards','badges']:
  if not data[key] is Array:return false
 for key in resources:
  if not data.resources.has(key) or not (data.resources[key] is float or data.resources[key] is int):return false
  if data.resources[key]<0 or data.resources[key]>100:return false
 for key in morale:
  if not data.morale.has(key) or not (data.morale[key] is float or data.morale[key] is int):return false
 if not (data.get('remaining',null) is float or data.get('remaining',null) is int) or data.remaining>270:return false
 var legacy:Dictionary=data.duplicate(true)
 legacy.version=1;legacy.remaining=minf(float(data.remaining),180)
 return super.valid_save(legacy)

func load_game(backup:=false)->bool:
 if not super.load_game(backup):return false
 var data:Dictionary=JSON.parse_string(FileAccess.get_file_as_string(save_path+('.bak' if backup else '')))
 jornada=int(data.jornada);phase=data.phase;selected=data.selected;blocks=int(data.blocks);rank=normalize_rank(data.rank);robot_name=data.robot_name
 if robot_name=='Robot guía':robot_name='Guide robot'
 resources=data.resources;morale=data.morale;cards=data.cards;badges=data.badges;results=data.results;unread_tasks=data.get('unread_tasks',true);minigame_running=false
 var old_badges:Dictionary={'Luz verde':'Green light','Aire limpio':'Clean air','Rover salvado':'Rover repaired','Equipo a salvo':'Crew safe'}
 badges=badges.map(func(b):return old_badges.get(b,b))
 changed.emit();return true

func normalize_rank(value:String)->String:
 return {'Cadete':'Cadet','Comandante':'Commander'}.get(value,value)

func report()->String:
 var lines:="Day %d · %s\nTime blocks left: %d\n" %[jornada,rank,blocks]
 lines+="Green light: "+("granted" if phase=='complete' else "in preparation")+'\n'
 lines+="Cards: %d · Samples: %d · Records: %d\n" %[cards.size(),inventory.muestras,inventory.registros]
 lines+="Water reserves: %d · Spares: %d\n" %[inventory.agua_reserva,inventory.repuesto_reserva]
 lines+="Water choice: "+("reserve used" if choices.get('water_choice',-1)==0 else "watering paused" if choices.has('water_choice') else "pending")+'\n'
 lines+="Crew assists: "+(', '.join(rescues) if not rescues.is_empty() else "none")+'\n'
 lines+='Robot: '+robot_name+"\n\nCompleted tasks:\n"
 for t in Daily.tasks():
  if t.id in completed:lines+='✓ '+t.title+'\n'
 return lines
