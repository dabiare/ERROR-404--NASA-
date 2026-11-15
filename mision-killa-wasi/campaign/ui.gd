extends CanvasLayer
const Catalog=preload("res://campaign/catalog.gd")
const Art=preload("res://campaign/art.gd")
const HudIcon=preload("res://campaign/icono_hud.gd")
var game: Node
var root: Control
var hud: Control
var title: Label
var objective: Label
var hint: Label
var status: Label
var timer: Label
var stack: Array[Control]=[]
var fade: ColorRect
var current_icon: TextureRect
var icon_kind:=""
var type_clock:=0.0
var notice: Label
var notice_time:=0.0

func _ready() -> void:
 root=Control.new()
 root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
 root.mouse_filter=Control.MOUSE_FILTER_IGNORE
 add_child(root)
 hud=Control.new()
 hud.mouse_filter=Control.MOUSE_FILTER_IGNORE
 root.add_child(hud)
 panel(hud,Rect2(0,0,1280,105),Color("0b1829"))
 label(hud,"KILLA WASI",Rect2(26,13,210,24),18,Color("70dfdf"))
 title=label(hud,"",Rect2(26,42,390,30),23)
 objective=label(hud,"",Rect2(435,18,550,65),19)
 status=label(hud,"",Rect2(26,79,1130,22),13,Color("b8c9dc"))
 timer=label(hud,"",Rect2(1000,43,255,40),26,Color("ffb987"))
 panel(hud,Rect2(0,666,1280,54),Color("0b1829"))
 hint=label(hud,"",Rect2(70,680,685,30),17)
 button(hud,"R · Ayuda del robot",Rect2(800,675,220,34),show_help)
 button(hud,"M · Mapa",Rect2(1030,675,110,34),show_map)
 button(hud,"Esc · Pausa",Rect2(1150,675,115,34),show_pause)
 current_icon=HudIcon.new()
 current_icon.position=Vector2(20,675)
 current_icon.size=Vector2(32,32)
 current_icon.expand_mode=TextureRect.EXPAND_IGNORE_SIZE
 current_icon.stretch_mode=TextureRect.STRETCH_KEEP_ASPECT_CENTERED
 current_icon.efecto=HudIcon.Efecto.PULSO
 current_icon.mouse_filter=Control.MOUSE_FILTER_IGNORE
 hud.add_child(current_icon)
 notice=label(root,"",Rect2(300,115,680,48),18,Color("ffe5a4"))
 notice.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER
 fade=ColorRect.new()
 fade.color=Color(0.02,0.04,0.08,0)
 fade.size=Vector2(1280,720)
 fade.mouse_filter=Control.MOUSE_FILTER_IGNORE
 root.add_child(fade)

func style(color: Color=Color("13263d"),border: Color=Color("375b73")) -> StyleBoxFlat:
 var s:=StyleBoxFlat.new()
 s.bg_color=color
 s.border_color=border
 s.set_border_width_all(2)
 s.set_corner_radius_all(12)
 s.content_margin_left=14
 s.content_margin_right=14
 return s

func panel(parent: Node, rect: Rect2, color: Color=Color("13263d")) -> Panel:
 var p:=Panel.new()
 p.position=rect.position
 p.size=rect.size
 p.add_theme_stylebox_override("panel",style(color))
 parent.add_child(p)
 return p

func label(parent: Node, text: String, rect: Rect2, font_size:=20, color:=Color("edf5ff")) -> Label:
 var l:=Label.new()
 l.text=text
 l.position=rect.position
 l.size=rect.size
 l.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART
 l.add_theme_font_size_override("font_size",font_size)
 l.add_theme_color_override("font_color",color)
 l.mouse_filter=Control.MOUSE_FILTER_IGNORE
 parent.add_child(l)
 return l

