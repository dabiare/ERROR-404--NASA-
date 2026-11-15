extends CharacterBody2D
const Art = preload("res://campaign/art.gd")
var identity := "commander"
var controlled := false
var robot := false
var exterior := false
var sprite: AnimatedSprite2D
var clock := 0.0
var foot_clock := 0.0
var surprised := 0.0
var working := false
var route := PackedVector2Array()
var route_index := 0
var speed := 200.0
var work_label: Label
var wait := 2.0
var facing := 1.0
var work_points: Array[Vector2]=[]
var work_point_index:=0

func _ready() -> void:
 collision_layer=2 if controlled else 4
 collision_mask=1
 var body_shape := CollisionShape2D.new()
 var circle := CircleShape2D.new()
 circle.radius=12 if not robot else 9
 body_shape.shape=circle
 add_child(body_shape)
 sprite=AnimatedSprite2D.new()
 var frames := SpriteFrames.new()
 frames.add_animation("idle")
 frames.add_frame("idle",Art.face(identity))
 frames.add_animation("walk")
 frames.set_animation_speed("walk",8)
 if controlled:
  for file in ["walk_01.png","walk_04.png","walk_06.png"]: frames.add_frame("walk",load("res://"+file))
 else: frames.add_frame("walk",Art.face(identity))
 sprite.sprite_frames=frames
 add_child(sprite)
 sprite.play("idle")
 work_label=Label.new()
 work_label.position=Vector2(-95,-110)
 work_label.size=Vector2(190,25)
 work_label.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER
 work_label.add_theme_font_size_override("font_size",12)
 work_label.add_theme_color_override("font_color",Color("b8d5dd"))
 add_child(work_label)
 refresh_sprite()

func refresh_sprite() -> void:
 var tex: Texture2D=sprite.sprite_frames.get_frame_texture(sprite.animation,sprite.frame)
 var h:=82.0 if not robot else 53.0
 sprite.scale=Vector2.ONE*(h/tex.get_height())
 sprite.position=Vector2(0,-h/2)
 sprite.flip_h=facing<0

func surprise() -> void:
 surprised=1.2

func _physics_process(delta: float) -> void:
 if not Mission.active: return
 if surprised>0 and Mission.focused:
  surprised=maxf(0,surprised-delta)
 var direction:=Vector2.ZERO
 if controlled and Mission.movable() and surprised<=0:
  direction=Input.get_vector("move_left","move_right","move_up","move_down")
 elif not controlled and Mission.movable() and surprised<=0:
  if route_index<route.size():
   var distance:=position.distance_to(route[route_index])
   if distance<7: route_index+=1
   else: direction=position.direction_to(route[route_index])
 var target_velocity:=direction*speed
 if controlled and exterior:
  velocity=velocity.move_toward(target_velocity,delta*(480 if direction!=Vector2.ZERO else 700))
  if not Mission.movable(): velocity=Vector2.ZERO
 else: velocity=target_velocity
 move_and_slide()
 var moving:=velocity.length()>4
 if moving:
  if absf(direction.x)>0.05: facing=signf(direction.x)
  clock+=delta
  if controlled:
   foot_clock+=delta
   if foot_clock>(0.65 if exterior else 0.34): Audio.step(); foot_clock=0
 elif Mission.movable(): clock+=delta*0.35
 var animation: String="walk" if moving else "idle"
 if sprite.animation!=animation: sprite.play(animation)
 if not Mission.movable(): sprite.pause()
 elif not sprite.is_playing(): sprite.play()
 refresh_sprite()
 sprite.rotation=0
 if not Mission.reduced_motion:
  var bounce:=absf(sin(clock*(4.8 if exterior and controlled else 9.0))) if moving else sin(clock*2)*0.3
  sprite.position.y-=bounce*(12 if exterior and controlled else 2.3)
  if not controlled and working and not moving: sprite.rotation=sin(clock*3)*0.035
 if surprised>0:
  sprite.rotation=sin(surprised*25)*0.08 if not Mission.reduced_motion else 0
  if not Mission.reduced_motion: sprite.position.y-=sin((1.2-surprised)/1.2*PI)*9
 elif not working: sprite.rotation=0
 z_index=int(position.y)
 queue_redraw()

func _draw() -> void:
 if robot and Mission.optional.get('robot_accessory',false):
  draw_string(ThemeDB.fallback_font,Vector2(-6,-58),'★',HORIZONTAL_ALIGNMENT_LEFT,-1,18,Color('f6ca68'))
 draw_set_transform(Vector2(0,-1),0,Vector2(1,0.3))
 draw_circle(Vector2.ZERO,17 if not robot else 12,Color(0.02,0.04,0.08,0.35))
 draw_set_transform(Vector2.ZERO)
 if surprised>0:
  draw_circle(Vector2(25,-85),13,Color("f6ca68"))
  draw_string(ThemeDB.fallback_font,Vector2(21,-79),"!",HORIZONTAL_ALIGNMENT_LEFT,-1,20,Color("142337"))
 elif working and velocity.length()<4 and not Mission.reduced_motion and Mission.movable():
  var at:=Vector2(facing*20,-40)
  var pulse:=0.5+0.5*sin(clock*5)
  match identity:
   "engineer": draw_arc(at,6,clock,clock+PI,8,Color(1,0.7,0.25,pulse),2)
   "botanist": draw_circle(at+Vector2(0,-pulse*5),3,Color(0.5,1,0.6,pulse))
   "doctor": draw_line(at-Vector2(4,0),at+Vector2(4,pulse*4-2),Color("79cfef"),2)
   "geologist": draw_arc(at,5,0,TAU,12,Color(1,0.85,0.55,pulse),1)
 if exterior and controlled and velocity.length()>10 and not Mission.reduced_motion:
  for i in 3:
   var t:=fmod(clock*1.5+i*0.3,1.0)
   draw_circle(Vector2(-velocity.normalized().x*t*25,-2-t*8),2,Color(0.65,0.65,0.7,(1-t)*0.35))
