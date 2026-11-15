@tool
class_name Meteorito
extends Sprite2D
## Ponlo en un Sprite2D, igual que la caja y los domos. Lo colocas y le das tamaño
## en el editor (Transform > Scale). Al darle play cae con física real y deja de arder al impactar.
##
## Tipos (basados en meteoritos reales):
##   VERDE = rocoso carbonáceo: ligero (~2.2 g/cm³), frágil, casi sin magnetismo.
##   GRIS  = condrita ordinaria: medio (~3.4 g/cm³), algo de hierro, magnetismo medio.
##   NEGRO = metálico hierro-níquel: muy denso (~7.8 g/cm³), muy magnético, sobrevive
##           intacto al impacto y destruye todo a su alrededor.
## Si no le pones textura usa la del tipo (res://sprites/meteorito_*.png).
##
## ÁNGULO: se mide respecto a la superficie (0° = rozando, 90° = vertical). El meteorito vuela en
## línea recta siguiendo ese ángulo (la gravedad solo lo acelera a lo largo del camino).
##
## LÍNEA DE EXPLOSIÓN: una coordenada Y. Si el meteorito llega a ella, explota ahí.
##
## EXPLOSIÓN: no se elige, es la consecuencia del impacto:
##   - FUERZA = energía cinética (½ · masa · velocidad²). Más pesado y más rápido = explosión más grande.
##   - FORMA = según el ángulo. Más vertical = explosión más redonda; más inclinado = alargada
##     hacia donde viajaba.
##
## Para que un objeto sea atraído por el magnetismo, ponlo en el grupo "iman" (Node2D).

enum Tipo { VERDE, GRIS, NEGRO }

enum Direccion { DERECHA, IZQUIERDA, AL_AZAR }

# Los radios de daño están pensados para escala 0.5 y crecen o bajan con el tamaño.
# La masa NO es fija: sale de densidad x tamaño real del sprite.
const DATOS := {
	Tipo.VERDE: {
		"textura": "res://sprites/meteorito_verde.png",
		"densidad": 2.2, "dano": 12.0, "radio": 70.0,
		"giro": 2.0,
		"fuego": 14, "tam_fuego": 3.0,
		"rebote": 0.15, "friccion": 0.7,
		"temblor": 4.0, "destruye_todo": false,
		"magnetismo": 0.1, "se_fragmenta": true,
	},
	Tipo.GRIS: {
		"textura": "res://sprites/meteorito_gris.png",
		"densidad": 3.4, "dano": 30.0, "radio": 130.0,
		"giro": 3.5,
		"fuego": 30, "tam_fuego": 4.0,
		"rebote": 0.1, "friccion": 0.7,
		"temblor": 8.0, "destruye_todo": false,
		"magnetismo": 0.5, "se_fragmenta": true,
	},
	Tipo.NEGRO: {
		"textura": "res://sprites/meteorito_negro.png",
		"densidad": 7.8, "dano": 9999.0, "radio": 280.0,
		"giro": 6.0,
		"fuego": 70, "tam_fuego": 5.0,
		"rebote": 0.05, "friccion": 0.7,
		"temblor": 16.0, "destruye_todo": true,
		"magnetismo": 1.0, "se_fragmenta": false,
	},
}

const ENERGIA_REF := 8.0e5          # energía de impacto "normal" (fuerza = 1.0)
const FUERZA_MIN := 0.5             # límites de la fuerza del impacto (para que ninguna explosión sea ridícula)
const FUERZA_MAX := 6.0
const VEL_ABLACION := 250.0         # a esta velocidad (px/s) la superficie brilla al máximo (corteza de fusión)
const AMORTIGUACION_AIRE := 0.02    # la atmósfera de Marte es muy delgada (~0.6% de la terrestre)
const ESTIRAMIENTO_ANGULO := 2.0    # cuánto se alarga la explosión hacia adelante a un ángulo casi 0°

@export var tipo: Tipo = Tipo.VERDE:
	set(valor):
		tipo = valor
		# en el editor, cambia la imagen solo si todavía usa la del tipo anterior
		if Engine.is_editor_hint() and is_node_ready() and _textura_por_defecto():
			texture = load(DATOS[tipo].textura)
