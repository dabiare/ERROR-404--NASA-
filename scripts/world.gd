extends Node2D
const Data = preload("res://scripts/mission_data.gd")
const Interaction = preload("res://scripts/interactable.gd")
@export var kind := "interior"
var walkable: Array[Rect2] = []
var rooms: Array[Dictionary] = []
var props: Array[Dictionary] = []
var interactions: Array[Area2D] = []
var npcs: Array[Sprite2D] = []
var time := 0.0
var player: CharacterBody2D
var nearest: Area2D
var grid := {}
var font: Font
var navigator := AStarGrid2D.new()
var route := PackedVector2Array()
var route_timer := 0.0
var solid_props: Array[Rect2] = []
var prop_textures := {}

func _ready() -> void:
	font = ThemeDB.fallback_font
	load_prop_atlas()
	if kind == "interior": build_interior()
	else: build_exterior()
	build_walls()
	build_navigation()
	player = CharacterBody2D.new()
	player.set_script(preload("res://scripts/player.gd"))
	player.position = Vector2(960,1055) if kind == "interior" else Vector2(470,790)
	add_child(player)
	Session.changed.connect(update_targets)
	update_targets()

func load_prop_atlas() -> void:
	var sheet: Texture2D = load("res://assets/art/props.png")
	var source := sheet.get_image()
	var cell := Vector2i(sheet.get_width()/4,sheet.get_height()/3)
	var types := ["console","bed","planter","shelf","sample","generator","locker","tools","lander","habitat","solar","antenna"]
	for i in types.size():
		var region := Rect2i(Vector2i(i%4,i/4)*cell,cell)
		var bounds := opaque_bounds(source.get_region(region))
		var atlas := AtlasTexture.new()
		atlas.atlas=sheet
		atlas.region=Rect2(region.position+bounds.position,bounds.size)
		prop_textures[types[i]]=atlas

func opaque_bounds(image: Image) -> Rect2i:
	# Atlas selection only: ignore near-transparent export padding, preserve the PNG.
	var minimum := Vector2i(image.get_width(),image.get_height())
	var maximum := Vector2i.ZERO
	for y in range(0,image.get_height(),2):
		for x in range(0,image.get_width(),2):
			if image.get_pixel(x,y).a>0.8:
				minimum=minimum.min(Vector2i(x,y))
				maximum=maximum.max(Vector2i(x,y))
	if maximum.x<minimum.x: return image.get_used_rect()
	return Rect2i(minimum,maximum-minimum+Vector2i(2,2)).grow(2).intersection(Rect2i(Vector2i.ZERO,image.get_size()))

func build_interior() -> void:
	rooms = [
		{"rect":Rect2(704,128,512,320),"name":"CENTRO DE MANDO","sub":"COMUNICACIONES / PLANIFICACIÓN","color":Color("73d6d2")},
		{"rect":Rect2(128,160,448,288),"name":"BAHÍA MÉDICA","sub":"SALUD / DESCANSO","color":Color("6dd5e9")},
		{"rect":Rect2(1344,128,448,352),"name":"INVERNADERO","sub":"CULTIVOS / OBSERVACIÓN","color":Color("83d9a2")},
		{"rect":Rect2(128,672,448,352),"name":"INGENIERÍA Y ALMACÉN","sub":"ENERGÍA / REPUESTOS","color":Color("f59a58")},
		{"rect":Rect2(1344,672,448,352),"name":"LABORATORIO","sub":"GEOLOGÍA / MEDICIONES","color":Color("ceaa84")}
	]
	for room in rooms: walkable.append(room.rect)
	walkable.append_array([Rect2(128,480,1664,128),Rect2(864,448,192,672),Rect2(288,448,128,32),Rect2(288,608,128,64),Rect2(1504,608,128,64)])
	add_prop("console",Rect2(832,220,256,140),Color("73d6d2"))
	add_prop("screen",Rect2(736,200,64,64),Color("73d6d2"))
	add_prop("screen",Rect2(1120,200,64,64),Color("73d6d2"))
	add_prop("table",Rect2(1100,335,64,64),Color("7ea3ae"))
	add_interaction("radio","Contactar al equipo",Vector2(960,394))
	add_prop("bed",Rect2(164,232,80,144),Color("6dd5e9"))
	add_prop("bed",Rect2(456,232,80,144),Color("6dd5e9"))
	add_prop("cabinet",Rect2(288,226,112,48),Color("6dd5e9"))
	add_npc("doctor",Vector2(350,335))
	for x in [1380,1664]:
		for y in [220,340]: add_prop("planter",Rect2(x,y,88,78),Color("83d9a2"))
	add_npc("botanist",Vector2(1550,325))
	add_prop("shelf",Rect2(160,740,144,100),Color("f59a58"))
	add_prop("shelf",Rect2(384,740,144,100),Color("f59a58"))
	add_interaction("shelf_a","Revisar estante A",Vector2(232,880))
	add_interaction("shelf_b","Revisar estante B",Vector2(456,880))
	add_prop("generator",Rect2(160,929,96,60),Color("f59a58"))
	add_prop("tools",Rect2(432,928,96,60),Color("f59a58"))
	add_npc("engineer",Vector2(345,920))
	add_prop("console",Rect2(1380,750,144,110),Color("ceaa84"))
	add_prop("sample",Rect2(1620,750,120,100),Color("ceaa84"))
	add_interaction("lab_console","Encender consola",Vector2(1452,896))
	add_interaction("sample","Registrar muestra",Vector2(1680,888))
	add_prop("cabinet",Rect2(1380,948,128,40),Color("ceaa84"))
	add_npc("geologist",Vector2(1580,945))
	add_interaction("exit","Consultar esclusa",Vector2(960,1080))
	add_prop("locker",Rect2(880,790,45,130),Color("f5c65b"))

