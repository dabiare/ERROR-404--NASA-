extends MinijuegoBase
## Estación de comunicaciones: sintoniza la frecuencia con ← → (o A / D).

const MENSAJE := "Aquí la Tierra. El agua reciclada pasa por 3 filtros. Revisa el segundo."

var frecuencia := 10.0
var objetivo := 0.0
var senal := 0.0
var tiempo_ok := 0.0
var activo := true

var barra: ProgressBar
var lbl_freq: Label
var lbl_msg: Label


func _configurar() -> void:
	titulo = "Estación de comunicaciones"
	instrucciones = "Gira la antena con ← → (o A / D) hasta tener la señal al máximo. Mantenla un momento."
	pista_final = "Mensaje recibido."
	tam_contenido = Vector2(520, 150)


func _iniciar() -> void:
	objetivo = randf_range(40.0, 90.0)
	frecuencia = randf_range(0.0, 25.0)

	var caja := VBoxContainer.new()
	caja.add_theme_constant_override("separation", 10)
	caja.custom_minimum_size = Vector2(480, 0)
	contenido.add_child(caja)

	lbl_freq = Label.new()
	lbl_freq.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	caja.add_child(lbl_freq)

	barra = ProgressBar.new()
	barra.min_value = 0
	barra.max_value = 100
	barra.custom_minimum_size = Vector2(480, 28)
	caja.add_child(barra)

	lbl_msg = Label.new()
	lbl_msg.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	lbl_msg.custom_minimum_size = Vector2(480, 60)
	lbl_msg.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	caja.add_child(lbl_msg)


func _process(delta: float) -> void:
	if not activo:
		return
	var giro := 0.0
	if Input.is_key_pressed(KEY_LEFT) or Input.is_key_pressed(KEY_A):
		giro -= 1.0
	if Input.is_key_pressed(KEY_RIGHT) or Input.is_key_pressed(KEY_D):
		giro += 1.0

	frecuencia = clampf(frecuencia + giro * 25.0 * delta, 0.0, 100.0)
	senal = clampf(1.0 - absf(frecuencia - objetivo) / 40.0, 0.0, 1.0)
	barra.value = senal * 100.0
	lbl_freq.text = "Frecuencia: %.1f MHz" % frecuencia
	lbl_msg.text = _texto_con_ruido()

	if senal > 0.9:
		tiempo_ok += delta
		if tiempo_ok >= 1.5:
			activo = false
			lbl_msg.text = MENSAJE
			_ganar()
	else:
		tiempo_ok = 0.0


func _texto_con_ruido() -> String:
	var simbolos := "#%&@*?"
	var res := ""
	for i in MENSAJE.length():
		var ch := MENSAJE[i]
		if ch == " " or float((i * 37) % 100) / 100.0 < senal:
			res += ch
		else:
			res += simbolos[randi() % simbolos.length()]
	return res
