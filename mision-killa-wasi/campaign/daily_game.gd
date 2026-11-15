extends 'res://campaign/game.gd'
const Daily=preload('res://campaign/daily_data.gd')
var awaiting_start:=false

func _ready()->void:
 ui_script_path='res://campaign/daily_ui.gd'
 super._ready()
 get_tree().set_meta('landing',false)
 if '--daily-test' in OS.get_cmdline_user_args():call_deferred('run_daily_tests')
 if '--daily-tour' in OS.get_cmdline_user_args():call_deferred('run_daily_tour')
 if '--daily-visual' in OS.get_cmdline_user_args():call_deferred('run_daily_visual')

func new_mission_confirmation()->void:
 if FileAccess.file_exists(Mission.save_path) or FileAccess.file_exists(Mission.save_path+'.bak'):
  var p:Control=ui.push('NUEVA MISIÓN')
  ui.label(p,'¿Reemplazar el progreso de esta campaña?',Rect2(35,110,890,90),25)
  ui.button(p,'Sí, comenzar',Rect2(35,275,430,60),func():ui.pop();choose_rank()).grab_focus()
  ui.button(p,'Conservar partida',Rect2(495,275,430,60),ui.pop)
 else:choose_rank()

func choose_rank()->void:
 var p:Control=ui.push('ELIGE TU AVENTURA')
 ui.label(p,'Puedes pedir ayuda en ambos modos. Las recompensas son las mismas.',Rect2(35,100,890,100),25)
 ui.button(p,'Cadete · Más tiempo y práctica',Rect2(35,230,895,65),func():ui.pop();Mission.rank='Cadete';start_new()).grab_focus()
 ui.button(p,'Comandante · Tiempo estándar',Rect2(35,315,895,65),func():ui.pop();Mission.rank='Comandante';start_new())
 ui.label(p,'Las partidas anteriores se conservan en su archivo original.',Rect2(35,425,895,50),17)

func arrival_context()->void:
 get_tree().set_meta('landing',false)
 ui.show_lines(Daily.ARRIVAL,func():Mission.optional.arrival_seen=true;Mission.save_game())

func start_new()->void:
 super.start_new()
 get_tree().set_meta('landing',true)

func begin_task()->void:
 var t:=Mission.current()
 match t.get('id',''):
  'meeting':
   ui.show_lines(Daily.MEETING,func():meeting_choice(),true)
  'planning':ui.show_tasks()
  'night':night_scene()
  '':ui.show_report()
  _:
   if t.room!=Mission.room:return
   ui.show_lines([[t.speaker,t.instruction]],func():ui.open_minigame(t))

func meeting_choice()->void:
 var p:Control=ui.push('TU PRIMERA DECISIÓN')
 ui.label(p,'¿Cómo empezamos juntos?',Rect2(35,100,895,70),25)
 for i in 2:
  var answer:int=i
  ui.button(p,['Escuchamos al equipo','Revisamos nuestras prioridades'][i],Rect2(35,230+i*80,895,60),func():
   Mission.choices.meeting=answer;ui.pop();name_robot()).grab_focus()

func name_robot()->void:
 var p:Control=ui.push('¿CÓMO LLAMAMOS AL ROBOT?')
 var input:=LineEdit.new();input.position=Vector2(35,115);input.size=Vector2(895,55);input.max_length=18;input.placeholder_text='Escribe un nombre o elige uno';p.add_child(input)
 var accept:=func(text:String):
  var clean:=text.strip_edges().replace('\n','').replace('\t','')
  Mission.robot_name=clean if clean!='' else 'Robot guía'
  ui.pop();Mission.complete(0);refresh_npcs();dawn_scene()
 for i in 3:
  var text:String=['Lunita','Chispa','Kiru'][i]
  ui.button(p,text,Rect2(35+i*300,215,280,55),func():accept.call(text))
 ui.button(p,'Usar mi nombre',Rect2(35,315,895,55),func():accept.call(input.text)).grab_focus()

func dawn_scene()->void:
 ui.show_lines([['control',Daily.DAWN[Mission.day()]]],ui.show_tasks)

func finish_activity(t:Dictionary,result:Dictionary)->void:
 if t.id=='preflight3':
  Mission.optional.preflight3=true;Mission.save_game()
  ui.show_lines([['engineer','Traje, radio y preparación comprobados. Ya podemos salir.']]);return
 if not Mission.finish_activity(t.id,result):return
 Audio.confirm();refresh_npcs()
 ui.toast('Carta desbloqueada · '+t.title)
 var lines:Array=[[t.speaker,t.science]]
 if t.id=='shelter_all':
  lines.append(['control','Horas después: termina la alerta. Revisamos al equipo antes de volver al trabajo.'])
  Mission.optional.alert_cleared=true
 ui.show_lines(lines,func():
  if not Mission.emergency.is_empty() and Mission.optional.get('emergency_brief_pending',false):emergency_brief()
  elif Mission.required_done() and Mission.selected.is_empty():ui.toast('Esenciales completas. Puedes terminar la jornada desde Tareas.'))

