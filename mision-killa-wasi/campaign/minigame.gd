extends Control
signal finished(result:Dictionary)
var task:Dictionary
var ui:CanvasLayer
var kind:=''
var cursor:=0
var stage:=0
var value:=2
var progress:=0.0
var chosen:Array=[]
var result:Dictionary={}
var mistakes:=0
var completed:=false
var feedback:=''
var action_buttons:Array[Button]=[]
var instruction_label:Label
var detail:Label
var timer_label:Label
var action_texts:Array=[]
var holding:=false
var elapsed:=0.0
var beat_clock:=0.0
var rhythm_hits:=0
var pipes:Array=[1,2,3,1]
var grid_origin:=Vector2(35,145)
const Art=preload('res://campaign/art.gd')

func setup(data:Dictionary,interface:CanvasLayer)->void:
 task=data;ui=interface;kind=task.kind

func _ready()->void:
 size=Vector2(900,440)
 instruction_label=ui.label(self,task.instruction,Rect2(25,5,850,60),21)
 detail=ui.label(self,'',Rect2(25,73,850,45),18,Color('74e1c6'))
 timer_label=ui.label(self,'',Rect2(25,365,850,45),17)
 Mission.minigame_running=true
 var saved:Dictionary=Mission.optional.get('activity_state',{})
 if saved.get('id','')==task.id:
  stage=int(saved.get('stage',0));cursor=int(saved.get('cursor',0));value=int(saved.get('value',2))
  chosen=saved.get('chosen',[]).map(func(n):return int(n));result=saved.get('result',{}).duplicate(true)
  progress=float(saved.get('progress',0));mistakes=int(saved.get('mistakes',0));elapsed=float(saved.get('elapsed',0))
  rhythm_hits=int(saved.get('rhythm_hits',0));pipes=saved.get('pipes',[1,2,3,1]).map(func(n):return int(n))
 rebuild()

func _exit_tree()->void:
 Mission.minigame_running=false

func rebuild()->void:
 for b in action_buttons:
  remove_child(b);b.queue_free()
 action_buttons.clear()
 action_texts=options()
 cursor=clampi(cursor,0,maxi(0,action_texts.size()-1))
 for i in action_texts.size():
  var index:int=i
  var b:Button=ui.button(self,str(action_texts[i]),Rect2(grid_origin+Vector2((i%3)*285,(i/3)*76),Vector2(270,62)),func():choose(index))
  b.focus_mode=Control.FOCUS_NONE
  b.mouse_entered.connect(func():cursor=index)
  action_buttons.append(b)
 detail.text=feedback if feedback!='' else status_text()
 save_progress()
 queue_redraw()

func options()->Array:
 match kind:
  'scan':return ['Pulso ✓','Oxígeno ✓','Temperatura ✓','Imagen sin sensor','Dibujo del traje','Etiqueta vacía']
  'cook':
   if stage==0:return ['Arroz','Tortilla','Frijoles','Huevo','Zanahoria','Espinaca']
   return ['Suave','Hierbas aparte','Picante aparte']
  'search':return ['Cable','Filtro de aire A','Cartucho de agua','Tornillo','Filtro de aire B','Envase vacío']
  'calibrate':return ['− Ajustar','Lectura: %d · Meta: 6'%value,'+ Ajustar','Comprobar']
  'air':
   if stage==0:return ['Consultar sensor']
   if stage==1:return ['Rejilla izquierda','Rejilla central','Rejilla derecha']
   if stage==2:return ['← Girar aire','Ángulo: %d°'%value,'Girar aire →','Mantener E: encender']
   return ['Verificar lectura']
  'suit':
   if stage==0:return ['Cómodo · preparación larga','Alta presión · −8 energía']
   return ['Revisar sellos','Probar radio','Preparación con el médico']
  'field':return ['Registrar textura','Registrar ubicación','Mover instrumento']
  'assemble':
   if stage==0:return ['Lámina flexible','Cinta compatible','Abrazaderas','Pieza que roza','Bolsa abierta','Tornillo incompatible']
   return ['Cubrir con lámina','Sujetar con cinta','Ajustar abrazaderas']
  'clean':return ['Botas','Guantes','Uniones'] if stage==0 else ['Inspeccionar sellos limpios']
  'pipes':
   if stage==0:return ['Usar una reserva de agua','Pausar el riego']
   if stage==1:return ['Tramo 1: %d°'%(pipes[0]*90),'Tramo 2: %d°'%(pipes[1]*90),'Tramo 3: %d°'%(pipes[2]*90),'Tramo 4: %d°'%(pipes[3]*90),'Comprobar conexión']
   if stage==2:return ['Filtro de aire','Cartucho de agua']
   return ['Comprobar calidad del agua']
  'rhythm':return ['← Resistencia','→ Bicicleta','Practicar sin ritmo']
  'solar':return ['Dejar bolsa · volver ahora','Recoger bolsa · −30 segundos']
  'lock':return ['Cerrar puerta exterior','Comprobar presión','Abrir puerta interior']
  'shelter':return ['Comandante','Ingeniero jefe','Bióloga botánica','Médico de vuelo','Geólogo lunar','Comprobar dosímetro y radio']
  'chat':return ['Escuchar sin interrumpir','Ofrecer una pausa','Pedir apoyo al equipo']
  'grow':return ['Observar luz','Medir humedad','Comprobar riego']
 return ['Comprobar']

