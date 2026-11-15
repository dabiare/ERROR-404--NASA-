@tool
class_name CajaHerramientas
extends Destruible
## Ponlo en el Sprite2D de la caja. Solo hace un leve balanceo, sin moverse de lugar.
## Si algún día quieres que además se desplace, sube "recorrido".

@export var inclinacion := 3.0   # grados hacia cada lado (más bajo = más leve)
@export var duracion := 1.3      # segundos por tramo (más alto = más lento)
@export var recorrido := 0.0     # píxeles de desplazamiento lateral (0 = no se mueve)

var _tw: Tween


func _ready() -> void:
	super()
	if Engine.is_editor_hint():
		return  # en el editor se queda quieta para no mover tu escena

	var x0 := position.x
	var r0 := rotation_degrees
	_tw = create_tween().set_loops() \
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	_tw.tween_property(self, "rotation_degrees", r0 + inclinacion, duracion)
	_tw.parallel().tween_property(self, "position:x", x0 + recorrido, duracion)
	_tw.tween_property(self, "rotation_degrees", r0 - inclinacion, duracion * 2.0)
	_tw.parallel().tween_property(self, "position:x", x0 - recorrido, duracion * 2.0)
	_tw.tween_property(self, "rotation_degrees", r0, duracion)
	_tw.parallel().tween_property(self, "position:x", x0, duracion)


func destruir() -> void:
	if _tw:
		_tw.kill()
	super()
