extends MinijuegoBase
## Mesa de planificación: gira las tuberías (clic izquierdo) para que
## el agua llegue del tanque (arriba a la izquierda) a los módulos (derecha, fila del medio).

const COLS := 4
const FILAS := 3
const LADO := 84
# 0 = recta, 1 = codo (filas de arriba hacia abajo)
const TIPOS := [
	0, 1, 0, 1,
	1, 1, 0, 0,
	0, 1, 0, 1,
]
const DIRS := [Vector2i(0, -1), Vector2i(1, 0), Vector2i(0, 1), Vector2i(-1, 0)]

var casillas: Array[Casilla] = []


class Casilla extends Control:
	signal girada
	# Lados abiertos en orden: arriba, derecha, abajo, izquierda
	const CODO := [
		[true, true, false, false],
		[false, true, true, false],
		[false, false, true, true],
		[true, false, false, true],
	]
	var tipo := 0
	var rot := 0
	var con_agua := false

	func abiertos() -> Array:
		if tipo == 0:
			if rot % 2 == 0:
				return [false, true, false, true]
			return [true, false, true, false]
		return CODO[rot]

	func _draw() -> void:
		draw_rect(Rect2(Vector2.ZERO, size), Color("1b2733"))
		draw_rect(Rect2(Vector2.ZERO, size), Color("34495e"), false, 2.0)
		var centro := size / 2.0
		var color := Color("3fa7ff") if con_agua else Color("8a949e")
		var ab := abiertos()
		var dirs := [Vector2(0, -1), Vector2(1, 0), Vector2(0, 1), Vector2(-1, 0)]
		for d in 4:
			if ab[d]:
				draw_line(centro, centro + dirs[d] * (size / 2.0), color, 14.0)
		draw_circle(centro, 9.0, color)

	func _gui_input(event: InputEvent) -> void:
		if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			rot = (rot + 1) % 4
			queue_redraw()
			girada.emit()


func _configurar() -> void:
	titulo = "Mesa de planificación"
	instrucciones = "Haz clic en las tuberías para girarlas. El agua entra por arriba a la izquierda y debe salir por la derecha, en la fila del medio."
	pista_final = "El holograma muestra una fuga en la tubería del módulo de Ingeniería."
	tam_contenido = Vector2(520, 260)


func _iniciar() -> void:
	var rejilla := GridContainer.new()
	rejilla.columns = COLS
	rejilla.add_theme_constant_override("h_separation", 4)
	rejilla.add_theme_constant_override("v_separation", 4)
	contenido.add_child(rejilla)

	for i in COLS * FILAS:
		var c := Casilla.new()
		c.tipo = TIPOS[i]
		c.custom_minimum_size = Vector2(LADO, LADO)
		c.girada.connect(_refrescar)
		rejilla.add_child(c)
		casillas.append(c)

	# Mezcla hasta que no empiece resuelto
	while true:
		for c in casillas:
			c.rot = randi() % 4
		if not _calcular():
			break
	_refrescar()
	mensaje("Gira las tuberías hasta que el agua llegue a los módulos.")


func _casilla(p: Vector2i) -> Casilla:
	return casillas[p.y * COLS + p.x]


func _abiertos(p: Vector2i) -> Array:
	return _casilla(p).abiertos()


# Calcula por dónde pasa el agua. Devuelve true si llega a la salida.
func _calcular() -> bool:
	for c in casillas:
		c.con_agua = false

	var pendientes: Array[Vector2i] = []
	var entrada := Vector2i(0, 0)
	if _abiertos(entrada)[3]:
		_casilla(entrada).con_agua = true
		pendientes.append(entrada)

	while pendientes.size() > 0:
		var p: Vector2i = pendientes.pop_back()
		var ab := _abiertos(p)
		for d in 4:
			if not ab[d]:
				continue
			var q: Vector2i = p + DIRS[d]
			if q.x < 0 or q.x >= COLS or q.y < 0 or q.y >= FILAS:
				continue
			var vecina := _casilla(q)
			if vecina.con_agua:
				continue
			if _abiertos(q)[(d + 2) % 4]:
				vecina.con_agua = true
				pendientes.append(q)

	var salida := Vector2i(COLS - 1, 1)
	return _casilla(salida).con_agua and _abiertos(salida)[1]


func _refrescar() -> void:
	var resuelto := _calcular()
	for c in casillas:
		c.queue_redraw()
	if resuelto:
		_ganar()
