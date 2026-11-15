# Fuentes y adaptación educativa

Revisión: 15 de noviembre de 2026. El guion aportado se conserva en `campaign/references/guion_original.md`. Sus problemas organizan la campaña; no se adoptaron literalmente sus cifras ni sus afirmaciones clínicas. Cada identificador de `campaign/catalog.gd` contiene una fuente y dos niveles de explicación.

## Fundamentos y simplificaciones

| Tema | Fuente primaria | Aplicación |
|---|---|---|
| Gravedad lunar | [NASA: Moon Facts](https://science.nasa.gov/moon/facts/) | Aproximadamente 1/6 de la gravedad terrestre. Los saltos son visuales y no cambian la colisión; no se representa ingravidez. |
| Aire y agua | [NASA: ECLSS](https://www.nasa.gov/reference/environmental-control-and-life-support-systems-eclss/) | Ventilación, retirada de CO₂, aporte de oxígeno y tratamiento de agua son funciones diferentes. Diagnóstico, pieza compatible y comprobación resumen procesos más complejos. |
| Descompresión | [NASA: Risk of Decompression Sickness](https://www.nasa.gov/reference/risk-of-decompression-sickness/) | La preparación con oxígeno reduce el nitrógeno y el riesgo al cambiar de presión. No se prescribe una duración universal ni se promete seguridad absoluta. |
| Polvo | [NASA: Lunar Dust Technical Brief](https://www.nasa.gov/wp-content/uploads/2023/12/ochmo-tb-011-lunar-dust-technical-brief.pdf) | Abrasión y contaminación de equipos; limpieza en zona controlada. No se afirma que una aspiradora doméstica funcione en el vacío. |
| Guardabarros | [NASA: Apollo 17 Lands at Taurus-Littrow](https://www.nasa.gov/history/50-years-ago-apollo-17-lands-at-taurus-littrow/) | La reparación con mapas y sujeciones inspira una práctica con material preparado. El rover permanece estacionado. |
| Radiación | [NASA: protección en la Luna](https://science.nasa.gov/science-research/heliophysics/how-nasa-will-protect-astronauts-from-space-radiation-at-the-moon/) y [NASA SRAG: protección y dosimetría](https://srag.jsc.nasa.gov/SpaceRadiation/How/How.cfm) | Aviso, retorno, blindaje, recuento, medición y seguimiento. El dosímetro mide y el refugio reduce exposición; no eliminan todo el riesgo. |
| Salud y descanso | [NASA: Fundamentals of Human Health](https://www.nasa.gov/reference/fundamentals-of-human-health/) y [Crew Systems](https://www.nasa.gov/reference/crew-systems/) | El médico interpreta lecturas y decide la atención. El niño no diagnostica ni elige medicamentos sin supervisión. |
| Ejercicio | [NASA: Astronaut Exercise](https://www.nasa.gov/missions/station/iss-research/astronaut-exercise/) | Resistencia y actividad cardiovascular mediante prácticas breves. No se trasladan tasas de pérdida muscular en microgravedad a la Luna. |
| Alimentos y cultivo | [CSA: Food Production](https://www.asc-csa.gc.ca/eng/youth-educators/toolkits/food-production/) y [NASA: Habitability Functions](https://www.nasa.gov/reference/7-0-habit-ability-functions-vol-2/) | Provisiones como fuente principal y huerto experimental. Condimentos opcionales y respeto por las preferencias. |
| Muestras | [NASA: Apollo Samples](https://science.nasa.gov/science-research/planetary-science/astrobiology/nasas-apollo-samples-yield-new-information-about-the-moon/) | Procedencia, observación y comparación. El analizador genérico representa principios de medición, no un instrumento específico. |
| Energía | [NASA: Lunar Surface Technology](https://www.nasa.gov/lunar-surface-technology/) | Generación y almacenamiento para sostener los sistemas de la base. |
| Robótica | [NASA: Mobile Servicing System](https://www.nasa.gov/international-space-station/mobile-servicing-system/) | Manipulación asistida y supervisión; el brazo y el robot guía son ficticios. |
| Comunicación | [NASA: Communicating with Missions](https://www.nasa.gov/communicating-with-missions/) | Radio para coordinar y transmitir datos; se omite la latencia en los diálogos. |
| Operaciones y seguridad | [NASA: Spaceflight Operations](https://www.nasa.gov/reference/jsc-spaceflight-operations/) y [Hardware and Equipment](https://www.nasa.gov/reference/9-0-hardware-and-equipment-vol-2/) | Tareas, repuestos, detección y respuesta. Las listas del juego no son procedimientos operativos reales. |

La campaña omite la administración preventiva de antioxidantes propuesta en el documento original. Las contramedidas farmacológicas específicas contra radiación siguen investigándose; aquí se priorizan protección y seguimiento. Referencia del plan: [NASA NTRS, revisión de radiación espacial](https://ntrs.nasa.gov/api/citations/20250004252/downloads/Book%20Chapter.pdf).

## Catálogo estable

Cada elemento admite consulta repetida sin duplicar avances, ficha infantil, página opcional y estado de misión.

| ID | Nombre | Habitación | Concepto |
|---|---|---|---|
| `lock` | Control de la esclusa | Esclusa | Presión y preparación |
| `dust` | Limpieza de polvo lunar | Esclusa | Abrasión y contención |
| `suits` | Soporte para trajes | Esclusa | Ambiente respirable y uniones |
| `atmosphere` | Consola de atmósfera | Ingeniería | Oxígeno, CO₂ y circulación |
| `water` | Recuperación de agua | Ingeniería | Tratamiento y calidad |
| `energy` | Consola de energía | Ingeniería | Generación y almacenamiento |
| `filter` | Filtro de repuesto | Ingeniería | Filtros y cartuchos compatibles |
| `fire` | Seguridad contra incendios | Ingeniería | Detección y respuesta |
| `dose` | Dosímetro de radiación | Mando | Medición de exposición |
| `shield` | Refugio contra radiación | Refugio | Blindaje y protección colectiva |
| `command` | Consola principal de mando | Mando | Coordinación |
| `radio` | Estación de comunicaciones | Mando | Enlace de datos y voz |
| `map` | Mesa de planificación | Mando | Rutas y organización |
| `arm` | Brazo robótico | Ingeniería | Manipulación supervisada |
| `spares` | Caja de repuestos | Ingeniería | Inventario y mantenimiento |
| `food` | Inventario de alimentos | Sala común | Nutrición y preferencias |
| `grow` | Módulo de cultivo | Cultivos | Investigación de crecimiento |
| `irrigation` | Riego y nutrientes | Cultivos | Agua y humedad |
| `bed_med` | Camilla médica | Medicina | Evaluación de la persona |
| `vitals` | Monitor de signos vitales | Medicina | Lecturas e interpretación |
| `kit` | Botiquín médico | Medicina | Materiales y supervisión |
| `samples` | Estantería de muestras | Minerales | Conservación y procedencia |
| `analyzer` | Analizador mineral | Minerales | Referencia y medición |
| `sleep` | Cama y control de descanso | Dormitorio | Sueño, luz y ruido |
| `exercise` | Equipo principal de ejercicio | Ejercicio | Resistencia y cardio |
| `hygiene` | Sistema sanitario | Higiene | Recogida y tratamiento |

El ventilador y rejilla (`vent`), el guardabarros (`rover`), el menú (`food`) y la muestra de campo (`rock`) son componentes o interacciones adicionales. El dosímetro y la radio del refugio se consultan desde su panel durante la emergencia para evitar salir de la zona protegida.

## Decisiones de diseño

- 90/60/180 segundos son límites lúdicos, no tiempos de supervivencia. Las reservas son unidades abstractas de inventario.
- CO₂ en aumento no significa que desaparezca automáticamente el oxígeno. La circulación y el tratamiento tienen funciones distintas.
- El impacto del día 2 y la alerta solar son eventos diferentes. El impacto no lleva llama atmosférica ni produce daño aleatorio.
- Los pasos se perciben dentro del traje. La música acompaña al juego, no se propaga por el vacío.
- Viaje y cambio de gravedad motivan la revisión inicial. No se confunden molestias de oído con enfermedad por descompresión.
- Preparación de salida, pruebas de calidad, ejercicio y fin de alerta usan saltos narrativos. Las decisiones clínicas corresponden al médico.
- La base, la mesa holográfica, el robot y sus distribuciones son ficción. Las fuentes respaldan conceptos; no certifican el diseño ni implican respaldo de NASA al proyecto.