@export var caer_al_iniciar := true
@export var retraso := 0.0  # segundos de espera antes de caer
@export var gravedad_marte := 0.38  # Marte tiene ~38% de la gravedad de la Tierra
## Los meteoritos reales no desaparecen: se quedan en el suelo, fríos y oscuros.
@export var desaparecer := false
## Si tu escena no tiene un suelo con colisión, pon aquí la altura (y) del suelo
## y se crea uno invisible. Con 0 usa los suelos que ya tengas.
@export var suelo_y := 0.0
## Atracción magnética hacia nodos del grupo "iman" (según el metal que tenga el tipo).
@export var alcance_iman := 250.0
@export var fuerza_iman := 3000.0

@export_group("Ángulos de caída")
## Ángulo de caída respecto a la superficie: 1° = casi horizontal, 90° = vertical.
@export_range(1.0, 90.0, 0.5, "suffix:°") var angulo_personalizado := 45.0:
	set(valor):
		angulo_personalizado = valor
		queue_redraw()
## Hacia qué lado avanza mientras cae.
@export var direccion: Direccion = Direccion.DERECHA:
	set(valor):
		direccion = valor
		queue_redraw()
## Desvío al azar (±grados) que se suma al ángulo cada vez que cae. 0 = siempre el mismo.
@export_range(0.0, 45.0, 0.5, "suffix:°") var variacion_angulo := 0.0:
	set(valor):
		variacion_angulo = valor
		queue_redraw()
## Activo: vuela en línea recta exactamente por el ángulo elegido (la gravedad solo lo acelera
## a lo largo de ese camino). Apagado: cae libre y la gravedad va curvando la trayectoria.
@export var mantener_angulo := true
## Con esto activo, el ángulo con el que impacta cambia la forma de la explosión
## (más inclinado = más alargada hacia adelante).
@export var efectos_por_angulo := true
## Dibuja en el editor la flecha del ángulo y la línea de explosión (no se ve al darle play).
@export var ver_trayectoria := true:
	set(valor):
		ver_trayectoria = valor
		queue_redraw()

@export_group("Línea de explosión (eje Y)")
## Si está activo, el meteorito explota al llegar a la coordenada Y indicada.
@export var explotar_en_linea_y := false:
	set(valor):
		explotar_en_linea_y = valor
		queue_redraw()
## Coordenada Y global de la línea. En Godot la y crece hacia abajo: el meteorito debe
## empezar con una y menor para llegar a ella. Si toca suelo o un objeto antes, explota ahí.
@export var linea_y := 600.0:
	set(valor):
		linea_y = valor
		queue_redraw()

@export_group("Fuerza del impacto")
## Rapidez con la que empieza a caer (píxeles/segundo), en la dirección del ángulo.
@export var rapidez_inicial := 80.0
## Velocidad máxima de caída (como la frenada de la atmósfera). Más alta = golpea más fuerte.
@export var velocidad_maxima := 300.0
## Multiplica la fuerza del impacto (1 = la que sale de masa y velocidad). La explosión
## sigue saliendo del impacto: esto solo la hace más o menos potente en general.
@export_range(0.5, 3.0, 0.1) var fuerza_extra := 1.0

@export_group("Suavidad")
## 0 = brusco, 1 = muy suave (menos rebote, polvo y fuego más lentos, temblor de cámara menor).
## No cambia el tamaño de la explosión: solo cómo se siente.
@export_range(0.0, 1.0, 0.05) var suavidad_impacto := 0.6
@export_group("")

static var _suelo: StaticBody2D

var _datos: Dictionary
var _cuerpo: RigidBody2D
var _fuego: CPUParticles2D
var _impactado := false
var _radio_cuerpo := 20.0
var _vel_previa := Vector2.ZERO  # velocidad justo antes del choque (para calcular la fuerza)
var _calor := 0.0                # 0 = frío, 1 = al rojo vivo (solo mientras cae rápido)
var _angulo_real := 45.0         # ángulo de entrada de esta caída (grados, respecto a la superficie)
var _dir_caida := Vector2.DOWN   # dirección de vuelo (según el ángulo)
var _pos_prev := Vector2.ZERO    # posición del paso anterior (para detectar que cruzó la línea de explosión)