func build_exterior() -> void:
	walkable.append(Rect2(192,384,1536,704))
	add_prop("lander",Rect2(312,480,210,220),Color("f5c65b"))
	add_prop("habitat",Rect2(1090,380,440,295),Color("73d6d2"))
	add_prop("solar",Rect2(1360,870,240,130),Color("6db6e0"))
	add_prop("antenna",Rect2(940,490,72,100),Color("73d6d2"))
	add_prop("crate",Rect2(880,910,68,58),Color("cbae7d"))
	add_prop("crate",Rect2(970,925,54,48),Color("cbae7d"))
	add_interaction("airlock","Entrar en la esclusa",Vector2(1310,730))
	for x in [660,850,1040,1230]:
		add_prop("beacon",Rect2(x,812,12,24),Color("73d6d2"),false)

func add_npc(id: String, at: Vector2) -> void:
	var actor := Sprite2D.new()
	actor.texture = Data.portrait(id,true)
	actor.scale = Vector2.ONE * (112.0 / actor.texture.get_height())
	actor.position = at + Vector2(0,-50)
	actor.z_index = int(at.y)
	actor.set_meta("origin",actor.position)
	actor.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	add_child(actor)
	npcs.append(actor)
	add_interaction(id,"Hablar · " + Data.CREW[id].name.capitalize(),at)
	add_collision(Rect2(at-Vector2(12,10),Vector2(24,20)))

func add_prop(type: String, rect: Rect2, color: Color, solid := true) -> void:
	props.append({"type":type,"rect":rect,"color":color})
	if solid: add_collision(rect)

func add_collision(rect: Rect2) -> void:
	solid_props.append(rect)
	var body := StaticBody2D.new()
	body.collision_layer = 1
	body.collision_mask = 2
	var c := CollisionShape2D.new()
	var shape := RectangleShape2D.new()
	shape.size = rect.size
	c.shape = shape
	body.position = rect.get_center()
	body.add_child(c)
	add_child(body)

func add_interaction(id: String, caption: String, at: Vector2) -> void:
	var interact := Area2D.new()
	interact.set_script(Interaction)
	interact.interaction_id = id
	interact.caption = caption
	interact.position = at
	add_child(interact)
	interactions.append(interact)

func is_floor(p: Vector2) -> bool:
	for rect in walkable:
		if rect.has_point(p): return true
	return false

func build_walls() -> void:
	for y in 40:
		var run_start := -1
		for x in 61:
			var open := x < 60 and is_floor(Vector2(x*32+16,y*32+16))
			if open: grid[Vector2i(x,y)] = true
			if not open and x < 60 and run_start == -1: run_start = x
			if (open or x == 60) and run_start != -1:
				add_collision(Rect2(run_start*32,y*32,(x-run_start)*32,32))
				run_start = -1

