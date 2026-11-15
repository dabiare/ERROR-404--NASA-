extends Node2D
const Catalog=preload("res://campaign/catalog.gd")
const Art=preload("res://campaign/art.gd")
const Actor=preload("res://campaign/actor.gd")
@export var room_id: String="corridor"
var entries: Array[Dictionary]=[]
var doors: Array[Dictionary]=[]
var obstacles: Array[Rect2]=[]
var npc_actors: Array=[]
var nav:=AStarGrid2D.new()
var exterior_polygons: Array[PackedVector2Array]=[]
var nearest: Dictionary={}
var hero: CharacterBody2D
var robot: CharacterBody2D
var route_clock:=0.0
var clock:=0.0
var meteor: Node2D
var state_labels: Dictionary={}

func _ready() -> void:
 if room_id=="exterior": build_exterior()
 else: build_room()
 build_nav()
 populate_npcs()

func wall(rect: Rect2) -> void:
 obstacles.append(rect)
 var body:=StaticBody2D.new()
 var shape:=CollisionShape2D.new()
 var box:=RectangleShape2D.new()
 box.size=rect.size
 shape.shape=box
 body.position=rect.get_center()
 body.add_child(shape)
 add_child(body)

func add_door(to: String, at: Vector2) -> void:
 doors.append({"id":"door_"+to,"to":to,"title":Catalog.ROOMS[to],"at":at,"door":true})

func build_room() -> void:
 var background:=Sprite2D.new()
 background.texture=load(Catalog.ART+"room_shell.png")
 background.centered=false
 background.z_index=-100
 background.position=Vector2(40,115)
 background.scale=Vector2(1200,540)/background.texture.get_size()
 background.modulate=Color("ecf4ff") if room_id!="bedroom" else Color("c4c8e6")
 add_child(background)
 wall(Rect2(40,110,1200,38)); wall(Rect2(40,644,1200,30))
 wall(Rect2(40,110,40,560)); wall(Rect2(1200,110,40,560))
 if room_id=="corridor":
  for d in [["engineering",Vector2(125,230)],["medical",Vector2(125,410)],["bedroom",Vector2(240,605)],["crops",Vector2(1155,230)],["minerals",Vector2(1155,410)],["gym",Vector2(1040,605)],["command",Vector2(640,175)],["shelter",Vector2(640,365)],["airlock",Vector2(640,605)]]: add_door(d[0],d[1])
  return
 if room_id=="airlock":
  add_door("corridor",Vector2(640,180)); add_door("exterior",Vector2(640,610))
 elif room_id=="hygiene": add_door("bedroom",Vector2(120,400))
 else: add_door("corridor",Vector2(640,610))
 if room_id=="bedroom": add_door("hygiene",Vector2(1150,400))
 var local_items: Array=[]
 for entry in Catalog.items()+Catalog.extra_items():
  if entry.room==room_id: local_items.append(entry)
 var slots: Array[Vector2]=[Vector2(230,305),Vector2(500,305),Vector2(800,305),Vector2(1060,305),Vector2(230,515),Vector2(500,515),Vector2(1000,515)]
 if local_items.size()<=4: slots=[Vector2(280,305),Vector2(980,305),Vector2(280,520),Vector2(980,520)]
 for i in local_items.size(): add_station(local_items[i],slots[i])
 if room_id=="bedroom":
  for at in [Vector2(510,300),Vector2(750,300),Vector2(270,515),Vector2(970,515)]: decor(20,at,Vector2(135,140),true)
 if room_id=="shelter":
  decor(13,Vector2(1050,510),Vector2(125,150),true)
  decor(27,Vector2(320,515),Vector2(170,110),true)
 if room_id=="gym": decor(109,Vector2(900,450),Vector2(220,160),true)
 if room_id=="crops": decor(2,Vector2(930,500),Vector2(230,170),true)
 if room_id in ["engineering","medical","minerals","gym","command"]:
  var posters: Dictionary={"engineering":"MODULO DE INGENIERIA.jpg","medical":"BAHIA MEDICA.jpg","minerals":"GEOLOGIA.jpg","gym":"GYM.jpg","command":"centro de mando.jpg"}
  var poster:=Sprite2D.new()
  poster.texture=load("res://campaign/references/"+posters[room_id])
  poster.position=Vector2(640,235)
  poster.scale=Vector2(195,100)/poster.texture.get_size()
  poster.modulate=Color(0.7,0.85,1,0.9)
  add_child(poster)

func decor(art: int, at: Vector2, size: Vector2, solid: bool) -> Sprite2D:
 var s:=Sprite2D.new()
 s.texture=Art.prop(art)
 s.position=at-Vector2(0,size.y/2)
 s.scale=size/s.texture.get_size()
 s.z_index=int(at.y)-25
 add_child(s)
 if solid: wall(Rect2(at-Vector2(size.x*0.4,50),Vector2(size.x*0.8,50)))
 return s