## Crea y lanza un meteorito por código desde "pos" (coordenadas globales).
## Ejemplo: Meteorito.lanzar(self, Meteorito.Tipo.NEGRO, Vector2(500, -60))
## Después puedes cambiar m.angulo_personalizado, m.direccion, m.explotar_en_linea_y, etc.
## (antes de que empiece a caer).
static func lanzar(padre: Node, t: Tipo, pos: Vector2, suelo: float = 0.0) -> Meteorito:
	var m := Meteorito.new()
	m.tipo = t
	m.suelo_y = suelo
	m.scale = Vector2(0.5, 0.5)
	m.angulo_personalizado = randf_range(35.0, 80.0)
	m.direccion = Direccion.AL_AZAR
	m.rapidez_inicial = 80.0
	padre.add_child(m)
	m.global_position = pos
	return m


## Densidad del material en g/cm³ (útil para otros scripts).
func densidad() -> float:
	return DATOS[tipo].densidad


## True si el meteorito contiene hierro-níquel y reacciona a un imán.
func es_magnetico() -> bool:
	return DATOS[tipo].magnetismo > 0.0


## Ángulo con el que cayó (grados respecto a la superficie), útil para otros scripts.
func angulo_de_caida() -> float:
	return _angulo_real


# ---------------------------------------------------------------- ángulos

## Ángulo elegido en el inspector (grados respecto a la superficie).
func _angulo_base() -> float:
	return angulo_personalizado


## Ángulo final de esta caída: el elegido más el desvío al azar (si hay variación).
func _calcular_angulo() -> float:
	var a := _angulo_base()
	a += randf_range(-variacion_angulo, variacion_angulo)
	return clampf(a, 1.0, 90.0)


## Dirección de movimiento (vector unitario) para un ángulo y un lado (+1 derecha, -1 izquierda).
func _vector_angulo(grados: float, lado: float) -> Vector2:
	var r := deg_to_rad(grados)
	return Vector2(cos(r) * lado, sin(r))


func _lado_elegido() -> float:
	match direccion:
		Direccion.IZQUIERDA: return -1.0
		Direccion.AL_AZAR: return 1.0 if randf() > 0.5 else -1.0
		_: return 1.0


func _draw() -> void:
	if not Engine.is_editor_hint() or not ver_trayectoria:
		return
	# se dibuja en coordenadas del mundo, para que no se incline ni escale con el sprite
	draw_set_transform_matrix(get_global_transform().affine_inverse() * Transform2D(0.0, global_position))
	var base := _angulo_base()
	var lados: Array = [1.0, -1.0] if direccion == Direccion.AL_AZAR else [-1.0 if direccion == Direccion.IZQUIERDA else 1.0]
	for lado_v in lados:
		var lado: float = lado_v
		_flecha(base, lado, Color(1.0, 0.6, 0.1, 0.9), 3.0)
		if variacion_angulo > 0.0:
			_flecha(clampf(base - variacion_angulo, 1.0, 90.0), lado, Color(1.0, 0.6, 0.1, 0.35), 2.0, false)
			_flecha(clampf(base + variacion_angulo, 1.0, 90.0), lado, Color(1.0, 0.6, 0.1, 0.35), 2.0, false)
	var texto := "%d°" % int(round(base))
	draw_string(ThemeDB.fallback_font, Vector2(12.0, -12.0), texto, HORIZONTAL_ALIGNMENT_LEFT, -1, 16, Color(1.0, 0.6, 0.1))
	if explotar_en_linea_y:
		_dibujar_linea_explosion(lados, base)


func _flecha(grados: float, lado: float, color: Color, grosor: float, con_punta: bool = true) -> void:
	var dir := _vector_angulo(grados, lado)
	var fin := dir * 160.0
	draw_line(Vector2.ZERO, fin, color, grosor)
	if con_punta:
		var lado_p := dir.orthogonal() * 10.0
		draw_line(fin, fin - dir * 18.0 + lado_p, color, grosor)
		draw_line(fin, fin - dir * 18.0 - lado_p, color, grosor)