func button(parent: Node, text: String, rect: Rect2, action: Callable) -> Button:
 var b:=Button.new()
 b.text=text
 b.position=rect.position
 b.size=rect.size
 b.add_theme_font_size_override("font_size",17)
 b.add_theme_stylebox_override("normal",style(Color("1c344b")))
 b.add_theme_stylebox_override("hover",style(Color("29465f"),Color("73d9e5")))
 b.add_theme_stylebox_override("focus",style(Color(0,0,0,0),Color("f6ca68")))
 b.add_theme_stylebox_override("pressed",style(Color("37576a"),Color("f6ca68")))
 b.pressed.connect(action)
 parent.add_child(b)
 return b

func picture(parent: Node, texture: Texture2D, rect: Rect2) -> TextureRect:
 var p:=TextureRect.new()
 p.position=rect.position
 p.size=rect.size
 p.texture=texture
 p.expand_mode=TextureRect.EXPAND_IGNORE_SIZE
 p.stretch_mode=TextureRect.STRETCH_KEEP_ASPECT_CENTERED
 p.mouse_filter=Control.MOUSE_FILTER_IGNORE
 parent.add_child(p)
 return p

func push(title_text: String, rect:=Rect2(155,135,970,510)) -> Control:
 var layer_panel:=Control.new()
 layer_panel.size=Vector2(1280,720)
 var dim:=ColorRect.new()
 dim.color=Color(0.02,0.04,0.08,0.84)
 dim.size=Vector2(1280,720)
 layer_panel.add_child(dim)
 root.add_child(layer_panel)
 var p:=panel(layer_panel,rect)
 layer_panel.set_meta("panel",p)
 layer_panel.set_meta("previous_focus",root.get_viewport().gui_get_focus_owner())
 label(p,title_text,Rect2(28,18,rect.size.x-55,65),27,Color("f6ca68"))
 stack.append(layer_panel)
 Mission.locks+=1
 fade.move_to_front()
 return p

func pop() -> void:
 if stack.is_empty(): return
 var top: Control=stack.pop_back()
 var focus=top.get_meta("previous_focus",null)
 root.remove_child(top)
 top.queue_free()
 Mission.locks=maxi(0,Mission.locks-1)
 if is_instance_valid(focus) and focus.is_inside_tree(): focus.grab_focus()
 Audio.voice.stop()

func clear() -> void:
 while not stack.is_empty(): pop()

func toast(text: String) -> void:
 notice.text=text
 notice_time=5

func show_lines(lines: Array, done:=Callable(), meeting:=false) -> void:
 var p:=push("COMUNICACIÓN DE LA TRIPULACIÓN",Rect2(140,435,1000,220) if meeting else Rect2(140,270,1000,350))
 if meeting:
  var header: Label=p.get_child(0)
  header.add_theme_font_size_override("font_size",18)
  header.size.y=30
  p.get_parent().get_child(0).color.a=0.35
 var pic:=picture(p,null,Rect2(25,40,110,150) if meeting else Rect2(25,75,145,195))
 var name_label:=label(p,"",Rect2(155,47,805,30) if meeting else Rect2(195,70,750,32),20 if meeting else 23)
 var body:=label(p,"",Rect2(155,81,805,80) if meeting else Rect2(195,116,750,135),20 if meeting else 23)
 var counter:=label(p,"",Rect2(155,180,300,26) if meeting else Rect2(195,280,300,26),15,Color("a9bfd5"))
 var index: Array=[0]
 var apply_page:=func():
  var line: Array=lines[index[0]]
  name_label.text=Catalog.NAMES.get(line[0],line[0])
  name_label.modulate=Color(Catalog.COLORS.get(line[0],"edf5ff"))
  pic.texture=Art.face(line[0]) if Catalog.PEOPLE.has(line[0]) else null
  body.text=line[1]
  body.visible_characters=0
  p.set_meta("typing",body)
  p.set_meta("speaker",line[0])
  counter.text="%d / %d · Enter o Espacio" % [index[0]+1,lines.size()]
 var next:=func():
  if body.visible_characters>=0 and body.visible_characters<body.text.length(): body.visible_characters=-1; Audio.voice.stop(); return
  index[0]+=1
  if index[0]>=lines.size():
   pop()
   if done.is_valid(): done.call()
  else: apply_page.call()
 var b:=button(p,"Continuar  →",Rect2(745,165,220,40) if meeting else Rect2(745,275,220,45),next)
 p.set_meta("advance",next)
 apply_page.call()
 b.grab_focus()