func status_text()->String:
 if kind=='cook' and stage==0:return 'Combina un cereal, una proteína y una verdura.'
 if kind=='pipes' and stage==1:return 'Conecta cuatro tramos horizontales. Cada selección gira una pieza.'
 if kind=='air' and stage==1 or kind=='clean' and stage==0:return 'Escoge una zona. Mantén E, Espacio o clic para aspirar.'
 if kind=='air' and stage==2:return 'Dirige el aire a 35°. Mantén E para activar el flujo.'
 if kind=='rhythm':return 'Alterna izquierda y derecha cuando el pulso entra al círculo.'
 return 'Flechas: elegir · Enter: confirmar · R: ayuda voluntaria'

func hint(level:int)->String:
 if level==0:return task.science
 if level==1:return status_text()
 match kind:
  'scan':return 'Comprueba pulso, oxígeno y temperatura. El médico interpreta las lecturas.'
  'cook':return 'Elige un alimento de cada pareja. Después ofrece condimentos por separado.'
  'search':return 'Busca las dos etiquetas que dicen filtro de aire.'
  'calibrate':return 'Ajusta la lectura hasta seis y pulsa Comprobar.'
  'air':return ['Consulta el sensor.','Aspira las tres zonas manteniendo E.','Ajusta a treinta y cinco grados. Mantén E.','Comprueba la lectura final.'][stage]
  'assemble':return 'Elige lámina, cinta y abrazaderas. Después colócalas en ese orden.'
  'pipes':return 'Elige una reserva o pausa. Alinea tramos; instala cartucho de agua y verifica.'
  'shelter':return 'Cuenta las cinco personas antes de comprobar dosímetro y radio.'
  'rhythm':return 'También puedes elegir Practicar sin ritmo. Obtienes la misma carta.'
 return 'Completa cada acción marcada antes de confirmar el resultado.'

func wrong(text:String)->void:
 mistakes+=1;feedback=text;rebuild()
 if Mission.rank=='Cadete' and mistakes==2:ui.toast('¿Una pista? Pulsa R cuando quieras.')

