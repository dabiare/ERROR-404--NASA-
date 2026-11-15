
extends Area2D

# Referencias al panel y al mensaje
@onready var panel = $"../Panel"
@onready var mensaje = $"../MensajeEntrada"

# Detectar si la comandante está cerca
var comandante_cerca: bool = false


func _ready() -> void:
	# Ocultar el mensaje al iniciar
	panel.hide()
	mensaje.hide()

	# Conectar las señales si aún no están conectadas
	if not body_entered.is_connected(_on_body_entered):
		body_entered.connect(_on_body_entered)

	if not body_exited.is_connected(_on_body_exited):
		body_exited.connect(_on_body_exited)


# Cuando la astronauta se acerca a la puerta
func _on_body_entered(body: Node2D) -> void:
	if body.name == "Comandante":
		comandante_cerca = true

		panel.show()
		mensaje.show()

		print("Comandante cerca de la entrada")


# Cuando la astronauta se aleja
func _on_body_exited(body: Node2D) -> void:
	if body.name == "Comandante":
		comandante_cerca = false

		panel.hide()
		mensaje.hide()

		print("Comandante se alejó de la entrada")
