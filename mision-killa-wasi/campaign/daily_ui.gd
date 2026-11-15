extends 'res://campaign/ui.gd'
const Daily=preload('res://campaign/daily_data.gd')
var tasks_button:Button
var bars:Dictionary={}
var mood_label:Label
var spoken_text:=''
var mood_portraits:Dictionary={}
var mood_symbols:Dictionary={}
var active_game:Control
var map_view:Control

func _ready()->void:
 super._ready()
 objective.hide();status.hide()
 tasks_button=button(hud,'T · Tareas !',Rect2(435,12,160,40),show_tasks)
 button(hud,'J · Diario',Rect2(605,12,150,40),show_journal)
 mood_label=label(hud,'',Rect2(770,17,300,30),18)
 var people:Array=['commander','engineer','botanist','doctor','geologist']
 for person in people:
  var portrait:=picture(hud,Art.face(person),Rect2(775+people.find(person)*54,10,42,44))
  portrait.mouse_filter=Control.MOUSE_FILTER_STOP
  mood_portraits[person]=portrait
  var symbol:=label(hud,':)',Rect2(775+people.find(person)*54,49,42,18),12,Color('74e1c6'))
  symbol.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER;mood_symbols[person]=symbol
 timer.position=Vector2(1080,12);timer.size=Vector2(175,40)
 var names:Dictionary={'oxigeno':'O₂','agua':'Agua','comida':'Comida','energia':'Energía'}
 var i:=0
 for key in names:
  label(hud,names[key],Rect2(435+i*195,67,65,25),15)
  var bar:=ProgressBar.new()
  bar.position=Vector2(500+i*195,70);bar.size=Vector2(115,17);bar.show_percentage=false
  bar.add_theme_stylebox_override('fill',style(Color('63bfc9'),Color('63bfc9')))
  hud.add_child(bar);bars[key]=bar;i+=1

func button(parent:Node,text:String,rect:Rect2,action:Callable)->Button:
 var b:=super.button(parent,text,rect,action)
 b.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART
 b.clip_text=true
 if rect.size.y<45:b.add_theme_font_size_override('font_size',14)
 b.size=rect.size
 return b

func label(parent:Node,text:String,rect:Rect2,font_size:=20,color:=Color('edf5ff'))->Label:
 var l:=super.label(parent,text,rect,font_size,color)
 if rect.size.y>0:
  l.clip_text=true
  l.size=rect.size
  l.size.y=maxf(rect.size.y,l.get_theme_font('font').get_height(font_size)+2)
 return l

func show_lines(lines:Array,done:=Callable(),meeting:=false)->void:
 var pages:Array=[]
 for line in lines:
  var words:PackedStringArray=str(line[1]).split(' ',false)
  for start in range(0,words.size(),15):
   pages.append([line[0],' '.join(words.slice(start,mini(start+15,words.size())))])
 super.show_lines(pages,done,meeting)
 var panel_node:Control=stack[-1].get_meta('panel')
 var advance:Callable=panel_node.get_meta('advance')
 panel_node.set_meta('advance',func():Audio.stop_speech();advance.call())
 for child in panel_node.get_children():
  if child is Button:child.pressed.connect(Audio.stop_speech)

func pop()->void:
 Audio.stop_speech();spoken_text=''
 super.pop()

func show_tasks()->void:
 if not Mission.active:return
 Mission.unread_tasks=false;Mission.save_game()
 var p:=push('PIZARRA · DÍA %d'%Mission.day(),Rect2(110,115,1060,535))
 label(p,'Bloques disponibles: %d · %s'%[Mission.blocks,Mission.rank],Rect2(30,75,990,32),20)
 var scroll:=ScrollContainer.new();scroll.position=Vector2(25,120);scroll.size=Vector2(1010,305);p.add_child(scroll)
 var box:=VBoxContainer.new();box.custom_minimum_size.x=985;box.add_theme_constant_override('separation',9);scroll.add_child(box)
 var current:=Mission.current()
 if Mission.phase=='arrival':
  add_task_row(box,'Conoce al equipo · Refugio',func():pop())
 elif not Mission.selected.is_empty():
  add_task_row(box,'→ '+current.title+' · '+Catalog.ROOMS[current.room],func():pop();toast('Destino señalado en el mapa.'))
 else:
  for t in Mission.available():
   var data:Dictionary=t
   add_task_row(box,('◇ ' if t.optional else '★ ')+t.title+' · %d bloque(s) · %s'%[t.cost,Catalog.ROOMS[t.room]],func():
    if data.id=='prepare' and Mission.priority=='':choose_priority();return
    Mission.select_task(data.id);pop();toast('Tarea asignada. Consulta M para orientarte.'))
  if Mission.required_done() and Mission.phase=='planning':
   add_task_row(box,'Terminar jornada · Cena y señal',func():Mission.begin_night();pop())
 if Mission.phase=='night':add_task_row(box,'Cena y señal · Sala común',func():pop())
 for t in Daily.tasks():
  if t.day==Mission.day() and t.id in Mission.completed:
   var row:=Label.new();row.text='✓ '+t.title;row.add_theme_font_size_override('font_size',18);box.add_child(row)
 button(p,'Cerrar tareas',Rect2(650,455,370,50),pop).grab_focus()