## Dibuja la línea horizontal de explosión (en y = linea_y) y dónde la cortaría el camino del ángulo.
func _dibujar_linea_explosion(lados: Array, base: float) -> void:
	var rojo := Color(1.0, 0.2, 0.1, 0.9)
	var ly := linea_y - global_position.y  # altura de la línea respecto al meteorito
	draw_line(Vector2(-6000.0, ly), Vector2(6000.0, ly), rojo, 3.0)
	draw_string(ThemeDB.fallback_font, Vector2(12.0, ly - 10.0), "línea de explosión  y = %d" % int(linea_y),
		HORIZONTAL_ALIGNMENT_LEFT, -1, 16, rojo)
	if ly <= 1.0:
		draw_string(ThemeDB.fallback_font, Vector2(12.0, ly + 24.0), "la línea queda arriba del meteorito: no llegará",
			HORIZONTAL_ALIGNMENT_LEFT, -1, 16, rojo)
		return
	for lado_v in lados:
		var lado: float = lado_v
		var dir := _vector_angulo(base, lado)
		var punto := dir * (ly / dir.y)  # donde el camino del ángulo corta la línea
		draw_dashed_line(Vector2.ZERO, punto, Color(1.0, 0.6, 0.1, 0.6), 2.0, 10.0)
		draw_circle(punto, 9.0, Color(1.0, 0.2, 0.1, 0.35))
		draw_arc(punto, 9.0, 0.0, TAU, 24, rojo, 2.0)
		draw_line(punto + Vector2(-14.0, 0.0), punto + Vector2(14.0, 0.0), rojo, 2.0)
		draw_line(punto + Vector2(0.0, -14.0), punto + Vector2(0.0, 14.0), rojo, 2.0)


# ---------------------------------------------------------------- ciclo de vida

func _textura_por_defecto() -> bool:
	if texture == null:
		return true
	for d in DATOS.values():
		if texture.resource_path == d.textura:
			return true
	return false


func _ready() -> void:
	_datos = DATOS[tipo]
	if texture == null:
		texture = load(_datos.textura)  # así lo ves en el editor
	if Engine.is_editor_hint():
		return

	if suelo_y > 0.0:
		_asegurar_suelo()

	if caer_al_iniciar:
		await get_tree().create_timer(maxf(retraso, 0.02)).timeout
		soltar()
	else:
		add_to_group("meteorito_espera")


## Hace que el meteorito empiece a caer (se llama solo si "caer_al_iniciar" está activo).
func soltar() -> void:
	if _cuerpo != null or Engine.is_editor_hint():
		return
	remove_from_group("meteorito_espera")
	add_to_group("meteorito")
	if es_magnetico():
		add_to_group("meteorito_magnetico")

	var padre := get_parent()
	var pos := global_position
	var rot := global_rotation
	var tam := texture.get_size() * global_scale.abs()
	_radio_cuerpo = minf(tam.x, tam.y) * 0.42

	# ángulo de esta caída y su dirección de vuelo
	_angulo_real = _calcular_angulo()
	_dir_caida = _vector_angulo(_angulo_real, _lado_elegido())

	if explotar_en_linea_y and pos.y >= linea_y:
		push_warning("Meteorito: ya está por debajo de la línea de explosión (y = %d); no llegará a ella." % int(linea_y))

	# --- el sprite pasa a ser hijo de un cuerpo con física, sin moverse de lugar ---
	_cuerpo = RigidBody2D.new()
	# masa real: densidad x área (un meteorito de hierro pesa mucho más que uno rocoso del mismo tamaño)
	_cuerpo.mass = _datos.densidad * _radio_cuerpo * _radio_cuerpo * 0.01
	_cuerpo.gravity_scale = gravedad_marte
	_cuerpo.contact_monitor = true
	_cuerpo.max_contacts_reported = 4
	# casi sin resistencia del aire y sin freno al giro (se conserva el momento angular)
	_cuerpo.linear_damp_mode = RigidBody2D.DAMP_MODE_REPLACE
	_cuerpo.linear_damp = AMORTIGUACION_AIRE
	_cuerpo.angular_damp_mode = RigidBody2D.DAMP_MODE_REPLACE
	_cuerpo.angular_damp = 0.0
	var mat := PhysicsMaterial.new()
	mat.bounce = _datos.rebote * _escala_suave()  # impacto suave: rebota menos
	mat.friction = _datos.friccion
	_cuerpo.physics_material_override = mat

	# forma irregular con bordes redondeados (nunca una esfera perfecta)
	var col := CollisionShape2D.new()
	col.shape = _forma_irregular(_radio_cuerpo)
	_cuerpo.add_child(col)

	padre.add_child(_cuerpo)
	_cuerpo.global_position = pos
	_cuerpo.global_rotation = rot
	reparent(_cuerpo)

	# giro libre (tumbling): se queda con el giro que trae, sin forzarlo
	_cuerpo.angular_velocity = _datos.giro * (1.0 if randf() > 0.5 else -1.0)
	_cuerpo.linear_velocity = _dir_caida * rapidez_inicial
	_vel_previa = _cuerpo.linear_velocity
	_pos_prev = global_position

	_cuerpo.body_entered.connect(_al_chocar)
	_crear_fuego(_radio_cuerpo)


