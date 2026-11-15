extends RefCounted
const ART := "res://campaign/art/"
const ROOMS := {
 "corridor":"Killa Wasi corridors", "airlock":"Airlock", "command":"Mission control room",
 "engineering":"Engineering", "medical":"Medical bay", "crops":"Greenhouse",
 "minerals":"Rock laboratory", "shelter":"Shelter and common room",
 "bedroom":"Sleeping quarters", "hygiene":"Hygiene module", "gym":"Exercise room", "exterior":"Lunar surface"
}
const COLORS := {"commander":"f6ca68","engineer":"ff9b60","botanist":"8bd49b","doctor":"79cfef","geologist":"d9ae80","robot":"66e5ef","control":"b1bacf"}
const NAMES := {"commander":"Commander","engineer":"Chief engineer","botanist":"Botanist","doctor":"Flight doctor","geologist":"Lunar geologist","robot":"Guide robot","control":"Mission Control"}
const PEOPLE := {
 "commander":"res://Astronauta Comandante Sonriente.png",
 "engineer":ART+"Astronauta ingeniero con llave y tableta.png",
 "botanist":ART+"Aventurera espacial con terrario verde.png",
 "doctor":ART+"Astronauta médico con botiquín.png",
 "geologist":ART+"Astronauta geólogo explorando la luna.png",
 "robot":ART+"Robot sonriente azul con luna y estrellas.png"
}
const HOME := {"engineer":"engineering","botanist":"crops","doctor":"medical","geologist":"minerals"}
const WORK := {"engineer":"Checking connections","botanist":"Measuring seedlings","doctor":"Reviewing readings","geologist":"Sorting rock samples"}
const FACTS := {
 "lock": "The crew checks pressure before opening a door. Pressure preparation follows the flight doctor's protocol; a game timer is not a real medical procedure.",
 "dust": "Lunar dust can scratch materials, wear seals, and contaminate the habitat. Cleaning takes place in a controlled area, rather than spreading dust around the rooms.",
 "suits": "A suit controls pressure, oxygen, and temperature. Crew members inspect connections and seals before each trip outside.",
 "atmosphere": "Moving air and removing carbon dioxide are different jobs. Particle filters catch dust; the carbon-dioxide scrubber removes a gas that ordinary dust filters do not trap.",
 "water": "Water recovery uses several treatment stages. Replacing a compatible cartridge is one maintenance step; the crew still checks water quality before using the supply.",
 "energy": "Solar panels generate electricity, and batteries store some for later. The game's resource bar represents an imagined base, not a certified engineering design.",
 "filter": "A dust filter catches particles, like a tiny net. It does not replace a carbon-dioxide scrubber or a water-treatment cartridge. Matching labels help identify compatible spares.",
 "fire": "Fire can produce dangerous gases as well as heat. Detection, suitable equipment, and trained responses help protect people inside a closed habitat.",
 "dose": "Dosimeter readings support decisions made with Mission Control and the medical team. Protection also depends on shelter, shielding, location, and the radiation environment.",
 "shield": "Sheltering reduces exposure but does not remove all radiation risk. The crew stays together, monitors readings, and waits for Mission Control's instructions.",
 "command": "Planning compares needs, available resources, and time. The commander coordinates specialists and checks the outcome of decisions.",
 "radio": "Radio signals travel through a vacuum. Conversations in the game omit the real signal delay to keep dialogue easy to follow.",
 "map": "A recorded route helps a team coordinate and respond if someone needs assistance. The holographic table is a fictional way to display information.",
 "arm": "Robotic manipulators can support maintenance and handling tasks. Operators need to understand their limits and keep the work area clear.",
 "spares": "In the storage activity, AD-42 is the fictional code for one spare dust-filter box and its shelf location. Selecting the two matching cards represents checking both labels; Store filter records the box in inventory.",
 "food": "The crew needs energy, nutrients, and food they enjoy eating. Our supplies from Earth remain the main food source while the greenhouse is an experiment.",
 "grow": "The botanist observes leaves and records changes. Plant growth depends on its environment and care, rather than directly depending on how happy a person feels.",
 "irrigation": "Plants need suitable water, nutrients, and access to oxygen around their roots. After repairing the water loop, the crew also checks the systems that depend on it.",
 "bed_med": "A medical assessment combines symptoms, observations, and measurements. Looking at a screen alone does not establish a diagnosis.",
 "vitals": "A reading can be incomplete or affected by the sensor. The doctor checks that it makes sense and considers other information before deciding what it means.",
 "kit": "Spaceflight medical kits include materials for assessment and treatment. In this educational game, clinical decisions remain with the flight doctor.",
 "samples": "A rock's location and surrounding conditions help scientists interpret it. Careful documentation preserves clues when samples move from the surface to the laboratory.",
 "analyzer": "Calibration compares an instrument with a reference. The matching-number activity demonstrates this idea; it does not represent a specific real lunar instrument.",
 "sleep": "Sleep supports health, attention, and wellbeing. Lighting, schedules, noise, and the habitat environment can affect rest.",
 "exercise": "The Moon has roughly one-sixth of Earth's gravity, not weightlessness. The flight doctor plans suitable exercise; our short activity summarizes a longer session.",
 "hygiene": "Containing waste helps protect a closed habitat. Water recovery needs treatment and quality checks; waste does not become drinking water directly.",
 "vent": "A blocked opening reduces airflow. The activity first checks a sensor, then clears three vent sections and aims the fan. The final reading checks that circulation improved; a separate scrubber removes carbon dioxide.",
 "rover": "The rover stays parked during the repair. The player chooses a sheet, suitable tape, and clamps, then checks that the patch stays secure and does not rub the wheel.",
 "rock": "Pressing a record card represents writing that observation in the field log. Keeping the same kinds of records allows scientists to compare observations from different days."
}
const CHATS = preload('res://campaign/daily_data.gd').CHATS
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
  item("lock","airlock","Airlock controls","This room keeps our air inside while we enter or leave.","suit",103),
  item("dust","airlock","Moon-dust cleaning station","We remove and contain suit dust before entering our clean living space.","dust",105),
  item("suits","airlock","Spacesuit rack","A spacesuit is a tiny spacecraft that provides a breathable environment.","suit",16),
  item("atmosphere","engineering","Air-system console","Fans circulate air. Other equipment controls oxygen and removes the carbon dioxide we exhale.","air",12),
  item("water","engineering","Water-recycling unit","Used water goes through treatment and quality checks before returning to our supply.","air",13),
  item("energy","engineering","Power console","Our air, water, and communication systems need electricity to work.","power",5),
  item("filter","engineering","Labeled spare filters","Dust filters and water cartridges do different jobs. Always check their codes.","air",25),
  item("fire","engineering","Fire-safety equipment","Sensors warn the crew about smoke so trained teammates can respond.","safety",17),
  item("dose","command","Radiation dosimeter","A dosimeter measures radiation exposure. It does not act as a shield.","radiation",18),
  item("shield","shelter","Radiation shelter","Protective material around this room helps reduce radiation exposure during a solar alert.","radiation",27),
  item("command","command","Main command console","This is where we listen to the crew and plan our next tasks.","mission",0),
  item("radio","command","Communication station","Radio messages connect our crew with each other and with Earth.","radio",11),
  item("map","command","Planning table","Maps help us choose routes and remember where our teammates will work.","mission",15),
  item("arm","engineering","Robotic arm","This arm helps hold equipment and move tools while a person supervises.","robotics",14),
  item("spares","engineering","Spare-parts storage","Matching box and shelf codes helps us store and find the correct spare.","mission",3),
  item("food","shelter","Food-supply station","We count food, read its labels, and plan balanced meals for the crew.","food",3),
  item("grow","crops","Plant-growing module","Light, water, nutrients, and suitable conditions help our experimental plants grow.","plants",2),
  item("irrigation","crops","Plant watering and nutrients","We check moisture and watering to avoid giving roots too much or too little.","plants",13),
  item("bed_med","medical","Medical examination bed","The doctor listens to how you feel and checks you when needed.","health",1),
  item("vitals","medical","Health-reading monitor","Sensors measure pulse, blood oxygen, and temperature. The doctor explains the readings.","health",104),
  item("kit","medical","Medical kit","Medical supplies are organized here. Only the medical team chooses how medicines are used.","health",19),
  item("samples","minerals","Rock-sample shelves","Every sample has a label so its place of origin is remembered.","rocks",26),
  item("analyzer","minerals","Rock-analysis instrument","We check this instrument against a known reference before trusting a new reading.","rocks",4),
  item("sleep","bedroom","Crew bed and rest controls","Rest helps us think clearly. We keep light and noise comfortable for sleepers.","sleep",20),
  item("exercise","gym","Crew exercise equipment","Resistance and cycling help care for our muscles, bones, and heart.","exercise",21),
  item("hygiene","hygiene","Hygiene and waste system","Waste stays safely contained. Some water goes through treatment before being reused.","air",22)
 ]