func choose(index:int)->void:
 if completed or Mission.locks!=1 or not Mission.focused:return
 feedback='';cursor=index
 match kind:
  'scan','field','grow':
   if index>2:wrong('Ese dibujo no es una lectura. Busca los sensores.');return
   if not index in chosen:chosen.append(index);Audio.confirm()
   if chosen.size()==3:finish();return
  'cook':
   if stage==1:result.season=index;finish();return
   var group:int=index/2
   chosen=chosen.filter(func(i):return int(i)/2!=group)
   chosen.append(index)
   if chosen.size()==3:stage=1;chosen.clear();cursor=0
  'search':
   if not index in [1,4]:wrong('¡Esa pieza tiene otro trabajo! Mira la etiqueta.');return
   if not index in chosen:chosen.append(index)
   if chosen.size()==2:finish();return
  'calibrate':
   if index==0:value=maxi(0,value-1)
   elif index==2:value=mini(10,value+1)
   elif index==3:
    if value==6:finish();return
    wrong('La referencia marca seis. Ajusta un poquito más.');return
  'air':
   if stage==0:stage=1;chosen.clear();cursor=0
   elif stage==1:return
   elif stage==2:
    if index==0:value=maxi(0,value-5)
    elif index==2:value=mini(90,value+5)
    rebuild()
    return
   else:finish();return
  'clean':
   if stage==0:return
   finish();return
  'suit':
   if stage==0:result.suit=index;stage=1;cursor=0
   else:
    if not index in chosen:chosen.append(index)
    if chosen.size()==3:finish();return
  'assemble','lock':
   if kind=='assemble' and stage==0:
    if index>2:wrong('Esa pieza podría soltarse o rozar. Prueba otra.');return
    if not index in chosen:chosen.append(index)
    if chosen.size()==3:stage=1;chosen.clear();cursor=0
   else:
    if index!=chosen.size():wrong('Comprueba primero el paso anterior.');return
    chosen.append(index)
    if chosen.size()==3:finish();return
  'pipes':
   if stage==0:result.water=index;stage=1;cursor=0
   elif stage==1:
    if index<4:pipes[index]=(int(pipes[index])+1)%4
    elif pipes.all(func(p):return p==0):stage=2;cursor=0
    else:wrong('Todavía hay un tramo girado. Busca la línea horizontal.');return
   elif stage==2:
    if index==0:wrong('Ese filtro trabaja con aire. Necesitamos el cartucho de agua.');return
    stage=3;cursor=0
   else:finish();return
  'rhythm':
   if index==2:result.practice=true;rhythm_hits+=1
   elif index!=rhythm_hits%2:wrong('Alterna los lados. ¡Sin prisa, podemos practicar!');return
   elif absf(fmod(beat_clock,1.6)-0.8)<0.45:rhythm_hits+=1
   else:wrong('Espera al pulso dentro del círculo.');return
   if rhythm_hits>=8:finish();return
  'solar':result.solar=index;finish();return
  'shelter':
   if index==5:
    if chosen.size()<5:wrong('Falta pasar lista. Contemos cinco personas.');return
    finish();return
   if not index in chosen:chosen.append(index)
  'chat':result.support=index;finish();return
  _:finish();return
 rebuild()

func finish()->void:
 if completed:return
 completed=true;Mission.minigame_running=false
 Mission.optional.erase('activity_state')
 result.grade='perfecto' if mistakes==0 else 'bien'
 result.mistakes=mistakes
 result.seconds=elapsed
 finished.emit(result)

func _input(event:InputEvent)->void:
 if not event is InputEventKey or not event.pressed or event.echo or Mission.locks!=1 or completed:return
 var key:int=event.keycode if event.keycode!=0 else event.physical_keycode
 var viewport:=get_viewport()
 if key in [KEY_R,KEY_ESCAPE,KEY_M,KEY_T,KEY_J]:return
 if key in [KEY_LEFT,KEY_A]:
  if kind=='rhythm':choose(0)
  elif kind=='air' and stage==2:choose(0)
  elif kind=='calibrate':choose(0)
  else:cursor=(cursor-1+action_texts.size())%action_texts.size()
 elif key in [KEY_RIGHT,KEY_D]:
  if kind=='rhythm':choose(1)
  elif kind=='air' and stage==2:choose(2)
  elif kind=='calibrate':choose(2)
  else:cursor=(cursor+1)%action_texts.size()
 elif key in [KEY_UP,KEY_W]:cursor=0 if kind=='rhythm' else posmod(cursor-3,action_texts.size())
 elif key in [KEY_DOWN,KEY_S]:cursor=2 if kind=='rhythm' else (cursor+3)%action_texts.size()
 elif key in [KEY_ENTER,KEY_SPACE,KEY_E]:choose(3 if kind=='calibrate' else cursor)
 else:return
 viewport.set_input_as_handled()
 if is_inside_tree():queue_redraw()

