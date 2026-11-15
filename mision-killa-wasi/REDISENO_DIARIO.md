# Campaña con planificación diaria — versión 2

Implementación de la propuesta revisada y de los seis ajustes adicionales del equipo. El proyecto sigue siendo `mision-killa-wasi/project.godot`, Godot 4.7.2, Compatibility.

## Cambios jugables

- Pizarra con 3, 5 y 5 bloques; elegir orden entre tareas disponibles, con dependencias. Las emergencias no cuestan bloques. En los días 2 y 3 queda un bloque opcional.
- Rangos Cadete y Comandante. Cadete ofrece 1,5 veces el tiempo e invita a pedir una pista después de dos errores; nunca abre ayuda obligatoria ni reduce premios.
- Presentación presencial, elección de actitud y nombre del robot; humanos identificados por sus cargos.
- Actividades diferenciadas: revisión de indicadores, combinación de alimentos, búsqueda de etiquetas, calibración, aspiración y dirección de flujo, preparación de traje, registro de campo, montaje del guardabarros, tuberías, ejercicio con ritmo o práctica y recuento en el refugio.
- Muestras opcionales después de reparar el rover. La reparación asistida cancela la muestra extra.
- Cuatro barras abstractas, ánimo por tripulante, costes visibles de decisiones, cartas, insignias y mejoras visuales. Las reservas esenciales mantienen un suelo para evitar partidas imposibles.
- Cenas, pista de la señal cada noche, autorización final y exploración posterior. La luz verde siempre es alcanzable con ayuda; no exige una puntuación de ánimo que pueda bloquear al jugador.
- Diario con cartas y resultados; fichas cortas y enciclopedia opcional con niveles Cadete/Comandante.

Las actividades son prototipos funcionales con recursos del equipo y dibujos de Godot. Todavía necesitan pruebas de interés y dificultad con niños; las cifras de duración del documento son metas, no tiempos acreditados.

## Ajustes solicitados

| Solicitud | Implementación |
|---|---|
| Música inicial | `campaign/audio/musica_menu.mp3`, copia del MP3 adjunto; bucle en menú y alunizaje, transición al contexto interior/exterior |
| Quitar misión del centro superior | Se oculta ese rótulo; botón **T · Tareas** con **!** hasta consultar las novedades |
| Mapa interactivo | **M** abre un croquis con conexiones reales; selecciona una sala para consultarla. La sala actual muestra colisiones, equipos, puertas y posición de la comandante. No teletransporta |
| Textos fuera de cuadros | Ajuste de tamaño después de activar el salto de línea; altura mínima según la fuente real; botones cortos y texto largo con desplazamiento |
| Nombres de ambientes al acercarse | Puertas con dos hojas dibujadas; rótulo contextual con fundido/desplazamiento breve, sin movimiento vertical en modo reducido |
| Transición entre días | Cena y señal, pantalla de nueva jornada con aparición gradual y confirmación de inicio; estado de transición recuperable |

## Voz y accesibilidad

Se activa la síntesis de voz de Godot y se busca una voz local en español. En el equipo de validación se detectó **Microsoft Pablo (es-ES)**. Las instrucciones y diálogos cortos se pueden oír sin conexión cuando hay una voz compatible instalada. En equipos sin esa voz se conservan texto, iconos y controles; no se descarga una voz automáticamente. Blip sigue siendo un efecto electrónico del robot y no sustituye a la locución.

Las actividades admiten teclado y ratón. En calibración: izquierda/derecha ajustan y Enter comprueba. En aspiración: escoger zona y mantener E, Espacio o clic. En ejercicio: izquierda/derecha alternan; flecha abajo y Enter permiten práctica sin ritmo con la misma carta. R abre ayuda, Esc pausa, T tareas, J diario y M croquis.

## Guardado y compatibilidad

Archivo nuevo `user://campaign_v2.json`, con temporal y copia válida de respaldo. Conserva día, fase, bloques, tarea elegida, inventario, recursos, ánimo, cartas, nombre, rango, decisiones, rescates, posición, estado de personajes y progreso de la actividad (pasos, piezas y rotaciones). Al cargar se vuelve a interactuar con el equipo para retomar el minijuego.

Los archivos de la versión anterior no se sobrescriben. Su secuencia lineal no se transforma automáticamente en un plan diario; esta versión comienza una misión nueva. Los ZIP entregados anteriormente siguen siendo copias de la versión anterior.

## Arquitectura

- `daily_data.gd`: tareas, costes, dependencias, verbos, texto y auditoría.
- `daily_mission.gd`: única autoridad del estado; reutiliza la escritura y recuperación seguras anteriores.
- `daily_game.gd`: llegada, decisiones, minijuegos, noches y cambio de día.
- `daily_ui.gd`: tareas, diario, enciclopedia y diálogo breve; reutiliza la capa de interfaz anterior.
- `minigame.gd`: controles, pausa, pistas y resultados compartidos; comportamiento distinto por actividad.
- `map_view.gd`: croquis consultable y posición local basada en el escenario activo.
- Se reutilizan `room.gd`, `actor.gd` y `audio.gd`, con los ajustes indicados. Los archivos lineales anteriores se conservan como base e historial.

## Validación actual

- **718 comprobaciones de estado, sin fallos:** ocho combinaciones de rango, prioridad y agua; dependencias y presupuestos; recompensas únicas; tres rescates; recuperación de emergencia y de un puzzle a mitad; acceso a los objetos; auditoría de texto y vocabulario.
- **Dos recorridos completos mediante entradas de teclado:** ambas prioridades, decisiones del agua y bolsa solar, tarea opcional, dos cambios de día y preparación antes de la segunda salida. **34 actividades**, sin rescates imprevistos.
- **52 capturas gráficas** a 1280×720 y 1920×1080: tareas, croquis interior y exterior, salas, puerta cercana, actividades, pistas, transición y reporte. Se comprueba reproducción de la música del menú, continuidad interior y disponibilidad de voz local.
- Auditoría de datos narrativos: máximo 15 palabras por intervención y ausencia de los términos técnicos excluidos del flujo principal. El diálogo adicional se pagina automáticamente con el mismo límite.

Comandos actuales en `README.md`: `--daily-test`, `--daily-tour` y `--daily-visual`. Las pruebas escriben `test_daily_v2.json`, sin reemplazar la partida normal. Las capturas se guardan en `artifacts/daily/`.

Pendiente con participantes reales: medir duración por día y total, proporción de lectura, comprensión, diversión y dificultad. No se afirma haber realizado sesiones con niños. El objetivo temporal coherente del documento es **39–50 minutos** al sumar sus intervalos diarios; requiere balance posterior, especialmente para lectores rápidos y jugadores que omitan contenido opcional.

## Adaptación científica

La revisión inicial usa indicadores interpretados por el médico; no diagnostica una supuesta burbuja del oído. El flujo y el CO₂ se muestran como datos del sensor, sin representar el gas como visible. Ventilar y retirar CO₂ son trabajos diferentes. El agua se trata y comprueba, sin compararla injustificadamente con el agua del caño. La preparación de presión resume un protocolo supervisado, sin recetas universales. El mayor gasto energético del traje es una regla ficticia. Las mejoras de plantas y decoración son recompensas visuales; el ánimo no se presenta como causa biológica directa. La señal de la sonda pertenece a la ficción del juego.

Las fuentes siguen asociadas a cada elemento en `catalog.gd` y en `FUENTES_CIENTIFICAS.md`.
