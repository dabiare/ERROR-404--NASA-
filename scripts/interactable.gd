extends Area2D
var interaction_id := ""
var caption := ""
var focused := false
var target := false
var radius := 90.0
var tint := Color("f5c65b")
var phase := 0.0

func _ready() -> void:
	collision_layer = 0
	collision_mask = 0
	var c := CollisionShape2D.new()
	var circle := CircleShape2D.new()
	circle.radius = radius
	c.shape = circle
	add_child(c)
	z_index = 2000

func _process(delta: float) -> void:
	if not Session.paused and not Session.reduced_motion: phase += delta
	queue_redraw()

func _draw() -> void:
	if not target and not focused: return
	var rise := 3.0 * sin(phase * 3.0) if not Session.reduced_motion else 0.0
	var y := -70.0 + rise
	var c := tint if target else Color("a5c7cb")
	draw_colored_polygon(PackedVector2Array([Vector2(-9,y),Vector2(0,y-9),Vector2(9,y),Vector2(0,y+9)]),c)
	draw_circle(Vector2(0,y),2,Color("142331"))
	if focused:
		draw_arc(Vector2(0,-10), 26, 0, TAU, 24, Color(c,0.75),2)
