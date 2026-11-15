
extends Control

@onready var barra = $BarraDeCarga

func _ready() -> void:
	barra.value = 0

	# Animar la barra de 0 a 100 durante 5 segundos
	var animacion = create_tween()
	animacion.tween_property(
		barra,
		"value",
		100.0,
		5.0
	)

	# Esperar a que termine la animacion
	await animacion.finished

	print("¡Mision Killa Wasi cargada correctamente!")

	# Cambiar a nuestra base lunar
	get_tree().change_scene_to_file(
        "res://base_lunar.tscn"
	)
