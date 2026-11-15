extends MinijuegoBase
## Dosímetro: pulsa ESPACIO cuando la aguja pase por la zona verde.

const ANCHO := 480.0
const ALTO := 50.0
const ANCHO_ZONA := 90.0
const ACIERTOS_META := 3

var zona: ColorRect
var aguja: ColorRect
var pos := 0.0
var dir := 1.0
var velocidad := 260.0
var aciertos := 0
var activo := true


func _configurar() -> void:
	titulo = "Dosímetro de radiación"
	instrucciones = "Pulsa ESPACIO cuando la aguja esté en la zona verde. Necesitas 3 aciertos."
	pista_final = "Radiación normal en la bomba de agua. El problema no es el sensor."
	tam_contenido = Vector2(520, 80)


func _iniciar() -> void:
	var barra := Control.new()
	barra.custom_minimum_size = Vector2(ANCHO, ALTO)
	contenido.add_child(barra)

	var fondo := ColorRect.new()
	fondo.color = Color("2c3e50")
	barra.add_child(fondo)
	fondo.size = Vector2(ANCHO, ALTO)

	zona = ColorRect.new()
	zona.color = Color("2ecc71")
	barra.add_child(zona)
	zona.size = Vector2(ANCHO_ZONA, ALTO)

	aguja = ColorRect.new()
	aguja.color = Color.WHITE
	barra.add_child(aguja)
	aguja.size = Vector2(6, ALTO)

	_mover_zona()
	mensaje("Aciertos: 0 / %d" % ACIERTOS_META)


func _mover_zona() -> void:
	zona.position.x = randf_range(20.0, ANCHO - ANCHO_ZONA - 20.0)


func _process(delta: float) -> void:
	if not activo:
		return
	pos += dir * velocidad * delta
	if pos >= ANCHO - 6.0:
		pos = ANCHO - 6.0
		dir = -1.0
	elif pos <= 0.0:
		pos = 0.0
		dir = 1.0
	aguja.position.x = pos


func _unhandled_input(event: InputEvent) -> void:
	if not activo:
		return
	if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_SPACE:
		get_viewport().set_input_as_handled()
		var centro := pos + 3.0
		if centro >= zona.position.x and centro <= zona.position.x + ANCHO_ZONA:
			aciertos += 1
			velocidad += 60.0
			mensaje("¡Bien! Aciertos: %d / %d" % [aciertos, ACIERTOS_META])
			_mover_zona()
			if aciertos >= ACIERTOS_META:
				activo = false
				_ganar()
		else:
			mensaje("¡Casi! Inténtalo otra vez.")
