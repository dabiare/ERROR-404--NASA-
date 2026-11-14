extends RefCounted
const CREW = {
	"commander": {"name": "COMANDANTE", "tag": "Coordinación de la misión", "color": Color("f5c65b"), "index": 0},
	"engineer": {"name": "INGENIERO JEFE", "tag": "Energía y soporte vital", "color": Color("f59a58"), "index": 1},
	"botanist": {"name": "BIÓLOGA BOTÁNICA", "tag": "Cultivos y ciencias de la vida", "color": Color("83d9a2"), "index": 2},
	"doctor": {"name": "MÉDICO DE VUELO", "tag": "Salud y bienestar", "color": Color("6dd5e9"), "index": 3},
	"geologist": {"name": "GEÓLOGO LUNAR", "tag": "Exploración y muestras", "color": Color("ceaa84"), "index": 4},
	"control": {"name": "CONTROL DE MISIÓN", "tag": "Enlace Tierra · Luna", "color": Color("70d7d5"), "index": -1}
}
const ARRIVAL = [
	["control", "Control de Misión a Killa Wasi: alunizaje confirmado. Durante 30 días comprobarán cómo vivir y trabajar en esta base lunar."],
	["control", "Cuiden a la tripulación, mantengan los sistemas y recojan información para futuras expediciones. Su regreso está previsto al terminar la misión."],
	["commander", "Recibido, Control de Misión. Primero entraré en la base y comprobaré cómo está el equipo."],
	["control", "Sigue las marcas doradas hasta la esclusa iluminada en azul. Acércate a la puerta y pulsa E para entrar."]
]
const RADIO = [
	["commander", "Aquí la comandante de Killa Wasi. Equipo, hagamos nuestra primera comprobación por radio."],
	["engineer", "Ingeniero jefe al habla: la energía y el soporte vital funcionan. Me encargo de que el aire, el agua y los equipos sigan listos."],
	["engineer", "Encontré dos estantes sin revisar en el almacén. Ordenarlos nos ayudará a saber qué repuestos tenemos."],
	["commander", "Gracias, ingeniero. Tener reservas localizadas puede ayudarnos más adelante."],
	["botanist", "¡Saludos desde el invernadero! Soy la bióloga botánica y estudiaré cómo crecen las plantas aquí."],
	["botanist", "Nuestro pequeño cultivo es un experimento. Durante la misión comeremos principalmente las provisiones que trajimos."],
	["commander", "Cuidaremos las plantas y registraremos lo que aprendamos. También tendremos que decidir cuánta energía dedicarles."],
	["doctor", "Soy el médico de vuelo: los cinco estamos bien. Me ocuparé de la salud, el descanso y el ejercicio del equipo."],
	["doctor", "Descansar también es parte de la misión. Una tripulación cansada puede cometer más errores."],
	["commander", "Lo tendré en cuenta al organizar las tareas. Necesitamos cuidarnos para trabajar juntos."],
	["geologist", "Geólogo lunar al habla: el laboratorio está preparado. Estudiaré rocas y mediciones para entender este lugar."],
	["geologist", "Dejé una muestra de calibración junto a la consola. Podemos usarla para comprobar los instrumentos antes de las salidas."],
	["commander", "Somos cinco especialistas y un solo equipo. Escucharé sus consejos y coordinaré nuestras prioridades."],
	["control", "Buen comienzo, Killa Wasi. Antes del informe inicial tienen tiempo para una preparación: revisar el almacén o activar el laboratorio."],
	["commander", "Consultaré las dos opciones en este terminal. Los sistemas esenciales seguirán funcionando con cualquiera de ellas."]
]
const GREETINGS = {
	"engineer": "El oxígeno y la eliminación de CO₂ son tareas diferentes. Revisar cada sistema nos ayuda a encontrar el origen de una avería.",
	"botanist": "Cada planta tiene su registro de luz y agua. ¡Un resultado inesperado también puede enseñarnos algo!",
	"doctor": "Nuestro horario incluye ejercicio, comidas y descanso. Cuidar al equipo nos permite cuidar la misión.",
	"geologist": "Una muestra bien documentada cuenta una historia. Anotaremos dónde la encontramos y qué medimos."
}

static func portrait(id: String, full_body := false) -> AtlasTexture:
	if not ResourceLoader.exists("res://assets/art/crew.png") or id == "control": return null
	var atlas := AtlasTexture.new()
	atlas.atlas = load("res://assets/art/crew.png")
	var s := atlas.atlas.get_size()
	var index: int = CREW[id].index
	atlas.region = Rect2(index * s.x / 5.0, 0 if full_body else s.y / 2.0, s.x / 5.0, s.y / 2.0)
	return atlas