func add_station(data: Dictionary, at: Vector2) -> void:
 var e: Dictionary=data.duplicate()
 e.at=at+Vector2(0,40)
 e.visual=at
 entries.append(e)
 decor(int(data.art),at,Vector2(155,140),true)
 var label:=Label.new()
 label.text=data.title
 label.position=at+Vector2(-110,6)
 label.size=Vector2(220,28)
 label.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER
 label.add_theme_font_size_override("font_size",14)
 label.add_theme_color_override("font_color",Color("e8f5ff"))
 label.add_theme_color_override("font_shadow_color",Color("122033"))
 label.add_theme_constant_override("shadow_offset_x",1)
 label.add_theme_constant_override("shadow_offset_y",2)
 label.z_index=900
 add_child(label)
 var state:=Label.new()
 state.position=at+Vector2(-115,60)
 state.size=Vector2(230,36)
 state.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART
 state.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER
 state.add_theme_font_size_override("font_size",11)
 state.add_theme_color_override("font_color",Color("83f2d4"))
 state.z_index=900
 add_child(state)
 state_labels[data.id]=state

func build_exterior() -> void:
 # Reuse the team's terrain and artwork without instantiating its old controller.
 var source: Node2D=load("res://base_lunar.tscn").instantiate()
 for node_name in ["FondoLunar","LimitesTerreno"]:
  var child: Node=source.get_node(node_name)
  child.owner=null
  source.remove_child(child)
  add_child(child)
  if node_name=="FondoLunar": child.z_index=-100
  if node_name=="LimitesTerreno":
   for polygon in child.get_children(): exterior_polygons.append(polygon.polygon)
 source.free()
 add_door("airlock",Vector2(1045,455))
 var rover: Dictionary=Catalog.extra_items()[1]
 add_station(rover,Vector2(1400,455))
 add_station(Catalog.extra_items()[2],Vector2(1665,420))
 meteor=preload("res://campaign/meteorito_lunar.gd").new()
 meteor.z_index=800
 add_child(meteor)

func build_nav() -> void:
 var cell:=10 if room_id=="exterior" else 20
 nav.region=Rect2i(0,0,220 if room_id=="exterior" else 64,74 if room_id=="exterior" else 36)
 nav.cell_size=Vector2(cell,cell)
 nav.offset=Vector2.ONE*cell/2
 nav.diagonal_mode=AStarGrid2D.DIAGONAL_MODE_ONLY_IF_NO_OBSTACLES
 nav.update()
 for x in nav.region.size.x:
  for y in nav.region.size.y:
   var p:=Vector2(x*cell+cell/2,y*cell+cell/2)
   var valid:=Rect2(100,170,1080,455).has_point(p)
   if room_id=="exterior":
    valid=Rect2(24,410,2124,294).has_point(p)
    for polygon in exterior_polygons:
     if Geometry2D.is_point_in_polygon(p,polygon): valid=false
     for i in polygon.size():
      if Geometry2D.get_closest_point_to_segment(p,polygon[i],polygon[(i+1)%polygon.size()]).distance_to(p)<14: valid=false
   for rect in obstacles:
    if rect.grow(17).has_point(p): valid=false
   nav.set_point_solid(Vector2i(x,y),not valid)

func nearest_cell(at: Vector2) -> Vector2i:
 var p:=Vector2i((at-nav.offset)/nav.cell_size)
 if nav.is_in_boundsv(p) and not nav.is_point_solid(p): return p
 var best:=Vector2i(-1,-1)
 var distance:=INF
 for x in nav.region.size.x:
  for y in nav.region.size.y:
   var cell:=Vector2i(x,y)
   if nav.is_point_solid(cell): continue
   var d:=nav.get_point_position(cell).distance_squared_to(at)
   if d<distance: distance=d; best=cell
 return best

func path(from: Vector2, to: Vector2) -> PackedVector2Array:
 var a:=nearest_cell(from)
 var b:=nearest_cell(to)
 if a.x<0 or b.x<0: return PackedVector2Array()
 return nav.get_point_path(a,b)

func safe_position(at: Vector2) -> Vector2:
 return nav.get_point_position(nearest_cell(at))

func populate_npcs() -> void:
 var gathering: bool=room_id=="shelter" and (not "meeting" in Mission.completed or Mission.current().get("id","") in ["shelter_all","dose_check","wait_control"])
 var ids: Array=[]
 if gathering: ids=["engineer","botanist","doctor","geologist"]
 else:
  for id in Catalog.HOME:
   if Catalog.HOME[id]==room_id: ids.append(id)
  if room_id=="exterior" and Mission.day()>=2: ids.append("geologist")
 for i in ids.size():
  var npc=Actor.new()
  npc.identity=ids[i]
  npc.speed=55
  npc.working=not gathering
  npc.position=safe_position(Vector2(430+i*140,410) if gathering else (Vector2(1280,430) if room_id=="exterior" else Vector2(660,400)))
  var saved: Dictionary=Mission.characters.get(npc.identity,{})
  if not gathering and saved.get("room","")==room_id and saved.get("position",[]).size()==2:
   npc.position=safe_position(Vector2(saved.position[0],saved.position[1]))
  add_child(npc)
  npc.work_label.text="Reunión de equipo" if gathering else Catalog.WORK[npc.identity]
  if not gathering and not entries.is_empty():
   var station: Vector2=entries[0].at
   if room_id=="exterior": station=Vector2(1370,510)
   npc.work_points.assign([safe_position(station+Vector2(45,15)),safe_position(station+Vector2(125,65))])
  npc_actors.append(npc)

