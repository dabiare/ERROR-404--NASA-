# Misión Killa Wasi — tres primeros días

Proyecto principal en Godot **4.7.2**, GDScript y renderizador Compatibility. Equipo ERROR 404. La campaña termina con el informe del día 3; los 30 días siguen siendo el contexto de la misión.

## Abrir y jugar

1. Abre Godot 4.7.2 y pulsa **Importar**.
2. Selecciona **este** `project.godot`, dentro de `mision-killa-wasi`.
3. Abre el proyecto y pulsa **F5**.
4. Elige **Nueva misión** o **Continuar**.

El `Jugar.ps1` de la carpeta superior abre este proyecto. La primera importación puede tardar porque incluye los recursos de arte y los fotogramas proporcionados por el equipo. No necesita Internet, plugins, .NET ni plantillas de exportación.

## Controles

| Acción | Control |
|---|---|
| Caminar | WASD o flechas |
| Interactuar con el elemento o puerta más cercano | E |
| Avanzar diálogo / mostrar toda la frase | Enter, Espacio o clic en Continuar |
| Elegir botones | Tab / Shift+Tab, después Enter o Espacio; también ratón |
| Ayuda opcional del robot, incluso en actividades | R o botón Ayuda del robot |
| Mapa sin teletransporte | M |
| Pausa y opciones | Esc |

El objetivo aparece arriba y la indicación inferior identifica la interacción cercana. Las puertas se activan con E. En interiores se ve la habitación completa; en el exterior la cámara sigue a la comandante. Higiene se accede desde el dormitorio.

Las actividades piden elegir, confirmar y comprobar. Las pistas del robot explican el concepto, señalan dónde buscar y detallan el siguiente paso. No cuestan recursos. Los errores de respuesta se pueden corregir.

## Campaña

- **Llegada:** alunizaje omisible que conserva el contexto, entrada y reunión presencial con los cuatro especialistas.
- **Día 1:** adaptación y revisión médica, comida, prioridad entre repuestos y laboratorio, ventilación del dormitorio.
- **Día 2:** traje, radio y esclusa; geólogo, rover, reparación del guardabarros, impacto lejano, muestras, limpieza de polvo y sellos.
- **Día 3:** diagnóstico del agua, reserva o pausa del riego, cartucho compatible, ejercicio, salida científica, alerta solar, refugio y reporte.
- **Después:** explorar los 26 sistemas, consultar sus fichas y completar la preparación inicial pendiente.

Las emergencias duran 90, 60 y 180 segundos **de juego**. El reloj comienza después de explicar el incidente y se detiene durante diálogos, decisiones, actividades de panel, ayuda, pausa, cambios de habitación y pérdida de foco. Estos valores no representan plazos médicos. Si se acaba, interviene el equipo y se registra el coste: la campaña puede continuar.

## Guardado y opciones

Autoguardado al completar una tarea, consultar un sistema, realizar una preparación opcional, cambiar de sala, cerrar la ventana o volver al menú. Se conserva el paso pendiente de la emergencia y su tiempo restante. Una actividad sin confirmar se vuelve a comenzar desde su objetivo, sin duplicar recompensas.

En Windows el guardado está normalmente en `%APPDATA%\KillaWasi\campaign_v1.json`. Se escribe primero un archivo temporal y se conserva una copia `.bak` válida. Si el archivo principal no se puede cargar, el menú ofrece recuperar la copia o comenzar de nuevo. **Nueva misión** pide confirmación antes de reemplazar progreso.

En Opciones hay volumen independiente de música, efectos y voz del robot, además de movimiento reducido. La música interior conserva su posición al cambiar de habitación. La música exterior espera 15–35 s al salir y 45–90 s entre canciones; la tensión sustituye temporalmente la música normal.

## Para editar

| Archivo / carpeta | Responsabilidad |
|---|---|
| `campaign/main.tscn`, `game.gd` | Inicio, escenas, interacción y presentación |
| `campaign/mission.gd` | Autoridad del progreso, inventario, elecciones, emergencias y guardado |
| `campaign/story.gd` | Secuencia y textos de la campaña |
| `campaign/catalog.gd` | 26 identificadores, fichas, fuentes y tripulación |
| `campaign/rooms/`, `room.gd` | 12 escenas, puertas, mobiliario, navegación y NPC |
| `campaign/actor.gd` | Movimiento, animaciones, robot, trabajo y sorpresa |
| `campaign/ui.gd` | Diálogos, decisiones, actividades, mapa, ayuda e informe |
| `campaign/audio.gd` | Música persistente, efectos, alarma y voz |
| `campaign/meteorito_lunar.gd` | Impacto lejano sin atmósfera ni daño |
| `campaign/art/`, `audio/`, `references/` | Recursos incluidos y guion original |
| `campaign/tests/` | Pruebas de campaña, teclado, presentación y audio |

Los archivos anteriores (`base_lunar.tscn`, `comandante.gd`, etc.) se conservan. La campaña reutiliza el fondo y todos los polígonos de colisión del exterior, los tres fotogramas de caminata a 8 fps y la velocidad base de 200 px/s. Se centra el cuerpo físico bajo la comandante; en el exterior se añade aceleración y salto visual sin alterar el plano de colisiones.

## Verificación

Desde la carpeta superior:

```powershell
$godot = 'C:\Users\Domenick\Desktop\Godot\Godot_v4.7.2-stable_win64_console.exe'
& $godot --headless --path mision-killa-wasi --editor --import --quit
& $godot --headless --path mision-killa-wasi -- --campaign-test
& $godot --headless --path mision-killa-wasi --fixed-fps 60 -- --keyboard-tour
& $godot --path mision-killa-wasi -- --presentation-test
```

Las pruebas usan `test_campaign_v1.json` y no reemplazan la partida normal. Las capturas y la grabación de mezcla se guardan en `artifacts/`, excluida de Git. El registro detallado está en [VALIDACION.md](VALIDACION.md); las fuentes y adaptaciones están en [FUENTES_CIENTIFICAS.md](FUENTES_CIENTIFICAS.md).

La meta de duración es **35–50 minutos** incluyendo lectura, decisiones y exploración. La prueba automatizada salta la lectura: su tiempo no equivale al de una partida infantil. Hace falta una sesión posterior con niños de 7–12 años para validar duración, comprensión y dificultad.