## Contorno irregular y suave: suma de pocas ondas con fases al azar (sin picos ni esquinas duras).
func _forma_irregular(radio: float) -> ConvexPolygonShape2D:
	var f1 := randf() * TAU
	var f2 := randf() * TAU
	var f3 := randf() * TAU
	var puntos := PackedVector2Array()
	var n := 16
	for i in n:
		var a := TAU * float(i) / float(n)
		var r := radio * (1.0 + 0.10 * sin(2.0 * a + f1) + 0.07 * sin(3.0 * a + f2) + 0.04 * sin(5.0 * a + f3))
		puntos.append(Vector2.from_angle(a) * r)
	var forma := ConvexPolygonShape2D.new()
	forma.set_point_cloud(puntos)
	return forma


func _asegurar_suelo() -> void:
	if is_instance_valid(_suelo):
		return
	_suelo = StaticBody2D.new()
	_suelo.position = Vector2(0.0, suelo_y + 20.0)
	var forma := RectangleShape2D.new()
	forma.size = Vector2(200000.0, 40.0)
	var col := CollisionShape2D.new()
	col.shape = forma
	_suelo.add_child(col)
	get_parent().add_child.call_deferred(_suelo)


## 1.0 = impacto brusco, baja hasta 0.35 con la suavidad al máximo.
func _escala_suave() -> float:
	return lerpf(1.0, 0.35, suavidad_impacto)


func _physics_process(_delta: float) -> void:
	if Engine.is_editor_hint() or _cuerpo == null:
		return

	# magnetismo: los que tienen hierro-níquel son atraídos por los "iman"
	var magnetismo: float = _datos.magnetismo
	if magnetismo > 0.0:
		for nodo in get_tree().get_nodes_in_group("iman"):
			var iman := nodo as Node2D
			if iman == null or not is_instance_valid(iman):
				continue
			var dir := iman.global_position - _cuerpo.global_position
			var dist := dir.length()
			if dist > 1.0 and dist < alcance_iman:
				_cuerpo.apply_central_force(dir / dist * magnetismo * fuerza_iman * (1.0 - dist / alcance_iman))

	if _impactado:
		return

	# --- vuelo ---
	var vel := _cuerpo.linear_velocity
	if mantener_angulo:
		# línea recta por el ángulo: se quita lo que la gravedad desvíe y solo queda la parte
		# a lo largo del camino (así acelera por el ángulo, pero nunca cambia de rumbo)
		var rapidez := clampf(vel.dot(_dir_caida), rapidez_inicial, maxf(velocidad_maxima, rapidez_inicial))
		_cuerpo.linear_velocity = _dir_caida * rapidez
	elif vel.length() > velocidad_maxima:
		# caída libre: la atmósfera frena y no deja pasar de la velocidad máxima
		_cuerpo.linear_velocity = vel.move_toward(vel.normalized() * velocidad_maxima, 600.0 * _delta)
	# velocidad antes del choque (en body_entered ya viene alterada por la colisión)
	_vel_previa = _cuerpo.linear_velocity

	# llegó a la línea de explosión (se revisa el tramo entre el paso anterior y el actual)
	if explotar_en_linea_y:
		var y0 := _pos_prev.y
		var y1 := global_position.y
		if y0 <= linea_y and y1 >= linea_y:
			var t := 0.0 if is_equal_approx(y0, y1) else (linea_y - y0) / (y1 - y0)
			_explotar_en_linea(_pos_prev.lerp(global_position, t))
			return
		_pos_prev = global_position

	# corteza de fusión: solo brilla y arde mientras cae rápido; al frenar se oscurece
	var calor_objetivo := clampf(_vel_previa.length() / VEL_ABLACION, 0.0, 1.0)
	_calor = lerpf(_calor, calor_objetivo, 0.1)
	self_modulate = Color.WHITE.lerp(Color(1.6, 0.85, 0.55), _calor * 0.6)
	if _fuego:
		_fuego.emitting = _calor > 0.2
		_fuego.speed_scale = lerpf(0.6, 1.4, _calor)

	# si pasa muy cerca de una planta, caja, etc., la golpea
	for nodo in get_tree().get_nodes_in_group("destruible"):
		if not is_instance_valid(nodo) or not nodo.has_method("radio_golpe"):
			continue
		if global_position.distance_to(nodo.global_position) <= _radio_cuerpo + nodo.radio_golpe():
			_impactar(nodo, true)
			return


