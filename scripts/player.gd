extends CharacterBody2D
const SPEED := 185.0
var facing := 0
var clock := 0.0
var foot_clock := 0.0
var sprite: Sprite2D
var camera: Camera2D
var walking_override := Vector2.ZERO

func _ready() -> void:
	collision_layer = 2
	collision_mask = 1
	var shape := CollisionShape2D.new()
	var circle := CircleShape2D.new()
	circle.radius = 13
	shape.shape = circle
	add_child(shape)
	sprite = Sprite2D.new()
	sprite.texture = load("res://assets/art/commander_walk.png")
	sprite.hframes = 4
	sprite.vframes = 4
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	sprite.scale = Vector2.ONE * (120.0 / (sprite.texture.get_height() / 4.0))
	sprite.position = Vector2(0, -47)
	add_child(sprite)
	camera = Camera2D.new()
	camera.position = Vector2(0, -60)
	camera.position_smoothing_enabled = false
	camera.limit_left = 0
	camera.limit_top = 0
	camera.limit_right = 1920
	camera.limit_bottom = 1280
	add_child(camera)

func _physics_process(delta: float) -> void:
	var direction := Input.get_vector("move_left", "move_right", "move_up", "move_down") if Session.can_move() else Vector2.ZERO
	if walking_override != Vector2.ZERO and Session.can_move(): direction = walking_override.normalized()
	velocity = direction * SPEED
	move_and_slide()
	if direction != Vector2.ZERO:
		if absf(direction.x) > absf(direction.y): facing = 1 if direction.x < 0 else 2
		else: facing = 3 if direction.y < 0 else 0
		clock += delta
		foot_clock += delta
		if foot_clock > 0.32:
			foot_clock = 0
			Sound.step()
	else: clock = 0
	sprite.frame = facing * 4 + (int(clock * 8) % 4 if direction != Vector2.ZERO else 0)
	z_index = int(position.y)
	queue_redraw()

func _draw() -> void:
	draw_ellipse_shadow()

func draw_ellipse_shadow() -> void:
	draw_set_transform(Vector2(0, -2), 0, Vector2(1, 0.35))
	draw_circle(Vector2.ZERO, 20, Color(0.02, 0.04, 0.06, 0.4))
	draw_set_transform(Vector2.ZERO)
