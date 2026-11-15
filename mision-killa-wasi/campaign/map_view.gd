extends Control
var game:Node
var ui:CanvasLayer
var selected:=''
var room_boxes:Dictionary={}
var links:Dictionary={
 'corridor':['engineering','medical','bedroom','crops','minerals','gym','command','shelter','airlock'],
 'bedroom':['corridor','hygiene'],'hygiene':['bedroom'],'airlock':['corridor','exterior'],
 'engineering':['corridor'],'medical':['corridor'],'crops':['corridor'],'minerals':['corridor'],
 'gym':['corridor'],'command':['corridor'],'shelter':['corridor'],'exterior':['airlock']}
var selected_label:Label
const NAMES=preload('res://campaign/catalog.gd').ROOMS
func _ready()->void:
 selected=Mission.room
 var places:Dictionary={'command':Vector2(230,0),'engineering':Vector2(20,70),'medical':Vector2(20,145),'bedroom':Vector2(20,220),'hygiene':Vector2(20,295),'crops':Vector2(440,70),'minerals':Vector2(440,145),'gym':Vector2(440,220),'corridor':Vector2(230,75),'shelter':Vector2(230,150),'airlock':Vector2(230,225),'exterior':Vector2(230,300)}
 for id in places:
  var room_id:String=id
  var rect:=Rect2(places[id],Vector2(180,54));room_boxes[id]=rect
  var marker:String=('● ' if id==Mission.room else '')+('★ ' if id==Mission.current().get('room','') else '')
  var b:Button=ui.button(self,marker+NAMES[id],rect,func():selected=room_id;queue_redraw())
  b.add_theme_font_size_override('font_size',14)
 selected_label=ui.label(self,'',Rect2(655,0,425,60),19)
 ui.label(self,"● You   ★ Destination   Select a room to preview its layout.",Rect2(650,305,430,50),15)

func _process(_delta:float)->void:
 selected_label.text=NAMES[selected]+("\nYou are here" if selected==Mission.room else "\nPreview · No teleporting")
 queue_redraw()

func local_point(at:Vector2)->Vector2:
 var bounds:=Vector2(2172,724) if selected=='exterior' else Vector2(1280,720)
 return Vector2(660,82)+at/bounds*Vector2(410,210)

func _draw()->void:
 if room_boxes.is_empty():return
 for id in links:
  for neighbor in links[id]:
   var a:Vector2=room_boxes[id].get_center();var b:Vector2=room_boxes[neighbor].get_center()
   draw_line(a,b,Color('41647e'),3)
 for id in room_boxes:
  var rect:Rect2=room_boxes[id]
  if id==Mission.room:draw_circle(rect.position+Vector2(12,12),6,Color('74e1c6'))
  if id==Mission.current().get('room',''):draw_string(ThemeDB.fallback_font,rect.end-Vector2(18,6),'★',HORIZONTAL_ALIGNMENT_LEFT,-1,20,Color('f6ca68'))
  if id==selected:draw_style_box(ui.style(Color(0,0,0,0),Color('f6ca68')),rect.grow(3))
 var preview:=Rect2(650,70,430,230)
 draw_style_box(ui.style(Color('102234')),preview)
 if selected==Mission.room and is_instance_valid(game.world):
  if selected=='exterior':
   for polygon in game.world.exterior_polygons:
    var points:=PackedVector2Array()
    for point in polygon:points.append(local_point(point))
    draw_colored_polygon(points,Color('344656'))
  for obstacle in game.world.obstacles:
   var a:=local_point(obstacle.position);var b:=local_point(obstacle.end)
   draw_rect(Rect2(a,b-a),Color('557087'))
  for entry in game.world.entries:
   draw_circle(local_point(entry.visual),4,Color('74c9d7'))
   if entry.id==Mission.current().get('target',''):draw_circle(local_point(entry.at),8,Color('f6ca68'),false,2)
  for door in game.world.doors:draw_rect(Rect2(local_point(door.at)-Vector2(6,3),Vector2(12,6)),Color('e4edf5'))
  for npc in game.world.npc_actors:draw_circle(local_point(npc.position),3,Color('79cfef'))
  draw_circle(local_point(game.hero.position),6,Color('74e1c6'))
  draw_arc(local_point(game.hero.position),10,0,TAU,16,Color.WHITE,1)
 else:
  var list:Array=[]
  var Catalog=preload('res://campaign/catalog.gd')
  for item in Catalog.items()+Catalog.extra_items():
   if item.room==selected:list.append(item)
  var slots:Array=[Vector2(230,305),Vector2(500,305),Vector2(800,305),Vector2(1060,305),Vector2(230,515),Vector2(500,515),Vector2(1000,515)]
  if list.size()<=4:slots=[Vector2(280,305),Vector2(980,305),Vector2(280,520),Vector2(980,520)]
  for i in list.size():draw_rect(Rect2(local_point(slots[i])-Vector2(16,10),Vector2(32,20)),Color('557087'))
  draw_string(ThemeDB.fallback_font,Vector2(680,275),"Your position appears in your current room.",HORIZONTAL_ALIGNMENT_LEFT,-1,16,Color('bad0e3'))
