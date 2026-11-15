class_name Interactuable
extends Area2D
## Ponlo en cada objeto (dosímetro, consola, antena, mesa).
## Necesita un CollisionShape2D hijo. El jugador debe estar en el grupo "jugador".

signal completado(id_objeto: String, recompensa: String)

@export var id_objeto := ""
@export_file("*.gd") var script_minijuego := ""
@export_enum("muestra", "registro", "ninguna") var recompensa := "registro"
@export var texto_aviso := "E · Interactuar"
@export var aviso_offset := Vector2(-40, -70)

var jugador_cerca := false
var completo := false
var _abierto := false
var aviso: Label


func _ready() -> void:
	body_entered.connect(_al_entrar)
	body_exited.connect(_al_salir)
	aviso = Label.new()
	aviso.text = texto_aviso
	aviso.position = aviso_offset
	aviso.z_index = 100
	aviso.visible = false
	add_child(aviso)


func _al_entrar(cuerpo: Node) -> void:
	if cuerpo.is_in_group("jugador"):
		jugador_cerca = true
		aviso.visible = not completo and not _abierto


func _al_salir(cuerpo: Node) -> void:
	if cuerpo.is_in_group("jugador"):
		jugador_cerca = false
		aviso.visible = false


func _unhandled_input(event: InputEvent) -> void:
	if not jugador_cerca or completo or _abierto:
		return
	if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_E:
		get_viewport().set_input_as_handled()
		_abrir()


func _abrir() -> void:
	var script: Script = load(script_minijuego)
	var mj: MinijuegoBase = script.new()
	_abierto = true
	aviso.visible = false
	mj.terminado.connect(_al_terminar)
	get_tree().current_scene.add_child(mj)


func _al_terminar(exito: bool) -> void:
	_abierto = false
	if exito:
		completo = true
		aviso.text = "✔ Hecho"
		aviso.visible = jugador_cerca
		completado.emit(id_objeto, recompensa)
	else:
		aviso.visible = jugador_cerca
