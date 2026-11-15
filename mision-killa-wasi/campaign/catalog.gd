extends RefCounted
const ART := "res://campaign/art/"
const ROOMS := {
 "corridor":"Pasillos de Killa Wasi", "airlock":"Esclusa", "command":"Centro de mando",
 "engineering":"Ingeniería", "medical":"Bahía médica", "crops":"Sala de cultivos",
 "minerals":"Laboratorio de minerales", "shelter":"Refugio y sala común",
 "bedroom":"Cuarto de descanso", "hygiene":"Higiene", "gym":"Cuarto de ejercicio", "exterior":"Superficie lunar"
}
const COLORS := {"commander":"f6ca68","engineer":"ff9b60","botanist":"8bd49b","doctor":"79cfef","geologist":"d9ae80","robot":"66e5ef","control":"b1bacf"}
const NAMES := {"commander":"Comandante","engineer":"Ingeniero jefe","botanist":"Bióloga botánica","doctor":"Médico de vuelo","geologist":"Geólogo lunar","robot":"Robot guía","control":"Control de Misión"}
const PEOPLE := {
 "commander":"res://Astronauta Comandante Sonriente.png",
 "engineer":ART+"Astronauta ingeniero con llave y tableta.png",
 "botanist":ART+"Aventurera espacial con terrario verde.png",
 "doctor":ART+"Astronauta médico con botiquín.png",
 "geologist":ART+"Astronauta geólogo explorando la luna.png",
 "robot":ART+"Robot sonriente azul con luna y estrellas.png"
}
const HOME := {"engineer":"engineering","botanist":"crops","doctor":"medical","geologist":"minerals"}
const WORK := {"engineer":"Revisando conexiones","botanist":"Midiendo brotes","doctor":"Revisando registros","geologist":"Clasificando rocas"}
const FACTS := {
 "lock":"El cuerpo y el traje necesitan prepararse para un cambio de presión. Un protocolo de respiración con oxígeno ayuda a reducir el nitrógeno del cuerpo y el riesgo de descompresión.",
 "dust":"El polvo lunar tiene bordes que desgastan los materiales. Limpiarlo y contenerlo protege tanto las juntas de los equipos como el aire que respiramos.",
 "suits":"En la superficie lunar hay gravedad: aproximadamente una sexta parte de la terrestre. El traje también debe permitir trabajar y moverse mientras mantiene un ambiente adecuado.",
 "atmosphere":"El ventilador mueve el aire, pero por sí solo no elimina el CO₂. El sistema de tratamiento del aire se encarga de retirarlo y controlar otros contaminantes.",
 "water":"El tratamiento del agua combina varias etapas; cambiar un cartucho no sustituye todas las comprobaciones. Un sensor y los análisis permiten evaluar si puede volver al suministro.",
 "energy":"Los paneles solares transforman luz en electricidad. Las baterías almacenan parte de esa energía para usarla cuando haga falta.",
 "filter":"Un filtro tiene un trabajo específico y una capacidad limitada. Por eso comprobamos su etiqueta y sus lecturas en vez de elegir solo por su forma.",
 "fire":"Un incendio puede producir gases peligrosos además de calor. Detectarlo pronto y contar con medios adecuados de respuesta ayuda a proteger un hábitat cerrado.",
 "dose":"El dosímetro registra exposición a radiación. La protección depende también del blindaje, los avisos y el lugar donde esté cada persona.",
 "shield":"Algunos materiales, incluido el agua colocada alrededor de una zona protegida, pueden ayudar a reducir la exposición. El refugio de Killa Wasi es una representación educativa, no un diseño certificado.",
 "command":"Coordinar implica comparar necesidades, recursos y tiempo. La comandante escucha a los especialistas antes de decidir una prioridad.",
 "radio":"Las ondas de radio llevan información a través del vacío. En nuestro juego los mensajes llegan enseguida para que sea más fácil conversar.",
 "map":"Una ruta registrada ayuda al equipo a saber dónde buscar a sus compañeros. El holograma es una forma imaginada de presentar datos y no un equipo obligatorio de todas las misiones.",
 "arm":"Un brazo robótico puede manipular equipos y apoyar el mantenimiento. Sus límites y la zona de trabajo deben conocerse antes de moverlo.",
 "spares":"Un inventario relaciona cada pieza con el equipo que la necesita. Registrar lo que usamos ayuda a planificar las reparaciones siguientes.",
 "food":"La alimentación debe aportar energía y nutrientes, además de resultar agradable. Preferencias, conservación y seguridad de los alimentos forman parte de la planificación.",
 "grow":"Las plantas necesitan luz, agua, nutrientes y un ambiente adecuado. Nuestros cultivos investigan cómo producir alimentos; las provisiones traídas siguen sosteniendo la misión.",
 "irrigation":"Las raíces necesitan agua y también acceso al oxígeno. Medir la humedad ayuda a evitar que reciban muy poca o demasiada agua.",
 "bed_med":"El examen médico combina lo que cuenta una persona con lo que observa el especialista. Una pantalla nunca reemplaza por sí sola esa evaluación.",
 "vitals":"Un sensor puede medir el pulso o estimar la saturación de oxígeno de la sangre. El médico comprueba que la lectura tenga sentido y la interpreta con otros datos.",
 "kit":"Los materiales de atención médica se organizan y revisan antes de una misión. Elegir un medicamento y su uso corresponde al personal médico.",
 "samples":"Una roca conserva información sobre cómo se formó y cambió la Luna. Su procedencia y las condiciones de recogida ayudan a interpretar lo que descubrimos.",
 "analyzer":"Una referencia conocida permite comprobar la respuesta de un instrumento. Es una manera de detectar errores antes de interpretar una muestra desconocida.",
 "sleep":"La luz, el ruido y los horarios influyen en el sueño. Cuidar el descanso ayuda al bienestar y al trabajo atento de toda la tripulación.",
 "exercise":"La resistencia de una máquina puede ejercitar músculos aunque el peso sea menor. La duración y la intensidad reales dependen del plan individual del equipo médico.",
 "hygiene":"Separar y contener los residuos evita contaminar el hábitat. Los procesos de recuperación de agua necesitan controles: no todo residuo se vuelve agua potable directamente."
}
const CHATS := {
 "engineer":["Si una máquina hace un ruido nuevo, ¡está pidiendo que la escuchemos! Hoy estoy revisando sus conexiones.","Mi superpoder es encontrar el tornillo que falta. Mi otro superpoder es apuntar dónde lo guardé.","El filtro de aire y el cartucho de agua tienen trabajos distintos. Las etiquetas evitan sorpresas."],
 "botanist":["Estoy buscando un brote nuevo. ¿Crees que tendrá una hoja o dos?", "Mis plantas no hablan, pero sus hojas me dan pistas. Registramos los cambios, incluso cuando no salen como esperábamos.","Este huerto es un experimento. Nuestra despensa sigue siendo la principal fuente de comida."],
 "doctor":["¿Cómo se siente hoy la tripulación? Preguntar y escuchar también son herramientas de trabajo.","Descansar no es perder tiempo: es recargar al equipo. Hasta una comandante necesita una pausa.","El monitor nos da pistas, pero no decide por nosotros. Primero escuchamos cómo se siente la persona."],
 "geologist":["¡Una roca es una historia sin palabras! La etiqueta nos ayuda a recordar dónde empezó.","No todas las piedras brillantes son cristales valiosos. Mi lupa y yo preferimos investigar antes de adivinar.","Hoy comparo muestras: tamaño, textura y lugar de origen. Las diferencias son nuestras pistas."]
}
const SOURCES := {
 "air":"https://www.nasa.gov/reference/environmental-control-and-life-support-systems-eclss/",
 "dust":"https://www.nasa.gov/wp-content/uploads/2023/12/ochmo-tb-011-lunar-dust-technical-brief.pdf",
 "suit":"https://www.nasa.gov/reference/risk-of-decompression-sickness/",
 "power":"https://www.nasa.gov/lunar-surface-technology/",
 "safety":"https://www.nasa.gov/reference/9-0-hardware-and-equipment-vol-2/",
 "radiation":"https://science.nasa.gov/science-research/heliophysics/how-nasa-will-protect-astronauts-from-space-radiation-at-the-moon/",
 "mission":"https://www.nasa.gov/reference/jsc-spaceflight-operations/",
 "radio":"https://www.nasa.gov/communicating-with-missions/",
 "robotics":"https://www.nasa.gov/international-space-station/mobile-servicing-system/",
 "food":"https://www.nasa.gov/reference/7-0-habit-ability-functions-vol-2/",
 "plants":"https://www.asc-csa.gc.ca/eng/youth-educators/toolkits/food-production/",
 "health":"https://www.nasa.gov/reference/crew-systems/",
 "rocks":"https://science.nasa.gov/science-research/planetary-science/astrobiology/nasas-apollo-samples-yield-new-information-about-the-moon/",
 "sleep":"https://www.nasa.gov/reference/fundamentals-of-human-health/",
 "exercise":"https://www.nasa.gov/missions/station/iss-research/astronaut-exercise/"
}

