# Misión Killa Wasi

El proyecto principal es **`mision-killa-wasi`**: campaña jugable de los tres primeros días de una misión lunar educativa, ahora en **inglés**, con cinco tripulantes y un robot guía. Incluye explicaciones breves del propósito de cada tarea y audio inglés local con tonos distintos por personaje.

## Abrir el juego

1. Abre **Godot 4.7.2**.
2. Importa **`mision-killa-wasi/project.godot`**.
3. Abre el proyecto y pulsa **F5**.
4. Elige **New mission** o **Continue**.

También puedes ejecutar **`Jugar.ps1`** desde PowerShell. El lanzador importa y abre siempre el proyecto ampliado.

**Controles:** WASD/flechas para caminar, E para interactuar, Enter/Espacio para los diálogos, **T para tareas**, **J para el diario**, R para ayuda del robot, M para el croquis interactivo y Esc para pausa. Los botones funcionan con ratón o Tab y Enter.

La versión actual incorpora planificación por bloques, minijuegos, modos explicados **Cadet/Commander**, nombre del robot, cartas, recursos y escenas nocturnas. Consulta [ENGLISH_EDUCATION.md](mision-killa-wasi/ENGLISH_EDUCATION.md) para los cambios de idioma, contenido educativo, voces y pruebas actuales. Los ZIP anteriores contienen versiones previas.

La guía completa, el guardado y las pruebas están en [mision-killa-wasi/README.md](mision-killa-wasi/README.md). Consulta también el [registro de validación](mision-killa-wasi/VALIDACION.md) y las [fuentes científicas y adaptaciones](mision-killa-wasi/FUENTES_CIENTIFICAS.md).

El `project.godot` de la carpeta principal también funciona como acceso: al pulsar F5 prepara y abre la campaña de `mision-killa-wasi` en otra ventana de Godot. Para editar directamente la campaña, importa el proyecto que está **dentro de `mision-killa-wasi`**. El menú actual dice **THREE-DAY CAMPAIGN** y ofrece **New mission** y **Continue**.

Las escenas, scripts y recursos de la introducción anterior se conservan para consulta.

Los diseños originales del equipo, los archivos ZIP y las escenas de la jugabilidad mejorada se conservan. Las incorporaciones de campaña están en `mision-killa-wasi/campaign/`. Rama de trabajo: `codex/tres-primeros-dias`.

Equipo **ERROR 404** · Proyecto educativo para NASA Space Apps. El alcance jugable termina tras el día 3; la misión de 30 días continúa como contexto narrativo.
