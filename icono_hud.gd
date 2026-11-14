class_name IconoHud
extends TextureRect

enum Efecto { PULSO, BALANCEO, PARPADEO, ALERTA, BURBUJAS, GOTAS, CHISPAS, HUMO }

@export var efecto: Efecto = Efecto.PULSO
@export var velocidad: float = 0.6
@export var particulas_por_segundo: float = 3.0
# Distancia máxima en píxeles que recorren las partículas
@export var alcance: float = 40.0

var tween: Tween
var particulas: CPUParticles2D

func _ready() -> void:
	# Esperamos un frame para que el contenedor ya le haya dado su tamaño
	await get_tree().process_frame
	pivot_offset = size / 2.0
	resized.connect(func(): pivot_offset = size / 2.0)
	reproducir()

func reproducir() -> void:
	detener()
	match efecto:
		Efecto.PULSO: _pulso()
		Efecto.BALANCEO: _balanceo(8.0)
		Efecto.PARPADEO: _parpadeo()
		Efecto.ALERTA: _alerta()
		Efecto.BURBUJAS: _burbujas()
		Efecto.GOTAS: _gotas()
		Efecto.CHISPAS: _chispas()
		Efecto.HUMO: _humo()

func detener() -> void:
	if tween:
		tween.kill()
	if particulas:
		particulas.queue_free()
		particulas = null
	scale = Vector2.ONE
	rotation_degrees = 0.0
	modulate = Color.WHITE

# ---------- Efectos simples ----------

func _pulso() -> void:
	tween = create_tween().set_loops()
	tween.tween_property(self, "scale", Vector2(1.15, 1.15), velocidad)\
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(self, "scale", Vector2.ONE, velocidad)\
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

func _balanceo(grados: float) -> void:
	tween = create_tween().set_loops()
	tween.tween_property(self, "rotation_degrees", grados, velocidad)\
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(self, "rotation_degrees", -grados, velocidad * 2.0)\
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(self, "rotation_degrees", 0.0, velocidad)\
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

func _parpadeo() -> void:
	tween = create_tween().set_loops()
	tween.tween_property(self, "modulate:a", 0.4, velocidad)
	tween.tween_property(self, "modulate:a", 1.0, velocidad)

func _alerta() -> void:
	# Se pone rojizo y tiembla de lado a lado
	tween = create_tween().set_loops()
	tween.tween_property(self, "modulate", Color(1.0, 0.4, 0.4), 0.25)
	tween.parallel().tween_property(self, "rotation_degrees", 6.0, 0.25)
	tween.tween_property(self, "modulate", Color.WHITE, 0.25)
	tween.parallel().tween_property(self, "rotation_degrees", -6.0, 0.25)

# ---------- Efectos con partículas ----------

func _burbujas() -> void:
	_crear_particulas(
		Vector2(size.x / 2.0, size.y * 0.2),  # origen
		Vector2(0, -1), 25.0,                 # dirección y desvío
		1.6, 0.06, 0.18                       # vida, escala min y max
	)
	particulas.emitting = false
	# Pop de entrada y luego flota con las burbujas
	scale = Vector2.ZERO
	tween = create_tween()
	tween.tween_property(self, "scale", Vector2.ONE, 0.5)\
		.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_callback(func(): particulas.emitting = true)
	tween.tween_callback(_balanceo.bind(3.0))

func _gotas() -> void:
	# Gotitas que caen desde abajo del ícono
	var vida := 1.2
	_crear_particulas(
		Vector2(size.x / 2.0, size.y * 0.8),
		Vector2(0, 1), 15.0,
		vida, 0.05, 0.12,
		Color.WHITE, true
	)
	_balanceo(5.0)

func _chispas() -> void:
	# Chispitas que salen en todas direcciones
	_crear_particulas(
		Vector2(size.x / 2.0, size.y / 2.0),
		Vector2(0, -1), 180.0,
		0.5, 0.04, 0.1,
		Color(1.0, 0.95, 0.5)
	)
	_pulso()

func _humo() -> void:
	# Humito gris que sube lento
	_crear_particulas(
		Vector2(size.x / 2.0, size.y * 0.3),
		Vector2(0, -1), 20.0,
		2.2, 0.12, 0.25,
		Color(0.8, 0.8, 0.8)
	)
	_balanceo(2.0)

func _crear_particulas(origen: Vector2, dir: Vector2, spread: float,
		vida: float, escala_min: float, escala_max: float,
		tinte: Color = Color.WHITE, con_gravedad: bool = false) -> void:
	particulas = CPUParticles2D.new()
	add_child(particulas)
	particulas.texture = texture
	particulas.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	particulas.show_behind_parent = true
	particulas.position = origen
	particulas.emission_shape = CPUParticles2D.EMISSION_SHAPE_SPHERE
	particulas.emission_sphere_radius = size.x * 0.2
	particulas.lifetime = vida
	particulas.amount = max(1, int(particulas_por_segundo * vida))
	particulas.direction = dir
	particulas.spread = spread

	if con_gravedad:
		# Arrancan quietas y caen: distancia = 0.5 * g * t²
		particulas.initial_velocity_min = 0.0
		particulas.initial_velocity_max = 0.0
		particulas.gravity = Vector2(0, 2.0 * alcance / (vida * vida))
	else:
		# Velocidad calculada para que lleguen justo hasta el alcance
		particulas.gravity = Vector2.ZERO
		particulas.initial_velocity_min = (alcance / vida) * 0.6
		particulas.initial_velocity_max = alcance / vida

	particulas.scale_amount_min = escala_min
	particulas.scale_amount_max = escala_max

	# Se desvanecen antes de llegar al límite
	var gradiente := Gradient.new()
	gradiente.offsets = PackedFloat32Array([0.3, 1.0])
	gradiente.colors = PackedColorArray([
		Color(tinte.r, tinte.g, tinte.b, 0.9),
		Color(tinte.r, tinte.g, tinte.b, 0.0)
	])
	particulas.color_ramp = gradiente