func build_navigation() -> void:
	navigator.region = Rect2i(0,0,60,40)
	navigator.cell_size = Vector2(32,32)
	navigator.offset = Vector2(16,16)
	navigator.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_NEVER
	navigator.update()
	for y in 40:
		for x in 60:
			var cell := Vector2i(x,y)
			var blocked := not grid.has(cell)
			var center := Vector2(cell)*32+Vector2(16,16)
			if not blocked:
				for rect in solid_props:
					if rect.grow(12).has_point(center):
						blocked=true
						break
			navigator.set_point_solid(cell,blocked)

func refresh_route() -> void:
	route.clear()
	if not Session.can_move(): return
	var best_distance := INF
	for station in interactions:
		if not station.target: continue
		var from := Vector2i(player.position/32)
		var to := Vector2i(station.position/32)
		if not navigator.is_in_boundsv(from) or not navigator.is_in_boundsv(to): continue
		if navigator.is_point_solid(from) or navigator.is_point_solid(to): continue
		var candidate := navigator.get_point_path(from,to)
		if candidate.size()>0 and candidate.size()<best_distance:
			best_distance=candidate.size()
			route=candidate

func target_ids() -> Array:
	match Session.stage:
		Session.Stage.ENTRY: return ["airlock"]
		Session.Stage.COMMUNICATIONS,Session.Stage.CHOICE: return ["radio"]
		Session.Stage.TASK:
			if Session.choice == "storage":
				var pending := []
				for id in ["shelf_a","shelf_b"]:
					if id not in Session.inspected: pending.append(id)
				return pending
			return ["sample"] if Session.lab_power else ["lab_console"]
	return []

func update_targets() -> void:
	var targets := target_ids()
	for object in interactions:
		object.target = object.interaction_id in targets
		object.tint = Color("f5c65b")
	queue_redraw()

func _process(delta: float) -> void:
	if not Session.paused:
		time += delta
		for npc in npcs:
			var origin: Vector2 = npc.get_meta("origin")
			npc.position = origin + Vector2(0,0 if Session.reduced_motion else sin(time*1.8+origin.x)*1.2)
	nearest = null
	var best := 91.0
	for object in interactions:
		object.focused = false
		var distance := player.position.distance_to(object.position)
		if distance < best:
			best = distance
			nearest = object
	if nearest and Session.can_move(): nearest.focused = true
	route_timer += delta
	if route_timer > 0.25:
		route_timer=0.0
		refresh_route()
	queue_redraw()

func _draw() -> void:
	if kind == "exterior": draw_exterior()
	else: draw_interior()
	for prop in props: draw_prop(prop)
	if Session.can_move():
		for i in range(1,route.size(),2):
			draw_rect(Rect2(route[i]-Vector2(3,3),Vector2(6,6)),Color(0.96,0.77,0.36,0.65))

func draw_interior() -> void:
	draw_rect(Rect2(0,0,1920,1280),Color("0b1420"))
	for rect in walkable:
		draw_rect(rect.grow(12),Color("40586a"))
		draw_rect(rect,Color("253b4c"))
	for room in rooms:
		draw_rect(room.rect,Color("344958"))
		draw_rect(Rect2(room.rect.position+Vector2(0,0),Vector2(room.rect.size.x,8)),room.color)
	for cell in grid:
		var p := Vector2(cell)*32
		draw_rect(Rect2(p+Vector2(1,1),Vector2(30,30)),Color(0.6,0.76,0.81,0.035))
		if (cell.x+cell.y)%4==0: draw_rect(Rect2(p+Vector2(4,4),Vector2(2,2)),Color("526573"))
		for dir in [Vector2i.UP,Vector2i.LEFT,Vector2i.RIGHT,Vector2i.DOWN]:
			if grid.has(cell+dir): continue
			var start := p
			var end := p
			if dir == Vector2i.UP: end += Vector2(32,0)
			elif dir == Vector2i.DOWN: start+=Vector2(0,32); end+=Vector2(32,32)
			elif dir == Vector2i.LEFT: end+=Vector2(0,32)
			else: start+=Vector2(32,0); end+=Vector2(32,32)
			draw_line(start,end,Color("92a7ad"),8)
			if dir == Vector2i.UP: draw_line(start+Vector2(0,8),end+Vector2(0,8),Color("536b7b"),8)
	for room in rooms:
		var p: Vector2 = room.rect.position
		draw_string(font,p+Vector2(20,35),room.name,HORIZONTAL_ALIGNMENT_LEFT,-1,17,room.color)
		draw_string(font,p+Vector2(20,55),room.sub,HORIZONTAL_ALIGNMENT_LEFT,-1,10,Color("9bafb9"))
	# Corridor stripes and doorway lights are navigational cues.
	for y in range(640,1080,64):
		draw_rect(Rect2(952,y,16,26),Color("455e69"))
	for x in range(192,1740,64):
		draw_rect(Rect2(x,538,24,4),Color("536b74"))
	for at in [Vector2(960,456),Vector2(352,464),Vector2(352,648),Vector2(1568,490),Vector2(1568,648)]:
		draw_rect(Rect2(at-Vector2(56,4),Vector2(112,8)),Color("73d6d2"))
	draw_string(font,Vector2(888,1000),"ESCLUSA  /  01",HORIZONTAL_ALIGNMENT_LEFT,-1,16,Color("9cbfc8"))
	draw_rect(Rect2(896,1095,128,12),Color("73d6d2"))
	if Session.lab_power:
		draw_circle(Vector2(1392,774),5,Color("83d9a2"))
	for i in Session.inspected.size():
		draw_rect(Rect2(320+i*20,702,12,6),Color("83d9a2"))