func _process(_delta: float) -> void:
	# el fuego sigue al meteorito, no gira con él y la estela queda detrás (contra la velocidad)
	if _fuego:
		_fuego.global_position = global_position
		if _cuerpo != null and _cuerpo.linear_velocity.length() > 1.0:
			_fuego.direction = -_cuerpo.linear_velocity.normalized()


func _crear_fuego(radio: float) -> void:
	_fuego = CPUParticles2D.new()
	_fuego.top_level = true
	_fuego.local_coords = false
	_fuego.amount = _datos.fuego
	_fuego.lifetime = 0.6
	_fuego.direction = -_cuerpo.linear_velocity.normalized()
	_fuego.spread = 25.0
	_fuego.gravity = Vector2.ZERO  # es una estela de ablación, no una llama que sube
	_fuego.initial_velocity_min = 20.0
	_fuego.initial_velocity_max = 60.0
	_fuego.scale_amount_min = _datos.tam_fuego * 0.6
	_fuego.scale_amount_max = _datos.tam_fuego
	_fuego.emission_shape = CPUParticles2D.EMISSION_SHAPE_SPHERE
	_fuego.emission_sphere_radius = radio * 0.7
	_fuego.color_ramp = _gradiente_fuego()
	add_child(_fuego)


func _gradiente_fuego() -> Gradient:
	var g := Gradient.new()
	g.set_color(0, Color(1.0, 0.95, 0.4, 1.0))
	g.set_color(1, Color(0.2, 0.1, 0.1, 0.0))
	g.add_point(0.3, Color(1.0, 0.5, 0.1, 0.9))
	g.add_point(0.7, Color(0.8, 0.15, 0.05, 0.6))
	return g


# ---------------------------------------------------------------- impacto y explosión

func _al_chocar(cuerpo: Node) -> void:
	_impactar(cuerpo, false)


func _impactar(objetivo: Node, golpe_a_objeto: bool) -> void:
	if _impactado:
		return
	_impactado = true

	# la explosión sale entera del impacto: fuerza (masa y velocidad) y ángulo (forma)
	_detonar(objetivo)

	# los rocosos (frágiles) se rompen al chocar con algo; los de hierro-níquel sobreviven intactos
	if golpe_a_objeto and _datos.se_fragmenta:
		_cuerpo.queue_free()
		return

	# aterrizaje suave: se frena poco a poco (más suavidad = frena más pronto), deja de arder y se enfría
	_cuerpo.linear_damp = lerpf(0.5, 3.0, suavidad_impacto)
	_cuerpo.angular_damp = lerpf(2.0, 4.0, suavidad_impacto)
	_enfriar()