func emergency_brief()->void:
 if Mission.emergency.is_empty():return
 var p:Control=ui.push('ALERTA · EQUIPO EN ACCIÓN')
 p.set_meta('required_ack',true)
 for i in 6:
  var id:String=['commander','engineer','botanist','doctor','geologist','robot'][i]
  var pic:TextureRect=ui.picture(p,Art.face(id),Rect2(35+i*150,90,120,140))
  ui.label(p,'!',Rect2(130+i*150,95,25,35),30,Color('f6ca68'))
  if not Mission.reduced_motion:
   var tw:=create_tween();tw.tween_property(pic,'position:y',82.0,0.15);tw.tween_property(pic,'position:y',90.0,0.2)
 var text:String={'air':'Revisa el sensor, limpia la rejilla y dirige el flujo.','rover':'El rover está estacionado. Repara y comprueba el guardabarros.','solar':'Regresa por la esclusa. Reúne a todos en el refugio.'}[Mission.emergency]
 ui.label(p,text,Rect2(35,260,895,85),25)
 ui.label(p,'El reloj avanza durante la acción. Leer y pedir ayuda lo detiene.',Rect2(35,355,895,45),17)
 ui.button(p,'Entendido · Comenzar',Rect2(35,425,895,55),func():Mission.optional.emergency_brief_pending=false;Mission.save_game();ui.pop()).grab_focus()

func rescued(kind:String)->void:
 ui.clear();ui.active_game=null
 if kind=='solar':await change_room('shelter',false)
 var message:String={'air':'El ingeniero recuperó la ventilación. Utilizamos un repuesto de reserva.','rover':'Reparación asistida. Usamos un repuesto y cancelamos la muestra extra.','solar':'Equipo a salvo. Perdimos la bolsa y utilizamos una reserva de agua.'}[kind]
 ui.show_lines([['control',message]])
 refresh_npcs()

func night_scene()->void:
 if Mission.phase!='night':return
 var d:int=Mission.day()
 ui.show_lines(Daily.NIGHT[d],func():
  if not Mission.finish_night():return
  if Mission.phase=='complete':ui.show_report()
  else:day_transition())

func day_transition()->void:
 Mission.transition=true
 var p:Control=ui.push('UNA NUEVA JORNADA',Rect2(0,0,1280,720))
 p.set_meta('required_ack',true)
 var heading:Label=ui.label(p,'DÍA %d'%Mission.day(),Rect2(200,245,880,110),70,Color('f6ca68'))
 heading.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER
 var subtitle:Label=ui.label(p,Daily.DAWN[Mission.day()],Rect2(200,385,880,80),25)
 subtitle.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER
 if not Mission.reduced_motion:
  heading.modulate.a=0;subtitle.modulate.a=0
  var tween:=create_tween();tween.tween_property(heading,'modulate:a',1.0,0.7);tween.tween_property(subtitle,'modulate:a',1.0,0.5)
 ui.button(p,'Comenzar el día',Rect2(420,550,440,60),func():
  ui.pop();Mission.transition=false;Mission.optional.day_intro_pending=false
  await change_room('shelter',false);Mission.save_game();dawn_scene()).grab_focus()
 Mission.optional.day_intro_pending=true;Mission.save_game()

func continue_game()->void:
 if not Mission.load_game():super.continue_game();return
 ui.clear();await change_room(Mission.room,false,true)
 if Mission.optional.get('day_intro_pending',false):day_transition()
 elif Mission.optional.get('emergency_brief_pending',false) and not Mission.emergency.is_empty():emergency_brief()
 elif Mission.phase=='arrival' and not Mission.optional.get('arrival_seen',false):arrival_context()

func interact(entry:Dictionary)->void:
 if not Mission.movable():return
 if entry.get('npc',false):
  var id:String=entry.id
  for npc in world.npc_actors:
   if npc.identity==id:npc.facing=signf(hero.position.x-npc.position.x)
  var count:int=conversation_counts.get(id,0);conversation_counts[id]=count+1
  var line:String=Daily.CHATS[id][count%Daily.CHATS[id].size()]
  if id=='botanist' and Mission.optional.get('irrigation_paused',false):line='Conservamos la reserva. Revisemos el riego cuando termine la reparación.'
  elif id=='engineer' and not Mission.rescues.is_empty() and count%3==0:line='Trabajamos juntos y seguimos adelante. Ya registré el repuesto utilizado.'
  ui.show_lines([[id,line]]);return
 if entry.get('door',false) and entry.to=='exterior' and Mission.selected=='eva3' and not Mission.optional.get('preflight3',false):
  var data:Dictionary=Daily.find('suit_check').duplicate(true)
  data.id='preflight3';data.cost=0
  ui.show_lines([['engineer','Repetimos traje, radio y preparación de presión antes de cada salida.']],func():ui.open_minigame(data));return
 if entry.get('door',false) and entry.to=='exterior' and not Mission.can_exit():
  ui.show_lines([['engineer','Primero revisamos traje, radio y preparación de presión.']]);return
 super.interact(entry)

func on_changed()->void:
 if last_step!=Mission.step:
  last_step=Mission.step
  if is_instance_valid(ui):ui.toast('Tareas actualizadas · T')

func _process(delta:float)->void:
 super._process(delta)
 if Mission.active and is_instance_valid(world):
  ui.hint.text='E · '+world.nearest.title if not world.nearest.is_empty() else 'WASD · Caminar   T · Tareas   J · Diario'

func run_daily_tests()->void:
 var suite=load('res://campaign/tests/daily_test.gd').new();add_child(suite);await suite.run(self)
func run_daily_tour()->void:
 var suite=load('res://campaign/tests/daily_tour.gd').new();add_child(suite);await suite.run(self)
func run_daily_visual()->void:
 var suite=load('res://campaign/tests/daily_visual.gd').new();add_child(suite);await suite.run(self)
