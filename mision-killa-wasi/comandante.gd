
extends CharacterBody2D

# Velocidad de movimiento
@export var velocidad: float = 200.0

# Animación de nuestra astronauta
@onready var animacion: AnimatedSprite2D = $AnimacionComandante


func _ready() -> void:
	animacion.play("idle")


func _physics_process(_delta: float) -> void:

	var direccion = Vector2.ZERO

	# Movimiento hacia arriba
	if Input.is_key_pressed(KEY_W):
		direccion.y -= 1

	# Movimiento hacia abajo
	if Input.is_key_pressed(KEY_S):
		direccion.y += 1

	# Movimiento hacia la izquierda
	if Input.is_key_pressed(KEY_A):
		direccion.x -= 1

	# Movimiento hacia la derecha
	if Input.is_key_pressed(KEY_D):
		direccion.x += 1

	# Aplicar velocidad
	velocity = direccion.normalized() * velocidad

	# Mover al personaje con colisiones
	move_and_slide()

	# Girar hacia la izquierda
	if direccion.x < 0:
		animacion.flip_h = true

	# Girar hacia la derecha
	elif direccion.x > 0:
		animacion.flip_h = false

	# Animación al caminar
	if direccion != Vector2.ZERO:

		if animacion.animation != "walk":
			animacion.play("walk")

		elif not animacion.is_playing():
			animacion.play()

	# Animación cuando está quieta
	else:

		if animacion.animation != "idle":
			animacion.play("idle")

		elif not animacion.is_playing():
			animacion.play()