# atlas: original props 0..11; new equipment 12..27; item PNGs use 100+.
static func items() -> Array:
 return [
  item("lock","airlock","Control de la esclusa","La esclusa cuida el aire de la base. Igualamos la presión antes de abrir una puerta; las dos nunca se abren a la vez.","suit",103),
  item("dust","airlock","Limpieza de polvo lunar","El polvo lunar puede rayar los equipos e irritar los ojos y pulmones. Aquí lo retiramos del traje antes de entrar al área limpia.","dust",105),
  item("suits","airlock","Soporte para trajes","Cada traje es una pequeña nave: mantiene presión, oxígeno y temperatura. Revisamos sus uniones antes de salir.","suit",16),
  item("atmosphere","engineering","Consola de atmósfera","El oxígeno nos permite respirar y el depurador retira el dióxido de carbono que exhalamos. Son trabajos distintos: ¡hay que revisar ambos!","air",12),
  item("water","engineering","Recuperación de agua","Cada gota cuenta. Tratamos el agua usada y comprobamos su calidad antes de volver a utilizarla.","air",13),
  item("energy","engineering","Consola de energía","Aquí revisamos la electricidad y las baterías. El aire, el agua y las comunicaciones necesitan energía para funcionar.","power",5),
  item("filter","engineering","Filtro de repuesto","Esta caja guarda filtros etiquetados. Un filtro de aire atrapa partículas; el cartucho de agua pertenece a otro circuito.","air",25),
  item("fire","engineering","Seguridad contra incendios","Este panel avisa si detecta humo y ayuda a localizar el problema. El equipo entrenado sigue el procedimiento de emergencia.","safety",17),
  item("dose","command","Dosímetro de radiación","Mide la radiación recibida: no es un escudo. Sus lecturas y los avisos de Control ayudan a decidir cuándo buscar refugio.","radiation",18),
  item("shield","shelter","Refugio contra radiación","El material protector de esta sala reduce nuestra exposición durante una tormenta solar. Nos quedamos juntos hasta recibir instrucciones de Control.","radiation",27),
  item("command","command","Consola principal de mando","Aquí reunimos las noticias de la base. Escuchar al equipo nos ayuda a elegir qué tarea atender primero.","mission",0),
  item("radio","command","Estación de comunicaciones","Esta estación envía mensajes y descubrimientos a la Tierra. La señal tarda un poquito en recorrer toda esa distancia.","radio",11),
  item("map","command","Mesa de planificación","Un mapa nos ayuda a organizar rutas y tareas. Esta mesa holográfica es nuestra forma de mostrar esa información en Killa Wasi.","mission",15),
  item("arm","engineering","Brazo robótico","Este brazo sostiene piezas y mueve herramientas con precisión. Una persona supervisa el trabajo y mantiene despejada la zona.","robotics",14),
  item("spares","engineering","Caja de repuestos","Una pieza pequeña puede detener una máquina grande. Guardamos repuestos con etiquetas para encontrarlos cuando hacen falta.","mission",3),
  item("food","shelter","Inventario de alimentos","Aquí contamos las provisiones y revisamos sus etiquetas. Trajimos alimentos para la misión: el huerto todavía es un experimento.","food",3),
  item("grow","crops","Módulo de cultivo","La luz ayuda a las plantas a crecer. Observamos sus hojas y registramos cambios para aprender a cultivar lejos de la Tierra.","plants",2),
  item("irrigation","crops","Riego y nutrientes","Las raíces reciben agua y minerales disueltos. Darles demasiado o demasiado poco puede perjudicar a las plantas.","plants",13),
  item("bed_med","medical","Camilla médica","Aquí el médico examina a quien necesita atención. Preguntar cómo se siente alguien es tan importante como observar las pantallas.","health",1),
  item("vitals","medical","Monitor de signos vitales","Estos sensores dan pistas sobre el pulso y el oxígeno en la sangre. El médico interpreta las lecturas junto con otros datos.","health",104),
  item("kit","medical","Botiquín médico","Vendas, materiales y medicinas están organizados para atender al equipo. Las medicinas solo se usan con indicaciones del médico.","health",19),
  item("samples","minerals","Estantería de muestras","Cada roca lleva una etiqueta con su lugar de origen. Así conservamos las pistas incluso cuando la muestra cambia de habitación.","rocks",26),
  item("analyzer","minerals","Analizador mineral","Este instrumento nos ayuda a estudiar de qué está hecha una roca. Primero comprobamos sus mediciones con una muestra conocida.","rocks",4),
  item("sleep","bedroom","Cama y control de descanso","Dormir ayuda a pensar con claridad y trabajar con cuidado. Ajustamos la luz y respetamos el descanso de los demás.","sleep",20),
  item("exercise","gym","Equipo principal de ejercicio","En la Luna pesamos menos, pero seguimos necesitando movernos. La resistencia y el ejercicio ayudan a cuidar músculos, huesos y corazón.","exercise",21),
  item("hygiene","hygiene","Sistema sanitario","Recogemos los residuos de forma segura. Parte del agua pasa al sistema de tratamiento, donde se limpia y se comprueba antes de reutilizarla.","air",22)
 ]

static func item(id: String, room: String, title: String, description: String, source: String, art: int) -> Dictionary:
 return {"id":id,"room":room,"title":title,"description":description,"source":SOURCES[source],"art":art}

static func find_item(id: String) -> Dictionary:
 for entry in items():
  if entry.id == id: return entry
 return {}

static func extra_items() -> Array:
 return [
  item("vent","bedroom","Ventilador del dormitorio","El aire debe circular en un hábitat cerrado. Una rejilla obstruida impide que la ventilación haga bien su trabajo.","air",24),
  item("rover","exterior","Rover de apoyo","El guardabarros limita cuánto polvo lanzan las ruedas. Un parche temporal necesita estar bien sujeto y no rozar la rueda.","dust",23),
  item("rock","exterior","Muestra de la expedición","Primero registramos el lugar y después recogemos la muestra. La seguridad del equipo siempre tiene prioridad.","rocks",26)
 ]