func show_item(entry: Dictionary) -> void:
 var p:=push(entry.title)
 picture(p,Art.prop(int(entry.art)),Rect2(35,90,190,200))
 label(p,entry.description,Rect2(255,95,675,160),23)
 label(p,"La ficha científica está en Fuentes y créditos del menú de pausa.",Rect2(255,260,675,50),15,Color("a9bfd5"))
 label(p,Mission.item_state(entry.id),Rect2(255,312,675,32),15,Color("74e1c6"))
 button(p,"¿Por qué importa?",Rect2(35,295,195,45),func(): show_lines([["control",Catalog.FACTS.get(entry.id,entry.description)]]))
 var t:=Mission.current()
 if t.get("target","")==entry.id and t.get("room","")==Mission.room:
  button(p,"Realizar tarea: "+t.title,Rect2(35,355,895,52),func(): pop(); game.begin_task()).grab_focus()
 else:
  button(p,"Seguir explorando",Rect2(255,355,675,52),pop).grab_focus()
 if entry.id=="spares" and Mission.priority=="lab" and "prepare" in Mission.completed and not Mission.optional.get("storage_later",false):
  button(p,"Completar preparación pendiente del almacén",Rect2(35,420,895,48),func(): Mission.optional_action("storage_later"); pop(); toast("Filtro de aire localizado y registrado."))
 if entry.id=="analyzer" and Mission.priority=="storage" and "prepare" in Mission.completed and not Mission.optional.get("lab_later",false):
  button(p,"Calibrar el laboratorio pendiente",Rect2(35,420,895,48),func(): Mission.optional_action("lab_later"); pop(); toast("Laboratorio calibrado."))
 if entry.id=="rock" and Mission.day()==2 and "sample2" in Mission.completed and not Mission.optional.get("extra_sample",false) and not Mission.optional.get("sample_cancelled",false):
  button(p,"Documentar y recoger una muestra extra",Rect2(35,420,895,48),func(): Mission.optional_action("extra_sample"); pop(); toast("Muestra extra documentada."))

func show_task() -> void:
 var t:=Mission.current()
 if t.is_empty(): return
 var p:=push(t.title)
 picture(p,Art.face(t.speaker),Rect2(25,90,140,180))
 label(p,Catalog.NAMES[t.speaker],Rect2(190,85,720,28),18,Color(Catalog.COLORS[t.speaker]))
 label(p,t.question,Rect2(190,125,720,90),24)
 for i in t.choices.size():
  var chosen: int=i
  var b:=button(p,t.choices[i],Rect2(190,235+i*62,720,51),func():
   if int(t.correct)>=0 and chosen!=int(t.correct):
    show_lines([[t.speaker,"Probemos otra idea. "+t.concept]])
   else:
    if int(t.correct)<0: confirm_choice(t,chosen)
    else: pop(); game.perform_task(chosen))
  if i==0: b.grab_focus()
 button(p,"R · Pedir una pista",Rect2(190,435,345,45),show_help)
 button(p,"Volver",Rect2(550,435,360,45),pop)

func confirm_choice(t: Dictionary, chosen: int) -> void:
 var p:=push("CONFIRMAR PRIORIDAD",Rect2(250,200,780,350))
 label(p,t.choices[chosen]+"\n\nLa decisión quedará registrada en el informe.",Rect2(35,95,710,120),23)
 button(p,"Confirmar",Rect2(35,260,340,50),func(): pop(); pop(); game.perform_task(chosen)).grab_focus()
 button(p,"Revisar opciones",Rect2(400,260,340,50),pop)