func bind_actors(player: CharacterBody2D, companion: CharacterBody2D) -> void:
 hero=player
 robot=companion
 hero.exterior=room_id=="exterior"
 hero.position=safe_position(Mission.position)
 robot.position=safe_position(hero.position+Vector2(-45,25))

func destination_spawn(from: String) -> Vector2:
 for d in doors:
  if d.to==from:
   var offset: Vector2=(Vector2(640,410)-d.at).normalized()*75 if room_id!="exterior" else Vector2(0,80)
   return safe_position(d.at+offset)
 return safe_position(Vector2(640,565))

func _process(delta: float) -> void:
 if not is_instance_valid(hero): return
 nearest={}
 var distance:=95.0
 var candidates: Array=entries+doors
 for npc in npc_actors:
  candidates.append({"id":npc.identity,"title":Catalog.NAMES[npc.identity],"at":npc.position,"npc":true})
 for e in candidates:
  var d:=hero.position.distance_to(e.at)
  if d<distance:
   var route:=path(hero.position,e.at)
   var length:=0.0
   for i in range(1,route.size()): length+=route[i].distance_to(route[i-1])
   if route.size()>0 and length<155: nearest=e; distance=d
 if Mission.movable():
  clock+=delta
  route_clock+=delta
  if route_clock>0.5:
   route_clock=0
   if hero.position.distance_to(robot.position)>60:
    robot.route=path(robot.position,hero.position-Vector2(hero.facing*45,-15))
    robot.route_index=0
   else: robot.route=PackedVector2Array()
   for npc in npc_actors:
    Mission.remember_character(npc.identity,npc.position,room_id,npc.work_label.text)
    if npc.working and npc.route_index>=npc.route.size():
     npc.wait-=0.5
     if npc.wait<=0:
      npc.wait=randf_range(3,6)
      var destination: Vector2=npc.work_points[npc.work_point_index%npc.work_points.size()] if not npc.work_points.is_empty() else npc.position
      npc.work_point_index+=1
      npc.route=path(npc.position,destination)
      npc.route_index=0
  if room_id=="exterior" and Mission.day()==2 and hero.position.x>1550 and not Mission.optional.get("meteor_seen",false):
   Mission.optional.meteor_seen=true
   meteor.start()
   Mission.save_game()
 for id in state_labels:
  var value:=Mission.item_state(id)
  state_labels[id].text=value if value!="DISPONIBLE PARA CONSULTA" else ""
  if id=="vent" and Mission.emergency=="air" or id=="rover" and Mission.emergency=="rover": state_labels[id].modulate=Color("ffae87")
  else: state_labels[id].modulate=Color.WHITE
 queue_redraw()

func _draw() -> void:
 var font:=ThemeDB.fallback_font
 for d in doors:
  var selected: bool=nearest.get("id","")==d.id
  var rect:=Rect2(d.at-Vector2(75,26),Vector2(150,52))
  draw_style_box(door_style(selected),rect)
  draw_string(font,d.at+Vector2(-69,5),d.title,HORIZONTAL_ALIGNMENT_CENTER,138,14,Color("edf6ff"))
 for e in entries:
  if e.id==Mission.current().get("target","") or nearest.get("id","")==e.id:
   var rise:=sin(clock*3)*3 if not Mission.reduced_motion else 0.0
   draw_circle(e.at+Vector2(0,12+rise),10,Color("f6ca68"))
   draw_string(font,e.at+Vector2(-4,17+rise),"E",HORIZONTAL_ALIGNMENT_LEFT,-1,14,Color("17283d"))
 if room_id=="corridor":
  draw_string(font,Vector2(365,300),"KILLA WASI  /  HÁBITAT 01",HORIZONTAL_ALIGNMENT_CENTER,550,25,Color("a6ccdf"))
  draw_string(font,Vector2(365,335),"Acércate a una puerta y pulsa E",HORIZONTAL_ALIGNMENT_CENTER,550,17,Color("778fab"))

func door_style(selected: bool) -> StyleBoxFlat:
 var style:=StyleBoxFlat.new()
 style.bg_color=Color("213e54") if not selected else Color("405164")
 style.border_color=Color("63dce7") if not selected else Color("f6ca68")
 style.set_border_width_all(2)
 style.set_corner_radius_all(7)
 return style
