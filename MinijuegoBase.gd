extends MinijuegoBase
## Consola principal: repite la secuencia de luces (tipo Simon).

const COLORES := [Color("e74c3c"), Color("2ecc71"), Color("3498db"), Color("f1c40f")]
const NOMBRES := ["Rojo", "Verde", "Azul", "Amarillo"]
const RONDAS := 4

var botones: Array[Button] = []
var secuencia: Array[int] = []
var indice := 0
var ronda := 1
var aceptando := false


func _configurar() -> void:
	titulo = "Consola principal de mando"
	instrucciones = "Mira la secuencia de luces y repítela para reiniciar los sistemas."
	pista_final = "Sistemas reiniciados. El registro dice que la bomba de agua se apagó sola a las 03:12."
	tam_contenido = Vector2(520, 110)


func _iniciar() -> void:
	var fila := HBoxContainer.new()
	fila.add_theme_constant_override("separation", 14)
	contenido.add_child(fila)
	for i in 4:
		var b := Button.new()
		b.text = NOMBRES[i]
		b.custom_minimum_size = Vector2(115, 90)
		b.focus_mode = Control.FOCUS_NONE
		b.modulate = COLORES[i].darkened(0.45)
		b.pressed.connect(_al_pulsar.bind(i))
		fila.add_child(b)
		botones.append(b)
	secuencia.append(randi() % 4)
	_mostrar_secuencia()


func _encender(i: int, encendido: bool) -> void:
	if encendido:
		botones[i].modulate = COLORES[i].lightened(0.35)
	else:
		botones[i].modulate = COLORES[i].darkened(0.45)


func _mostrar_secuencia() -> void:
	aceptando = false
	indice = 0
	mensaje("Mira la secuencia... (ronda %d de %d)" % [ronda, RONDAS])
	await get_tree().create_timer(0.7).timeout
	for i in secuencia:
		if _cerrado:
			return
		_encender(i, true)
		await get_tree().create_timer(0.5).timeout
		if _cerrado:
			return
		_encender(i, false)
		await get_tree().create_timer(0.2).timeout
	indice = 0
	aceptando = true
	mensaje("¡Tu turno!")


func _al_pulsar(i: int) -> void:
	if not aceptando:
		return
	var correcto := (i == secuencia[indice])
	var termino_ronda := false
	if correcto:
		indice += 1
		if indice >= secuencia.size():
			termino_ronda = true
			aceptando = false
	else:
		aceptando = false

	_encender(i, true)
	await get_tree().create_timer(0.18).timeout
	if _cerrado:
		return
	_encender(i, false)

	if not correcto:
		mensaje("¡Ups! Mira otra vez.")
		await get_tree().create_timer(1.0).timeout
		_mostrar_secuencia()
	elif termino_ronda:
		if ronda >= RONDAS:
			_ganar()
		else:
			ronda += 1
			secuencia.append(randi() % 4)
			mensaje("¡Muy bien!")
			await get_tree().create_timer(0.8).timeout
			_mostrar_secuencia()