func draw_exterior() -> void:
	draw_rect(Rect2(0,0,1920,1280),Color("65717c"))
	var rng := RandomNumberGenerator.new()
	rng.seed = 35
	for i in 600:
		var p := Vector2(rng.randf_range(0,1920),rng.randf_range(0,1280))
		var v := rng.randf_range(0.35,0.6)
		draw_rect(Rect2(p,Vector2(rng.randi_range(2,9),rng.randi_range(2,5))),Color(v,v+0.04,v+0.07,0.5))
	for data in [Vector3(220,240,125),Vector3(780,310,95),Vector3(1800,680,160),Vector3(640,1190,110),Vector3(1280,1170,100),Vector3(180,1000,80)]:
		draw_set_transform(Vector2(data.x,data.y),0,Vector2(1,0.6))
		draw_circle(Vector2.ZERO,data.z,Color("89929a"))
		draw_circle(Vector2(8,8),data.z-9,Color("485664"))
		draw_arc(Vector2(0,0),data.z-12,0.2,3.2,30,Color("a3adb1"),4)
	draw_set_transform(Vector2.ZERO)
	for x in range(560,1280,42):
		draw_rect(Rect2(x,760,18,4),Color("aebbc0"))
	for rect in walkable:
		draw_rect(rect,Color(0.85,0.9,0.92,0.22),false,2)
	draw_string(font,Vector2(1120,353),"KILLA WASI   /   HÁBITAT 01",HORIZONTAL_ALIGNMENT_LEFT,-1,22,Color("e3eeed"))
	draw_string(font,Vector2(255,440),"MÓDULO DE DESCENSO",HORIZONTAL_ALIGNMENT_LEFT,-1,18,Color("d2d9d8"))
	for i in range(5):
		draw_rect(Rect2(1267,674+i*9,86,5),Color("b3c7cd"))

