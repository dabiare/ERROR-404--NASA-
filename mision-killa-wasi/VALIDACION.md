# Registro de validación

Fecha: 15 de noviembre de 2026. Windows, Godot **4.7.2 stable**, GDScript, Compatibility. Ejecución gráfica con OpenGL 3.3, NVIDIA GeForce RTX 5050 Laptop GPU.

## Resultados

| Comprobación | Resultado |
|---|---|
| Importación y arranque | Sin errores de scripts ni recursos faltantes |
| `--campaign-test` | **937 comprobaciones, 0 fallos** |
| `--keyboard-tour` | **Dos campañas completas**, ambas prioridades iniciales, dos decisiones de agua y dos decisiones solares; acceso a los 26 sistemas mediante movimiento y E |
| `--presentation-test` | **65 comprobaciones, 0 fallos**: capturas a **1280×720 y 1920×1080**, reproducción real de audio y los tres rescates |
| Revisión manual de Windows | Menú, opciones, nueva misión, alunizaje, contexto y avance de diálogo; Esc abre y cierra opciones |
| Integridad del exterior | Mismos fotogramas originales, caminata a 8 fps y velocidad base de 200 px/s; se reutilizan los polígonos de terreno del equipo |
| Archivos previos | Las escenas y controladores originales se conservan; `project.godot` y el lanzador señalan la campaña ampliada |

Las pruebas de estado cubren ocho combinaciones de prioridad/agua/retorno solar, respuestas incorrectas, recompensa única, preparación pendiente, muestras opcionales, filtros y cartuchos separados, recursos y reporte. También verifican rutas a todos los elementos y puertas recíprocas de las 12 escenas.

Se comprueba cada rescate por agotamiento de tiempo y la posibilidad de completar la campaña después. El rover consume un repuesto y cancela la muestra **extra**; la muestra principal sigue disponible. El rescate solar carga el refugio, pierde la bolsa de esa salida y consume una reserva.

El reloj se prueba detenido durante explicación inicial, diálogo, transición y pérdida de foco. El recorrido con teclado abre la ayuda mediante R durante decisiones y una actividad; comprueba que no descuente tiempo. Mantener E mediante eventos repetidos no duplica paneles. La confirmación de tarea verifica su identificador vigente antes de entregar resultados.

## Guardado

Se guarda y recupera cada emergencia con su tiempo restante. El recorrido de teclado sale al menú durante la emergencia del dormitorio y usa Continuar. También se prueban final de campaña, reinicio, datos incompatibles, inventario inválido, archivo principal corrupto y recuperación de la copia anterior.

El archivo de pruebas está separado del guardado normal. Las pruebas de recuperación usan una carga real desde disco; no se ha realizado un apagado forzado del equipo. Un cierre durante una actividad conserva la tarea pendiente y repite sus pasos aún no confirmados.

## Presentación y audio

Capturas en `artifacts/qa_*.png`: menú, reunión presencial, diálogo, prioridades, ayuda, alerta, mapa, opciones, dormitorio con cinco camas, higiene, ingeniería, cultivos, ejercicio, esclusa, exterior, reporte y los tres rescates. Los textos revisados caben a ambas resoluciones; el reporte largo usa desplazamiento.

Se comprueba que la música interior reproduce y conserva su posición entre habitaciones, que tensión sustituye a la pista normal mediante fundido, que los tres buses permiten silenciar, y que Blip tiene datos y se reproduce. La prueba espera el intervalo exterior real antes de comprobar su primera reproducción y verifica el intervalo posterior de 45–90 s. Se graba una mezcla del motor de audio en `artifacts/audio_mix_test.wav` para revisión auditiva del equipo. La valoración humana de balance musical y comodidad de la alarma queda pendiente; estas pruebas no sustituyen una escucha subjetiva.

Movimiento reducido detiene pulso del icono, suavizado de cámara y partículas/oscilaciones ambientales. Conserva texto y símbolos de alerta. La comprobación manual de Windows detectó una diferencia entre código físico y lógico de Esc en eventos de entrada; ambos tipos se admiten ahora.

## Duración y público infantil

El recorrido automatizado completo salta la lectura y ejecuta las dos ramas en aproximadamente **55 s de tiempo de ejecución acelerada**; recorre unos **281 y 289 s de tiempo simulado activo**, incluyendo exploración posterior. Estos números no representan una partida humana.

Los diálogos principales, preguntas, opciones y fichas breves suman **2615 palabras**, sin las páginas opcionales ni las tres capas de ayuda. A un ritmo hipotético de 80–110 palabras por minuto, leer todo ese contenido supone unos 24–33 minutos, más desplazamiento, comprensión y elecciones. Es una estimación de diseño, no una medición con niños. La meta de **35–50 minutos** debe validarse en una sesión posterior con niños de 7–12 años; lectores rápidos o quienes omitan fichas pueden terminar antes.

## Reproducir las pruebas

Las órdenes están en `README.md`. No hace falta conexión a Internet. Las capturas y guardados de prueba no se incluyen en Git; los scripts y todos los recursos necesarios sí están dentro del proyecto.