func add_task_row(box:VBoxContainer,text:String,action:Callable)->void:
 var b:=button(box,text,Rect2(0,0,970,60),action)
 b.custom_minimum_size=Vector2(970,60)

func choose_priority()->void:
 var p:=push('PRIMERA PREPARACIÓN')
 label(p,'Ambas opciones son útiles. La preparación pendiente seguirá disponible.',Rect2(35,95,895,80),23)
 button(p,'Almacén · Localiza un filtro de aire',Rect2(35,215,895,65),func():Mission.priority='storage';Mission.select_task('prepare');pop();pop()).grab_focus()
 button(p,'Laboratorio · Calibra el instrumento',Rect2(35,295,895,65),func():Mission.priority='lab';Mission.select_task('prepare');pop();pop())
 button(p,'Revisar la pizarra',Rect2(35,425,895,50),pop)

func show_item(entry:Dictionary)->void:
 var t:=Mission.current()
 if entry.id==t.get('target','') and Mission.room==t.get('room',''):
  game.begin_task();return
 var p:=push(entry.title)
 picture(p,Art.prop(int(entry.art)),Rect2(35,90,185,210))
 var simple:=short_description(entry)
 label(p,simple,Rect2(250,105,670,100),24)
 label(p,Mission.item_state(entry.id),Rect2(250,220,670,85),18,Color('74e1c6'))
 button(p,'Quiero saber más',Rect2(35,350,895,50),func():show_encyclopedia(entry)).grab_focus()
 if entry.id=='rock' and Mission.day()==2 and 'rover' in Mission.completed and not Mission.optional.get('extra_sample',false) and not Mission.optional.get('sample_cancelled',false):
  button(p,'Recoger muestra extra',Rect2(35,415,430,50),func():Mission.optional_action('extra_sample');pop();toast('Muestra registrada.'))
 elif entry.id=='spares' and Mission.priority=='lab' and 'prepare' in Mission.completed and not Mission.optional.get('storage_later',false):
  button(p,'Preparación pendiente: almacén',Rect2(35,415,430,50),func():Mission.optional_action('storage_later');pop())
 elif entry.id=='analyzer' and Mission.priority=='storage' and 'prepare' in Mission.completed and not Mission.optional.get('lab_later',false):
  button(p,'Preparación pendiente: laboratorio',Rect2(35,415,430,50),func():Mission.optional_action('lab_later');pop())
 button(p,'Seguir explorando',Rect2(495,415,435,50),pop)

func short_description(entry:Dictionary)->String:
 var sentence:String=str(entry.description).split('.')[0]+'.'
 var words:=sentence.split(' ',false)
 return ' '.join(words.slice(0,15))

func show_encyclopedia(entry:Dictionary)->void:
 var p:=push('ENCICLOPEDIA · '+entry.title)
 var text:=RichTextLabel.new();text.position=Vector2(35,145);text.size=Vector2(895,250)
 text.add_theme_font_size_override('normal_font_size',21);p.add_child(text)
 var display:=func(level:String):
  text.text=(entry.description if level=='Cadete' else Catalog.FACTS.get(entry.id,entry.description)+'\n\n'+entry.description)+'\n\nFuente: '+entry.source
 button(p,'Cadete',Rect2(35,85,430,45),func():display.call('Cadete'))
 button(p,'Comandante',Rect2(495,85,435,45),func():display.call('Comandante'))
 display.call(Mission.rank)
 button(p,'Volver',Rect2(35,430,895,50),pop).grab_focus()