func draw_prop(prop: Dictionary) -> void:
	var r: Rect2 = prop.rect
	var c: Color = prop.color
	draw_rect(Rect2(r.position+Vector2(7,9),r.size),Color(0.01,0.03,0.05,0.35))
	if prop_textures.has(prop.type):
		draw_texture_rect(prop_textures[prop.type],r,false)
		return
	match prop.type:
		"console","screen":
			draw_rect(r,Color("748b99"))
			draw_rect(r.grow(-5),Color("112b3b"))
			draw_rect(Rect2(r.position+Vector2(10,9),r.size-Vector2(20,26)),Color("244954"))
			for i in 4:
				draw_rect(Rect2(r.position+Vector2(14+i*int((r.size.x-20)/4),16),Vector2(4,10+i*3)),c)
			draw_line(r.position+Vector2(12,r.size.y-12),r.end-Vector2(12,12),c,3)
		"shelf":
			draw_rect(r,Color("647b86"))
			for i in 3:
				var box := Rect2(r.position+Vector2(7+i*44,6),Vector2(38,36))
				draw_rect(box,Color("b58f60") if i!=1 else Color("8ca3a5"))
				draw_rect(Rect2(box.position+Vector2(13,0),Vector2(8,36)),Color("d5b780"))
			draw_line(r.position+Vector2(0,r.size.y-4),r.end-Vector2(0,4),c,5)
		"bed":
			draw_rect(r,Color("92a8ae"))
			draw_rect(r.grow(-6),Color("dbe3db"))
			draw_rect(Rect2(r.position+Vector2(9,39),r.size-Vector2(18,48)),Color("37768d"))
			draw_rect(Rect2(r.position+Vector2(12,9),Vector2(r.size.x-24,24)),Color("f0f1df"))
			draw_line(r.position+Vector2(9,49),r.position+Vector2(r.size.x-9,49),c,5)
		"planter":
			draw_rect(r,Color("7c9c9e"))
			draw_rect(r.grow(-6),Color("423f36"))
			for x in 3:
				for y in 2:
					var p := r.position+Vector2(17+x*26,20+y*32)
					draw_rect(Rect2(p-Vector2(7,1),Vector2(19,7)),Color("4d9e77"))
					draw_rect(Rect2(p-Vector2(1,8),Vector2(7,23)),c)
		"sample":
			draw_rect(r,Color("81949b"))
			draw_rect(r.grow(-5),Color("b7c8c6"))
			draw_circle(r.get_center(),20,Color("527984"))
			draw_colored_polygon(PackedVector2Array([r.get_center()+Vector2(-12,5),r.get_center()+Vector2(-8,-12),r.get_center()+Vector2(8,-8),r.get_center()+Vector2(14,6)]),Color("cbb391"))
		"habitat":
			draw_rect(r,Color("afbdc4"))
			draw_rect(r.grow(-12),Color("d4ddd9"))
			for x in range(int(r.position.x+20),int(r.end.x),64):
				draw_line(Vector2(x,r.position.y+12),Vector2(x,r.end.y-12),Color("92a7b0"),4)
			for x in [r.position.x+45,r.end.x-105]:
				draw_rect(Rect2(x,r.position.y+80,60,110),Color("2e5669"))
				draw_rect(Rect2(x+5,r.position.y+87,50,6),c)
			draw_rect(Rect2(r.get_center().x-55,r.end.y-115,110,115),Color("627e90"))
			draw_rect(Rect2(r.get_center().x-45,r.end.y-105,90,105),Color("172d40"))
			draw_rect(Rect2(r.get_center().x-40,r.end.y-100,80,6),c)
		"solar":
			draw_rect(r,Color("b0c2c8"))
			draw_rect(r.grow(-6),Color("213e69"))
			for x in range(int(r.position.x+8),int(r.end.x),30): draw_line(Vector2(x,r.position.y+6),Vector2(x,r.end.y-6),Color("729ac3"),2)
			for y in range(int(r.position.y+8),int(r.end.y),28): draw_line(Vector2(r.position.x+6,y),Vector2(r.end.x-6,y),Color("729ac3"),2)
		"lander":
			draw_line(r.position,r.end,Color("c9a773"),12)
			draw_line(Vector2(r.end.x,r.position.y),Vector2(r.position.x,r.end.y),Color("c9a773"),12)
			draw_rect(r.grow(-28),Color("d2ddd8"))
			draw_rect(r.grow(-42),Color("8fa5ad"))
			draw_rect(Rect2(r.position+Vector2(53,48),Vector2(104,60)),Color("26495c"))
			draw_rect(Rect2(r.position+Vector2(60,53),Vector2(89,6)),Color("79cfdf"))
			draw_rect(Rect2(r.position+Vector2(85,127),Vector2(40,65)),c)
		"antenna":
			draw_rect(Rect2(r.get_center()-Vector2(5,0),Vector2(10,50)),Color("bbcbd0"))
			draw_circle(r.position+Vector2(r.size.x/2,30),30,Color("a7bec7"))
			draw_arc(r.position+Vector2(r.size.x/2,30),23,0.4,4.0,24,Color("314b61"),4)
		"beacon":
			draw_rect(r,Color("263f50"))
			draw_rect(Rect2(r.position,Vector2(r.size.x,6)),c)
		_:
			draw_rect(r,Color("566c7b"))
			draw_rect(r.grow(-5),Color("849aa3"))
			draw_rect(Rect2(r.position+Vector2(8,8),Vector2(r.size.x-16,5)),c)
			if prop.type=="generator":
				for i in 4: draw_rect(Rect2(r.position+Vector2(12+i*18,21),Vector2(10,23)),Color("263f50"))
			if prop.type=="locker":
				for i in 3: draw_rect(Rect2(r.position+Vector2(5,38+i*28),Vector2(35,2)),Color("314958"))
