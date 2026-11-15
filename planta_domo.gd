@tool
class_name PlantaDomo
extends Destruible
## Ponlo en el Sprite2D del domo. La planta crece por etapas con un "estirón".
## Se ve en el editor: el tamaño lo cambias con Transform > Scale (o arrastrando
## las esquinas) y la posición moviéndolo, como cualquier Sprite2D.
## Si dejas "etapas" vacío usa res://sprites/planta_1.png ... planta_7.png

signal cosechada

@export var etapas: Array[Texture2D] = []
@export var tiempo_por_etapa := 4.0  # segundos entre etapas
@export var crece_solo := true

var etapa := 0

var _lista: Array[Texture2D] = []
var _escala_base := Vector2.ONE
var _alto_inicial := 0.0
var _timer: Timer
var _tw: Tween


func _ready() -> void:
	super()
	add_to_group("planta")

	if etapas.is_empty():
		for i in range(1, 8):
			_lista.append(load("res://sprites/planta_%d.png" % i))
	else:
		_lista = etapas

	texture = _lista[0]  # así lo ves en el editor
	if Engine.is_editor_hint():
		return

	_escala_base = scale
	_alto_inicial = texture.get_height()

	if crece_solo:
		_timer = Timer.new()
		_timer.wait_time = tiempo_por_etapa
		_timer.timeout.connect(crecer)
		add_child(_timer)
		_timer.start()


func crecer() -> void:
	if _destruido or etapa >= _lista.size() - 1:
		return
	etapa += 1
	texture = _lista[etapa]
	offset.y = (_alto_inicial - texture.get_height()) / 2.0  # la base no se mueve

	if _tw:
		_tw.kill()
	scale = _escala_base * 0.85
	_tw = create_tween()
	_tw.tween_property(self, "scale", _escala_base, 0.5) \
		.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

	if etapa == _lista.size() - 1:
		cosechada.emit()


func destruir() -> void:
	if _timer:
		_timer.stop()
	if _tw:
		_tw.kill()
	super()