func _process(delta:float)->void:
 if not Mission.minigame_running or not Mission.clock_running():return
 elapsed+=delta;beat_clock+=delta
 save_progress()
 var vacuum:bool=kind=='air' and stage==1 or kind=='clean' and stage==0
 var fan:bool=kind=='air' and stage==2
 var held:bool=Input.is_physical_key_pressed(KEY_E) or Input.is_physical_key_pressed(KEY_SPACE) or Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) and get_global_rect().has_point(get_global_mouse_position())
 if vacuum and held and not cursor in chosen:
  progress+=delta
  if progress>=0.8:
   chosen.append(cursor);progress=0;Audio.confirm()
   if chosen.size()==3:
    stage+=1;chosen.clear();cursor=0
    if kind=='air':value=0
   rebuild()
 elif fan and held and absi(value-35)<=5:
  progress+=delta
  if progress>=1.0:stage=3;progress=0;cursor=0;rebuild()
 else:progress=maxf(0,progress-delta*0.5)
 timer_label.text='Comprobados: %d  ·  %s'%[rhythm_hits if kind=='rhythm' else chosen.size(),feedback]
 for i in action_buttons.size():
  action_buttons[i].modulate=Color('74e1c6') if i in chosen else Color.WHITE
 queue_redraw()

func save_progress()->void:
 if completed:return
 Mission.optional.activity_state={'id':task.id,'stage':stage,'cursor':cursor,'value':value,'chosen':chosen.duplicate(),'result':result.duplicate(true),'progress':progress,'mistakes':mistakes,'elapsed':elapsed,'rhythm_hits':rhythm_hits,'pipes':pipes.duplicate()}

func _draw()->void:
 if cursor<action_buttons.size():draw_style_box(ui.style(Color(0,0,0,0),Color('f6ca68')),Rect2(action_buttons[cursor].position-Vector2(3,3),action_buttons[cursor].size+Vector2(6,6)))
 if kind=='air' or kind=='clean':
  draw_rect(Rect2(35,325,820,15),Color('213e54'))
  draw_rect(Rect2(35,325,820*minf(progress,1),15),Color('74e1c6'))
 if kind=='air' and stage==2:
  var center:=Vector2(600,310)
  draw_line(center,center+Vector2.from_angle(deg_to_rad(-value))*90,Color('73d9e5'),5)
  draw_string(ThemeDB.fallback_font,Vector2(35,310),'SENSOR: visualización del flujo; el CO₂ es invisible.',HORIZONTAL_ALIGNMENT_LEFT,-1,15,Color('ffce88'))
 if kind=='pipes' and stage==1:
  for i in 4:
   var center:=Vector2(310+i*115,325)
   var dir:=Vector2.from_angle(deg_to_rad(pipes[i]*90))*45
   draw_line(center-dir,center+dir,Color('73d9e5'),8)
 if kind=='rhythm':
  draw_arc(Vector2(460,325),20,0,TAU,24,Color('f6ca68'),3)
  draw_circle(Vector2(300+fmod(beat_clock,1.6)/1.6*320,325),8,Color('74e1c6'))
 if kind=='calibrate':
  draw_line(Vector2(110,330),Vector2(660,330),Color('557087'),4)
  for i in 11:draw_line(Vector2(110+i*55,320),Vector2(110+i*55,340),Color('a6ccdf'),2)
  draw_circle(Vector2(110+value*55,330),9,Color('74e1c6'))
  draw_line(Vector2(440,310),Vector2(440,350),Color('f6ca68'),3)
 var preview:Dictionary={'scan':104,'cook':110,'search':25,'suit':16,'field':26,'assemble':23,'shelter':18,'chat':27,'grow':2}
 if preview.has(kind):draw_texture_rect(Art.prop(preview[kind]),Rect2(745,290,100,70),false)
 if kind=='scan':
  for n in 3:
   var x:float=70+n*195
   draw_rect(Rect2(x,305,160,45),Color('102234'))
   var points:=PackedVector2Array()
   for i in 40:points.append(Vector2(x+i*4,330+sin(i*0.8+elapsed*3)*8))
   draw_polyline(points,Color('74e1c6') if n in chosen else Color('557087'),2)
 if kind=='field':
  for i in 3:
   var at:=Vector2(160+i*190,325)
   draw_circle(at,11,Color('74e1c6') if i in chosen else Color('557087'))
   if i<2:draw_line(at+Vector2(15,0),at+Vector2(175,0),Color('a6ccdf'),2)
 if kind=='cook':
  for i in 3:
   draw_circle(Vector2(250+i*130,325),24,[Color('dbb86c'),Color('b2816c'),Color('82c965')][i])
 if kind=='assemble':
  for i in chosen:draw_rect(Rect2(180+i*100,315,75,20),Color('74e1c6'))