## Llegó a la línea de explosión (eje Y): explota justo ahí, con la fuerza y el ángulo con que iba,
## y el meteorito se destruye.
func _explotar_en_linea(punto: Vector2) -> void:
	if _impactado:
		return
	_impactado = true
	_cuerpo.global_position = punto
	_detonar(null)
	_cuerpo.queue_free()


## Fuerza del impacto = energía cinética (½ m v²) respecto a la de referencia, por "fuerza_extra".
## Más masa o más velocidad = explosión más grande.
func _fuerza_impacto() -> float:
	var v := _vel_previa.length()
	var energia := 0.5 * _cuerpo.mass * v * v
	return clampf(energia / ENERGIA_REF * fuerza_extra, FUERZA_MIN, FUERZA_MAX)


## Calcula la explosión completa a partir del impacto y la lanza: partículas, onda, temblor y daño.
func _detonar(objetivo: Node) -> void:
	var fuerza := _fuerza_impacto()

	# forma: seno = 1 (vertical, redonda) ... 0 (muy inclinado, alargada hacia donde iba)
	var seno := 1.0
	var hacia := Vector2.ZERO
	if efectos_por_angulo and _vel_previa.length() > 1.0:
		seno = clampf(absf(_vel_previa.y) / _vel_previa.length(), 0.0, 1.0)
		hacia = Vector2(signf(_vel_previa.x), 0.0)

	_explosion(fuerza, seno, hacia)
	_temblor_camara(fuerza)
	_dano_en_area(objetivo, fuerza, seno, hacia)


## Radio de la zona de daño: crece con el tamaño del meteorito y con la raíz de la fuerza.
func _radio_dano(fuerza: float) -> float:
	return _datos.radio * maxf(global_scale.x, 0.1) / 0.5 * sqrt(fuerza)


## Daño en área. Es una elipse alargada hacia adelante si el impacto fue inclinado, y un círculo si fue vertical.
## Más débil mientras más lejos del centro.
func _dano_en_area(objetivo: Node, fuerza: float, seno: float, hacia: Vector2) -> void:
	var factor := clampf(fuerza, 0.3, 3.0)
	var base := _radio_dano(fuerza)
	var alarg := lerpf(ESTIRAMIENTO_ANGULO, 1.0, seno)
	var r_perp := base / sqrt(alarg)

	# golpe directo a lo que tocó
	if objetivo and objetivo.is_in_group("destruible"):
		_danar(objetivo, factor)

	for nodo in get_tree().get_nodes_in_group("destruible"):
		if nodo == objetivo or not is_instance_valid(nodo):
			continue
		var d: Vector2 = nodo.global_position - global_position
		var along := d.dot(hacia)  # cuánto está hacia adelante (+) o atrás (−) del impacto
		var perp := (d - hacia * along).length()
		var r_along := base * (alarg if along > 0.0 else 1.0)
		var t := sqrt(pow(along / r_along, 2.0) + pow(perp / r_perp, 2.0))
		if t <= 1.0:
			_danar(nodo, factor * (1.0 - t * 0.6))


func _danar(nodo: Node, factor: float) -> void:
	if _datos.destruye_todo and nodo.has_method("destruir"):
		nodo.destruir()
	elif nodo.has_method("recibir_dano"):
		nodo.recibir_dano(_datos.dano * factor)


func _enfriar() -> void:
	if not is_inside_tree():
		return
	if _fuego:
		_fuego.emitting = false
	var tw := create_tween()
	tw.tween_property(self, "self_modulate", Color.WHITE, 4.0)  # el brillo se apaga
	if desaparecer:
		tw.tween_interval(3.0)
		tw.tween_property(self, "modulate:a", 0.0, 1.0)
		tw.tween_callback(_cuerpo.queue_free)