func show_help() -> void:
 if not Mission.active: return
 var t:=Mission.current()
 if t.is_empty(): show_lines([["robot","¡Qué equipo! Puedes recorrer las salas y descubrir los sistemas que te faltan."]]); return
 var n:=int(Mission.help_level.get(t.id,0))%3
 Mission.help_level[t.id]=n+1
 var answer: String=t.choices[maxi(0,int(t.correct))] if int(t.correct)>=0 else "Compara los beneficios de las dos opciones: ambas se pueden completar."
 var item_name: String=t.target
 for entry in Catalog.items()+Catalog.extra_items():
  if entry.id==t.target: item_name=entry.title
 var hints: Array=[t.concept,"Busca «%s» en %s. El objetivo amarillo señala el equipo adecuado." % [item_name,Catalog.ROOMS[t.room]],"El siguiente paso es: «%s». %s" % [t.title,answer]]
 if not stack.is_empty():
  var active_panel: Control=stack[-1].get_meta("panel")
  if active_panel.has_meta("next_action"): hints[2]="Ahora selecciona «%s». Después comprobaremos juntos el resultado." % active_panel.get_meta("next_action")
 show_lines([["robot","Pista %d de 3. %s" % [n+1,hints[n]]]])

func show_map() -> void:
 if not Mission.active: return
 var p:=push("MAPA DE KILLA WASI",Rect2(115,115,1050,535))
 picture(p,load(Catalog.ART+"mapa_base_killa_wasi_sistemas_v2.png"),Rect2(25,85,735,405))
 var t:=Mission.current()
 label(p,"ESTÁS EN\n"+Catalog.ROOMS[Mission.room]+"\n\nDESTINO\n"+Catalog.ROOMS.get(t.get("room","corridor"),"Base")+"\n\nLas puertas conectan con los pasillos. Higiene se accede desde el dormitorio.",Rect2(785,100,235,310),18)
 button(p,"Cerrar mapa",Rect2(785,425,235,55),pop).grab_focus()

func show_pause() -> void:
 var p:=push("PAUSA Y OPCIONES")
 for i in 3:
  var names: Array=["Música","Efectos y alarma","Voz del robot"]
  var keys: Array=["music","effects","voice"]
  label(p,names[i],Rect2(40,100+i*62,260,35),21)
  var slider:=HSlider.new()
  slider.position=Vector2(320,105+i*62)
  slider.size=Vector2(560,30)
  slider.min_value=0
  slider.max_value=1
  slider.step=0.05
  slider.value=Mission.settings[keys[i]]
  var key: String=keys[i]
  slider.value_changed.connect(func(value): Mission.settings[key]=value; Audio.set_levels(); Mission.save_settings())
  p.add_child(slider)
 var reduced:=CheckButton.new()
 reduced.text="Movimiento reducido"
 reduced.add_theme_font_size_override("font_size",20)
 reduced.position=Vector2(40,300)
 reduced.button_pressed=Mission.reduced_motion
 reduced.toggled.connect(func(value): Mission.reduced_motion=value; Mission.save_settings(); refresh_icon(true))
 p.add_child(reduced)
 button(p,"Volver",Rect2(40,370,270,50),pop).grab_focus()
 button(p,"Fuentes y créditos",Rect2(340,370,280,50),show_sources)
 button(p,"Guardar y salir al menú",Rect2(40,435,580,45),func():
  if Mission.active: Mission.position=game.hero.position; Mission.save_game()
  clear(); game.show_menu())
 button(p,"Informe de la misión",Rect2(650,370,280,110),show_report)

func show_sources() -> void:
 var p:=push("CIENCIA Y CRÉDITOS")
 var scroll:=ScrollContainer.new()
 scroll.position=Vector2(30,90)
 scroll.size=Vector2(910,330)
 p.add_child(scroll)
 scroll.get_v_scroll_bar().focus_mode=Control.FOCUS_ALL
 var text:=RichTextLabel.new()
 text.custom_minimum_size=Vector2(880,0)
 text.fit_content=true
 text.bbcode_enabled=true
 text.add_theme_font_size_override("normal_font_size",18)
 var content:="Proyecto del equipo ERROR 404 · Misión Killa Wasi\nArte del equipo y complementos de ImageGen. Música y Blip aportados por el equipo.\n\nLos tiempos son retos del juego; no son procedimientos médicos.\n\n"
 for entry in Catalog.items(): content+="[b]"+entry.title+"[/b]\n"+entry.source+"\n\n"
 text.text=content
 scroll.add_child(text)
 button(p,"Volver",Rect2(635,435,300,48),pop).grab_focus()

