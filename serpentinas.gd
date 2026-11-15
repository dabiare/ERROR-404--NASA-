class_name Serpentinas
extends CanvasLayer
## Serpentinas y confeti de colores.
## Uso desde cualquier script del juego:
##     Serpentinas.lanzar(self)
## Opciones:  Serpentinas.lanzar(self, 1.5)         # más cantidad
##            Serpentinas.lanzar(self, 1.0, false)  # sin sonido

const COLORES := [
	Color("f4f6ff"), Color("3b82ff"), Color("7cc4ff"), Color("8b5cf6"),
	Color("c7b0ff"), Color("ffd84d"), Color("ff5c9d"), Color("5cffb0"),
]

var _intensidad := 1.0
var _con_sonido := true
var _tex_cuadrito: ImageTexture
var _tex_serpentina: ImageTexture


static func lanzar(escena: Node, intensidad: float = 1.0, con_sonido: bool = true) -> void:
	var arbol := escena.get_tree()
	var padre: Node = arbol.current_scene if arbol.current_scene != null else arbol.root
	var s := Serpentinas.new()
	s._intensidad = intensidad
	s._con_sonido = con_sonido
	padre.add_child(s)


func _ready() -> void:
	layer = 300
	process_mode = Node.PROCESS_MODE_ALWAYS   # funciona aunque el juego esté en pausa
	_crear_texturas()
	_canones(1.0)
	_lluvia()
	if _con_sonido:
		_jingle()
	# Segunda tanda de cañones, para que se sienta más dinámico
	await get_tree().create_timer(0.55, true).timeout
	_canones(0.6)
	await get_tree().create_timer(6.0, true).timeout
	queue_free()


func _crear_texturas() -> void:
	var img := Image.create(8, 8, false, Image.FORMAT_RGBA8)
	img.fill(Color.WHITE)
	_tex_cuadrito = ImageTexture.create_from_image(img)
	var img2 := Image.create(4, 22, false, Image.FORMAT_RGBA8)
	img2.fill(Color.WHITE)
	_tex_serpentina = ImageTexture.create_from_image(img2)


func _paleta() -> Gradient:
	var offs := PackedFloat32Array()
	var cols := PackedColorArray()
	for i in COLORES.size():
		offs.append(float(i) / float(COLORES.size() - 1))
		cols.append(COLORES[i])
	var g := Gradient.new()
	g.offsets = offs
	g.colors = cols
	g.interpolation_mode = Gradient.GRADIENT_INTERPOLATE_CONSTANT   # colores sólidos
	return g


func _emisor(pos: Vector2, dir: Vector2, tex: Texture2D, cantidad: int, vmin: float, vmax: float, abre: float, explosivo: float, vida: float, gravedad: float, rect: Vector2 = Vector2.ZERO) -> void:
	var p := CPUParticles2D.new()
	p.texture = tex
	p.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST   # look pixel
	p.position = pos
	p.amount = maxi(4, int(float(cantidad) * _intensidad))
	p.lifetime = vida
	p.one_shot = true
	p.explosiveness = explosivo
	p.direction = dir
	p.spread = abre
	p.initial_velocity_min = vmin
	p.initial_velocity_max = vmax
	p.gravity = Vector2(0, gravedad)
	p.angular_velocity_min = -540.0
	p.angular_velocity_max = 540.0
	p.scale_amount_min = 0.8
	p.scale_amount_max = 1.5
	p.color_initial_ramp = _paleta()
	if rect != Vector2.ZERO:
		p.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
		p.emission_rect_extents = rect
	add_child(p)
	p.emitting = true


func _canones(fuerza: float) -> void:
	var tam := get_viewport().get_visible_rect().size
	var n := int(70.0 * fuerza)
	# Serpentinas largas y confeti, disparados desde las dos esquinas de abajo
	_emisor(Vector2(0, tam.y), Vector2(0.5, -1), _tex_serpentina, n, 600, 1100, 22, 0.95, 3.6, 900)
	_emisor(Vector2(tam.x, tam.y), Vector2(-0.5, -1), _tex_serpentina, n, 600, 1100, 22, 0.95, 3.6, 900)
	_emisor(Vector2(0, tam.y), Vector2(0.6, -1), _tex_cuadrito, n, 500, 1000, 25, 0.95, 3.4, 900)
	_emisor(Vector2(tam.x, tam.y), Vector2(-0.6, -1), _tex_cuadrito, n, 500, 1000, 25, 0.95, 3.4, 900)


func _lluvia() -> void:
	var tam := get_viewport().get_visible_rect().size
	var extents := Vector2(tam.x / 2.0, 10)
	_emisor(Vector2(tam.x / 2.0, -20), Vector2(0, 1), _tex_cuadrito, 90, 60, 160, 25, 0.0, 5.0, 260, extents)
	_emisor(Vector2(tam.x / 2.0, -20), Vector2(0, 1), _tex_serpentina, 40, 60, 160, 25, 0.0, 5.0, 220, extents)


# Sonidito de victoria generado por código (no necesita archivos de audio)
func _jingle() -> void:
	var rate := 22050
	var datos := PackedByteArray()
	for f in [523.0, 659.0, 784.0, 1047.0, 784.0, 1047.0]:
		var n := int(float(rate) * 0.1)
		for i in n:
			var t := float(i) / float(rate)
			var onda := 1.0 if fmod(t * f, 1.0) < 0.5 else -1.0
			var env := 1.0 - float(i) / float(n)
			var s := int(onda * env * 0.25 * 32767.0)
			datos.append(s & 0xFF)
			datos.append((s >> 8) & 0xFF)
	var w := AudioStreamWAV.new()
	w.format = AudioStreamWAV.FORMAT_16_BITS
	w.mix_rate = rate
	w.stereo = false
	w.data = datos
	var p := AudioStreamPlayer.new()
	p.stream = w
	p.volume_db = -6.0
	add_child(p)
	p.finished.connect(p.queue_free)
	p.play()