const ENGLISH_ITEMS := {
 "lock": [
  "Airlock controls",
  "This room keeps our air inside while we enter or leave.",
  "The crew checks pressure before opening a door. Pressure preparation follows the flight doctor's protocol; a game timer is not a real medical procedure."
 ],
 "dust": [
  "Moon-dust cleaning station",
  "We remove and contain suit dust before entering our clean living space.",
  "Lunar dust can scratch materials, wear seals, and contaminate the habitat. Cleaning takes place in a controlled area, rather than spreading dust around the rooms."
 ],
 "suits": [
  "Spacesuit rack",
  "A spacesuit is a tiny spacecraft that provides a breathable environment.",
  "A suit controls pressure, oxygen, and temperature. Crew members inspect connections and seals before each trip outside."
 ],
 "atmosphere": [
  "Air-system console",
  "Fans circulate air. Other equipment controls oxygen and removes the carbon dioxide we exhale.",
  "Moving air and removing carbon dioxide are different jobs. Particle filters catch dust; the carbon-dioxide scrubber removes a gas that ordinary dust filters do not trap."
 ],
 "water": [
  "Water-recycling unit",
  "Used water goes through treatment and quality checks before returning to our supply.",
  "Water recovery uses several treatment stages. Replacing a compatible cartridge is one maintenance step; the crew still checks water quality before using the supply."
 ],
 "energy": [
  "Power console",
  "Our air, water, and communication systems need electricity to work.",
  "Solar panels generate electricity, and batteries store some for later. The game's resource bar represents an imagined base, not a certified engineering design."
 ],
 "filter": [
  "Labeled spare filters",
  "Dust filters and water cartridges do different jobs. Always check their codes.",
  "A dust filter catches particles, like a tiny net. It does not replace a carbon-dioxide scrubber or a water-treatment cartridge. Matching labels help identify compatible spares."
 ],
 "fire": [
  "Fire-safety equipment",
  "Sensors warn the crew about smoke so trained teammates can respond.",
  "Fire can produce dangerous gases as well as heat. Detection, suitable equipment, and trained responses help protect people inside a closed habitat."
 ],
 "dose": [
  "Radiation dosimeter",
  "A dosimeter measures radiation exposure. It does not act as a shield.",
  "Dosimeter readings support decisions made with Mission Control and the medical team. Protection also depends on shelter, shielding, location, and the radiation environment."
 ],
 "shield": [
  "Radiation shelter",
  "Protective material around this room helps reduce radiation exposure during a solar alert.",
  "Sheltering reduces exposure but does not remove all radiation risk. The crew stays together, monitors readings, and waits for Mission Control's instructions."
 ],
 "command": [
  "Main command console",
  "This is where we listen to the crew and plan our next tasks.",
  "Planning compares needs, available resources, and time. The commander coordinates specialists and checks the outcome of decisions."
 ],
 "radio": [
  "Communication station",
  "Radio messages connect our crew with each other and with Earth.",
  "Radio signals travel through a vacuum. Conversations in the game omit the real signal delay to keep dialogue easy to follow."
 ],
 "map": [
  "Planning table",
  "Maps help us choose routes and remember where our teammates will work.",
  "A recorded route helps a team coordinate and respond if someone needs assistance. The holographic table is a fictional way to display information."
 ],
 "arm": [
  "Robotic arm",
  "This arm helps hold equipment and move tools while a person supervises.",
  "Robotic manipulators can support maintenance and handling tasks. Operators need to understand their limits and keep the work area clear."
 ],
 "spares": [
  "Spare-parts storage",
  "Matching box and shelf codes helps us store and find the correct spare.",
  "In the storage activity, AD-42 is the fictional code for one spare dust-filter box and its shelf location. Selecting the two matching cards represents checking both labels; Store filter records the box in inventory."
 ],
 "food": [
  "Food-supply station",
  "We count food, read its labels, and plan balanced meals for the crew.",
  "The crew needs energy, nutrients, and food they enjoy eating. Our supplies from Earth remain the main food source while the greenhouse is an experiment."
 ],
 "grow": [
  "Plant-growing module",
  "Light, water, nutrients, and suitable conditions help our experimental plants grow.",
  "The botanist observes leaves and records changes. Plant growth depends on its environment and care, rather than directly depending on how happy a person feels."
 ],
 "irrigation": [
  "Plant watering and nutrients",
  "We check moisture and watering to avoid giving roots too much or too little.",
  "Plants need suitable water, nutrients, and access to oxygen around their roots. After repairing the water loop, the crew also checks the systems that depend on it."
 ],
 "bed_med": [
  "Medical examination bed",
  "The doctor listens to how you feel and checks you when needed.",
  "A medical assessment combines symptoms, observations, and measurements. Looking at a screen alone does not establish a diagnosis."
 ],
 "vitals": [
  "Health-reading monitor",
  "Sensors measure pulse, blood oxygen, and temperature. The doctor explains the readings.",
  "A reading can be incomplete or affected by the sensor. The doctor checks that it makes sense and considers other information before deciding what it means."
 ],
 "kit": [
  "Medical kit",
  "Medical supplies are organized here. Only the medical team chooses how medicines are used.",
  "Spaceflight medical kits include materials for assessment and treatment. In this educational game, clinical decisions remain with the flight doctor."
 ],
 "samples": [
  "Rock-sample shelves",
  "Every sample has a label so its place of origin is remembered.",
  "A rock's location and surrounding conditions help scientists interpret it. Careful documentation preserves clues when samples move from the surface to the laboratory."
 ],
 "analyzer": [
  "Rock-analysis instrument",
  "We check this instrument against a known reference before trusting a new reading.",
  "Calibration compares an instrument with a reference. The matching-number activity demonstrates this idea; it does not represent a specific real lunar instrument."
 ],
 "sleep": [
  "Crew bed and rest controls",
  "Rest helps us think clearly. We keep light and noise comfortable for sleepers.",
  "Sleep supports health, attention, and wellbeing. Lighting, schedules, noise, and the habitat environment can affect rest."
 ],
 "exercise": [
  "Crew exercise equipment",
  "Resistance and cycling help care for our muscles, bones, and heart.",
  "The Moon has roughly one-sixth of Earth's gravity, not weightlessness. The flight doctor plans suitable exercise; our short activity summarizes a longer session."
 ],
 "hygiene": [
  "Hygiene and waste system",
  "Waste stays safely contained. Some water goes through treatment before being reused.",
  "Containing waste helps protect a closed habitat. Water recovery needs treatment and quality checks; waste does not become drinking water directly."
 ],
 "vent": [
  "Sleeping-room air vent",
  "A clear vent lets the fan move air around the sleeping room.",
  "A blocked opening reduces airflow. The activity first checks a sensor, then clears three vent sections and aims the fan. The final reading checks that circulation improved; a separate scrubber removes carbon dioxide."
 ],
 "rover": [
  "Parked support rover",
  "Its wheel guard helps keep thrown-up dust away from equipment and the crew.",
  "The rover stays parked during the repair. The player chooses a sheet, suitable tape, and clamps, then checks that the patch stays secure and does not rub the wheel."
 ],
 "rock": [
  "Field-sample station",
  "Record a rock's texture and location before moving the measuring instrument.",
  "Pressing a record card represents writing that observation in the field log. Keeping the same kinds of records allows scientists to compare observations from different days."
 ]
}

static func item(id: String, room: String, title: String, description: String, source: String, art: int) -> Dictionary:
 return {"id":id,"room":room,"title":ENGLISH_ITEMS[id][0],"description":ENGLISH_ITEMS[id][1],"source":SOURCES[source],"art":art}

static func find_item(id: String) -> Dictionary:
 for entry in items():
  if entry.id == id: return entry
 return {}

static func extra_items() -> Array:
 return [
  item("vent","bedroom","Sleeping-room air vent","A clear vent lets the fan move air around the sleeping room.","air",24),
  item("rover","exterior","Parked support rover","Its wheel guard helps keep thrown-up dust away from equipment and the crew.","dust",23),
  item("rock","exterior","Field-sample station","Record a rock's texture and location before moving the measuring instrument.","rocks",26)
 ]