func show_task()->void:game.begin_task()

func show_help()->void:
 if not Mission.active:return
 var t:=Mission.current();var id:String=t.get('id','explore')
 var level:=int(Mission.help_level.get(id,0))%3
 Mission.help_level[id]=level+1
 var text:='Puedes explorar las salas. El mapa muestra tu posición.'
 if is_instance_valid(active_game) and active_game.is_inside_tree():text=active_game.hint(level)
 elif t.get('id','')=='planning':text='Abre Tareas. Elige una tarjeta disponible y camina hasta su destino.'
 elif t.has('room'):text='Busca %s en %s.'%[t.get('target','el equipo'),Catalog.ROOMS[t.room]]
 show_lines([['robot',text]])

func show_journal()->void:
 if not Mission.active:return
 var p:=push('DIARIO DEL COMANDANTE')
 var text:=RichTextLabel.new();text.position=Vector2(35,85);text.size=Vector2(895,330);text.add_theme_font_size_override('normal_font_size',20);p.add_child(text)
 text.text='Robot: '+Mission.robot_name+'\nInsignias: '+', '.join(Mission.badges)+'\n\nCARTAS DE MISIÓN\n'
 for id in Mission.cards:
  var t:=Daily.find(id,Mission.priority)
  text.text+='\n'+t.title+'\n'+t.science+'\n'
 if Mission.cards.is_empty():text.text+='Completa actividades para descubrir tus primeras cartas.'
 button(p,'Cerrar diario',Rect2(35,430,895,50),pop).grab_focus()

func show_map()->void:
 if not Mission.active:return
 var p:=push('CROQUIS DE KILLA WASI',Rect2(65,110,1150,545))
 var map=preload('res://campaign/map_view.gd').new()
 map.game=game;map.ui=self;map.position=Vector2(25,85);map.size=Vector2(1100,360);p.add_child(map);map_view=map
 button(p,'Cerrar mapa',Rect2(740,465,375,50),pop).grab_focus()

func open_minigame(t:Dictionary)->void:
 var p:=push(t.title,Rect2(120,115,1040,540))
 var activity=preload('res://campaign/minigame.gd').new()
 activity.setup(t,self);activity.position=Vector2(25,75);p.add_child(activity);active_game=activity
 activity.finished.connect(func(result):
  pop();active_game=null;game.finish_activity(t,result))
 var info:=label(p,'R · Ayuda   Esc · Pausa',Rect2(680,20,325,35),17)
 info.horizontal_alignment=HORIZONTAL_ALIGNMENT_RIGHT

func _process(delta:float)->void:
 super._process(delta)
 objective.hide();status.hide()
 if not Mission.active:return
 tasks_button.text='T · Tareas'+(' !' if Mission.unread_tasks else '')
 for key in bars:bars[key].value=Mission.resources[key]
 mood_label.hide()
 for key in mood_portraits:
  var content:bool=Mission.morale[key]>=70
  mood_portraits[key].modulate=Color.WHITE if content else Color('b4c2d6')
  mood_portraits[key].tooltip_text=Catalog.NAMES[key]+(' · Contento' if content else ' · Necesita una pausa')
  mood_symbols[key].text=':)' if content else ':|'
 if not stack.is_empty():
  var p:Control=stack[-1].get_meta('panel')
  if p.has_meta('typing'):
   var body:Label=p.get_meta('typing')
   if spoken_text!=body.text:
    spoken_text=body.text;Audio.speak(body.text)
    if p.has_meta('speaker') and p.get_meta('speaker')=='robot':
     for child in p.get_children():
      if child is Label and child.text=='Robot guía':child.text=Mission.robot_name

func _input(event:InputEvent)->void:
 if event is InputEventKey and event.pressed and not event.echo:
  var key:int=event.keycode if event.keycode else event.physical_keycode
  if key in [KEY_T,KEY_J] and Mission.active:
   get_viewport().set_input_as_handled()
   if stack.is_empty():
    if key==KEY_T:show_tasks()
    else:show_journal()
   return
  if key==KEY_ESCAPE and is_instance_valid(active_game) and stack.size()==1:
   get_viewport().set_input_as_handled();show_pause();return
 super._input(event)