func show_report() -> void:
 var p:=push("INFORME · DÍA %d" % Mission.day())
 var scroll:=ScrollContainer.new()
 scroll.position=Vector2(40,90)
 scroll.size=Vector2(890,315)
 p.add_child(scroll)
 scroll.get_v_scroll_bar().focus_mode=Control.FOCUS_ALL
 var body:=label(scroll,Mission.report(),Rect2(0,0,855,0),20)
 body.custom_minimum_size.x=855
 button(p,"Seguir explorando",Rect2(40,425,420,50),pop).grab_focus()
 button(p,"Volver al menú",Rect2(490,425,440,50),func(): Mission.save_game(); clear(); game.show_menu())

func refresh_icon(force:=false) -> void:
 var t:=Mission.current()
 var kind:="10_reparacion"
 if t.get("room","")=="medical": kind="08_salud"
 if t.get("id","").begins_with("water"): kind="02_agua"
 if not Mission.emergency.is_empty(): kind="15_radiacion_solar" if Mission.emergency=="solar" else "07_co2"
 if icon_kind==kind and not force: return
 icon_kind=kind
 current_icon.texture=Art.icon(kind)
 current_icon.efecto=HudIcon.Efecto.ALERTA if not Mission.emergency.is_empty() else HudIcon.Efecto.PULSO
 if Mission.reduced_motion: current_icon.detener()
 else: current_icon.reproducir()

func _process(delta: float) -> void:
 hud.visible=Mission.active
 if Mission.active:
  var t:=Mission.current()
  title.text="Día %d · %s" % [Mission.day(),Catalog.ROOMS[Mission.room]]
  objective.text=t.get("title","Primeros tres días completados · Explora la base")
  status.text="Agua reserva: %d   ·   Muestras: %d   ·   Registros: %d   ·   Sistemas: %d/26" % [Mission.inventory.agua_reserva,Mission.inventory.muestras,Mission.inventory.registros,Mission.visited.size()]
  if not Mission.save_error.is_empty(): status.text=Mission.save_error
  timer.text="%02d:%02d  %s" % [int(Mission.remaining)/60,int(Mission.remaining)%60,"Ⅱ" if not Mission.movable() else ""] if not Mission.emergency.is_empty() else ""
  refresh_icon()
 notice_time=maxf(0,notice_time-delta)
 notice.visible=notice_time>0
 if not stack.is_empty() and Mission.focused:
  var p: Control=stack[-1].get_meta("panel")
  if p.has_meta("typing"):
   var body: Label=p.get_meta("typing")
   if body.visible_characters>=0 and body.visible_characters<body.text.length():
    type_clock+=delta
    if type_clock>=0.025:
     type_clock=0
     var c: String=body.text[body.visible_characters]
     body.visible_characters+=1
     if p.get_meta("speaker","")=="robot" and c.strip_edges()!="": Audio.blip()
     if body.visible_characters>=body.text.length(): Audio.voice.stop()

func _input(event: InputEvent) -> void:
 if event is InputEventKey and event.echo: return
 if event.is_action_pressed("help") and Mission.active:
  get_viewport().set_input_as_handled(); show_help()
 elif event.is_action_pressed("map") and Mission.active:
  get_viewport().set_input_as_handled()
  if stack.is_empty(): show_map()
 elif event.is_action_pressed("pause"):
  get_viewport().set_input_as_handled()
  if stack.is_empty(): show_pause()
  else:
   var p: Control=stack[-1].get_meta("panel")
   if p.has_meta("advance") or p.has_meta("required_ack"): show_pause()
   else: pop()
 elif event.is_action_pressed("dialogue_next") and not stack.is_empty():
  var p: Control=stack[-1].get_meta("panel")
  if p.has_meta("advance"):
   get_viewport().set_input_as_handled()
   var advance: Callable=p.get_meta("advance")
   advance.call()
