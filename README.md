# Misión Killa Wasi

Introducción jugable de un videojuego educativo para NASA Space Apps: alunizaje, llegada a una base lunar, presentación de cinco especialistas y una primera decisión entre preparar el almacén o el laboratorio.

## Jugar

1. Abre Godot **4.7.2**.
2. En el administrador de proyectos, pulsa **Importar** y selecciona `project.godot` de esta carpeta.
3. Abre el proyecto y pulsa **F5**.
4. Selecciona **Iniciar misión**.

También puedes ejecutar `Jugar.ps1` con PowerShell. El lanzador usa la instalación de Godot encontrada en el escritorio y, si no está allí, busca Godot en PATH.

No requiere plugins, .NET, conexión a Internet ni plantillas de exportación para jugar dentro de Godot. Todos los recursos están incluidos.

## Controles

| Acción | Control |
|---|---|
| Mover a la comandante | WASD o flechas |
| Interactuar cuando aparece la indicación | E |
| Avanzar un diálogo | Enter, Espacio o botón Continuar |
| Navegar botones | Tab / Shift+Tab y Enter o Espacio |
| Pausa, volumen y movimiento reducido | Esc o botón de pausa |

Sigue las pequeñas marcas doradas. Las indicaciones superiores muestran el objetivo y el área actual. La radio está en el centro de mando, al norte del pasillo de entrada. Tras los reportes del equipo, elige y confirma tu prioridad.

**Almacén:** revisa ambos estantes de ingeniería, en cualquier orden. **Laboratorio:** enciende la consola y registra la muestra. El informe final muestra el resultado y la tarea pendiente. Después puedes visitar las áreas y conversar con los cuatro especialistas.

## Contenido y límites de esta entrega

- Cinco tripulantes: comandante, ingeniero jefe, bióloga botánica, médico de vuelo y geólogo lunar.
- La comandante es el único personaje controlable.
- Primera sesión prevista de aproximadamente 5–8 minutos según ritmo de lectura y exploración; pendiente de medir con niños del público objetivo.
- Estado de misión durante la sesión; reiniciar restablece todas las tareas. El juego no guarda una campaña entre sesiones.
- La estancia de 30 días forma parte del contexto narrativo. Esta versión termina tras la primera preparación del día 1.
- Las cifras y tiempos de la misión son ficción de diseño. No es un simulador de procedimientos reales de vuelo.

## Estructura para el equipo

- `scenes/`: escenas independientes del menú, alunizaje, exterior, interior e interfaz.
- `scripts/mission_data.gd`: reportes de la tripulación, colores, roles y diálogos iniciales.
- `scripts/session.gd`: etapas, elección, inventario y resultados; evita recompensas repetidas.
- `scripts/world.gd`: distribución de la base, mobiliario, colisiones e indicaciones de recorrido.
- `scripts/player.gd`: controles, cámara y animaciones de la comandante.
- `scripts/interface.gd`: objetivos, radio, decisiones, informe, pausa y opciones.
- `assets/art/`: ilustraciones, retratos y sprites incluidos en el proyecto.
- `tests/smoke.gd`: comprobaciones integradas de ambos recorridos, reinicio, bloqueos, colisiones y accesibilidad básica.

## Validación

Desde PowerShell, en esta carpeta:

```powershell
$godot = 'C:\Users\Domenick\Desktop\Godot\Godot_v4.7.2-stable_win64_console.exe'
& $godot --headless --path . --editor --import --quit
& $godot --headless --path . -- --smoke-test
& $godot --headless --path . -- --keyboard-test
& $godot --path . -- --smoke-test --capture
```

La última orden abre el juego, comprueba las ramas y guarda capturas a 1280×720 y 1920×1080 dentro de `artifacts/` (excluido de Git). Se cierra al terminar. El código de salida es 0 cuando pasan las comprobaciones.

La prueba `--keyboard-test` recorre las dos ramas mediante eventos de teclado enviados al sistema de entrada de Godot. Camina siguiendo rutas que respetan las colisiones, utiliza E, avanza los reportes y confirma las opciones con Tab/Enter. No usa teletransporte ni activa directamente las recompensas.

## Arte, sonido y referencias

Arte generado con la herramienta integrada ImageGen, inspirado en las imágenes del documento del equipo. Las instrucciones de generación y la procedencia están en `assets/art/PROMPTS.md`. Los sprites se usan como atlas sin alterar los originales. La geometría de escenarios, señalética e interfaz es nativa de Godot. El ambiente y los efectos de sonido se sintetizan localmente.

- [Documento de lluvia de ideas](https://docs.google.com/document/d/1gCs5G-uFG9-iR8PhUOyHkd4FyISKZeaZoOkynb9B6_U)
- [Desafío Junior Astronaut Mission Trainer](https://www.spaceappschallenge.org/2026/challenges/junior-astronaut-mission-trainer/)

El equipo se identifica como ERROR 404. El juego conserva el nombre aprobado **Misión Killa Wasi**.
