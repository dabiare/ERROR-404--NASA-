# Procedencia de recursos

Se conservan los originales del repositorio. No se publican ni se reclaman derechos exclusivos sobre los materiales del equipo.

- **Comandante:** PNG original y `walk_01`, `walk_04`, `walk_06`; se mantienen los tres cuadros a 8 fps. El origen físico se sitúa bajo los pies.
- **Tripulación y robot:** diseños PNG aportados por el equipo, copiados dentro del proyecto para que este sea autónomo.
- **Exterior:** imagen y polígonos de `base_lunar.tscn`, sin modificar el archivo original.
- **Salas:** referencias JPG originales en `campaign/references/`. Se utilizan como referencia de color/equipos y como diagramas murales. La arquitectura se adapta a habitaciones independientes con suelo despejado y colisiones separadas.
- **props.png, crew.png y mapa consultable:** recursos de la introducción anterior. El mapa es una referencia consultable, no un fondo con colisiones incrustadas.
- **items/**: recursos extraídos de `elementos_individuales_png.zip`.
- **icons/frames_items/**: recursos de `frames_items.zip`. Se usa el primer fotograma recortando su área transparente mediante AtlasTexture y animación de `icono_hud.gd`; el resto de fotogramas queda disponible para el equipo.
- **Audio:** las tres músicas y `Blip.wav` aportados por el usuario. Alarma, confirmación y pasos sintetizados en `audio.gd`.

## Complementos ImageGen

Se empleó la herramienta integrada ImageGen en esta conversación. Los resultados finales están incluidos como archivos del proyecto; no requieren servicio externo al jugar.

### room_shell.png

Brief de generación: habitación vacía para juego lunar infantil en pixel art, vista superior con leve vista de la pared frontal, coherente con el mapa y las salas proporcionadas. Planta rectangular con esquinas recortadas, estructura metálica blanca/gris, detalles azul oscuro y luces cian/ámbar, suelo de baldosas, aperturas en los cuatro lados; sin texto, personajes ni mobiliario. El código añade puertas activas, muebles, etiquetas y colisiones.

### equipment.png

Brief de generación: atlas transparente de 4 × 4 elementos separados de equipamiento lunar educativo, misma perspectiva y estilo del mapa. Filas: consola de atmósfera, procesador de agua, brazo robótico, mesa holográfica; soporte de traje, armario de incendios, dosímetro, botiquín; cama, bicicleta, higiene, rover; ventilador/rejilla, cartucho, estantería de muestras, banco. Sin texto ni personajes. El juego utiliza las 16 celdas como AtlasTexture.

Las animaciones de sorpresa, trabajo, polvo, luces y reacción del robot se construyen en Godot sobre estos recursos. El meteorito se adapta conceptualmente del `meteorito.gd` del equipo; se conserva el original y se usa `meteorito_lunar.gd` sin ablación atmosférica, frenado por aire ni daño aleatorio.
