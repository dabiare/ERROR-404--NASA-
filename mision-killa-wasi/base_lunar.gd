
extends Node2D

@onready var mensaje = $MensajeEntrada

func _ready() -> void:
	mensaje.hide()


func _on_entrada_base_body_entered(body: Node2D) -> void:
	if body.name == "Comandante":
		mensaje.show()


func _on_entrada_base_body_exited(body: Node2D) -> void:
	if body.name == "Comandante":
		mensaje.hide()