func _explosion(fuerza: float, seno: float, hacia: Vector2) -> void:
	var padre := _cuerpo.get_parent()
	var escala := sqrt(fuerza)
	var arriba := Vector2(0.0, -1.0)

	# hacia dónde sale: vertical = abanico redondo hacia arriba; inclinado = chorro hacia adelante
	var dir_expl := arriba
	if seno < 1.0 and hacia != Vector2.ZERO:
		dir_expl = arriba.lerp(Vector2(hacia.x, -0.35).normalized(), 1.0 - seno).normalized()
	var abanico := lerpf(25.0, 85.0, seno)

	# bola de fuego
	var p := CPUParticles2D.new()
	p.one_shot = true
	p.explosiveness = 1.0
	p.amount = clampi(int(_datos.fuego * 3.0 * fuerza), 30, 400)
	p.lifetime = lerpf(0.9, 1.5, suavidad_impacto)  # más suave = el fuego dura más y se mueve más lento
	p.direction = dir_expl
	p.spread = abanico
	p.gravity = Vector2(0.0, lerpf(300.0, 120.0, suavidad_impacto))
	p.damping_min = 40.0 * suavidad_impacto
	p.damping_max = 80.0 * suavidad_impacto
	p.initial_velocity_min = 100.0 * escala
	p.initial_velocity_max = (160.0 + float(_datos.radio) * 0.9) * escala
	p.scale_amount_min = _datos.tam_fuego * 1.5
	p.scale_amount_max = _datos.tam_fuego * 3.0 * escala
	p.color_ramp = _gradiente_fuego()
	padre.add_child(p)
	p.global_position = global_position
	p.emitting = true
	get_tree().create_timer(3.0).timeout.connect(p.queue_free)

	# escombros oscuros: caen por gravedad, más lejos si la fuerza es grande
	var e := CPUParticles2D.new()
	e.one_shot = true
	e.explosiveness = 1.0
	e.amount = clampi(int(_datos.fuego * fuerza), 15, 200)
	e.lifetime = 1.6
	e.direction = dir_expl
	e.spread = abanico
	e.gravity = Vector2(0.0, 500.0)
	e.initial_velocity_min = 120.0 * escala
	e.initial_velocity_max = (220.0 + float(_datos.radio)) * escala
	e.scale_amount_min = _datos.tam_fuego * 0.6
	e.scale_amount_max = _datos.tam_fuego * 1.6
	e.color = Color(0.25, 0.2, 0.17, 1.0)
	padre.add_child(e)
	e.global_position = global_position
	e.emitting = true
	get_tree().create_timer(3.0).timeout.connect(e.queue_free)

	_onda_expansiva(padre, fuerza, seno, hacia)


## Anillo de choque que se expande: del tamaño del daño y alargado hacia adelante si fue inclinado.
func _onda_expansiva(padre: Node, fuerza: float, seno: float, hacia: Vector2) -> void:
	var radio := _radio_dano(fuerza)
	var alarg := lerpf(ESTIRAMIENTO_ANGULO, 1.0, seno)
	var onda := Polygon2D.new()
	var puntos := PackedVector2Array()
	for i in 32:
		puntos.append(Vector2.from_angle(TAU * float(i) / 32.0) * 20.0)
	onda.polygon = puntos
	onda.color = Color(1.0, 0.85, 0.55, 0.35)
	onda.scale = Vector2.ONE * 0.2
	onda.z_index = 10
	padre.add_child(onda)
	onda.global_position = global_position + hacia * radio * 0.25 * (alarg - 1.0)
	var duracion := lerpf(0.45, 0.9, suavidad_impacto)
	var tw := onda.create_tween().set_parallel(true)
	tw.tween_property(onda, "scale", Vector2(radio * alarg / 20.0, radio / 20.0), duracion) \
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tw.tween_property(onda, "modulate:a", 0.0, duracion)
	tw.chain().tween_callback(onda.queue_free)


func _temblor_camara(fuerza: float) -> void:
	var cam := get_viewport().get_camera_2d()
	if cam == null:
		return
	var fuerza_t: float = _datos.temblor * clampf(sqrt(fuerza), 0.5, 2.0) * _escala_suave()
	var tw := cam.create_tween()
	var pasos := 8
	for i in pasos:
		var k := 1.0 - float(i) / float(pasos)  # el temblor se va apagando poco a poco
		tw.tween_property(cam, "offset",
			Vector2(randf_range(-1.0, 1.0), randf_range(-1.0, 1.0)) * fuerza_t * k, 0.06) \
			.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tw.tween_property(cam, "offset", Vector2.ZERO, 0.08)
