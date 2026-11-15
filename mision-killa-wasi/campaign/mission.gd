extends Node
signal changed
signal emergency_started(kind: String)
signal rescue_requested(kind: String)
const Story = preload("res://campaign/story.gd")
const Catalog = preload("res://campaign/catalog.gd")
var active := false
var step := 0
var room := "exterior"
var position := Vector2(960, 545)
var priority := ""
var choices: Dictionary = {}
var completed: Array = []
var visited: Array = []
var rescues: Array = []
var inventory := {"filtro_aire":0,"cartucho_agua":1,"agua_reserva":3,"repuesto_reserva":2,"muestras":0,"registros":0}
var emergency := ""
var remaining := 0.0
var locks := 0
var transition := false
var focused := true
var reduced_motion := false
var settings := {"music":0.55,"effects":0.65,"voice":0.4,"reduced_motion":false}
var optional: Dictionary = {}
var help_level: Dictionary = {}
var characters: Dictionary = {}
var save_path := "user://campaign_v1.json"
var test_mode := false
var save_error := ""
var play_seconds := 0.0

func _ready() -> void:
 test_mode = "--campaign-test" in OS.get_cmdline_user_args() or "--keyboard-tour" in OS.get_cmdline_user_args() or "--presentation-test" in OS.get_cmdline_user_args()
 if test_mode: save_path = "user://test_campaign_v1.json"
 var cfg := ConfigFile.new()
 if cfg.load("user://settings.cfg") == OK:
  for key in settings: settings[key] = cfg.get_value("options",key,settings[key])
 reduced_motion = bool(settings.reduced_motion)

func _notification(what: int) -> void:
 if what == NOTIFICATION_APPLICATION_FOCUS_OUT: focused = false
 if what == NOTIFICATION_APPLICATION_FOCUS_IN: focused = true

func movable() -> bool:
 return active and locks == 0 and not transition and focused

func _process(delta: float) -> void:
 if not movable(): return
 play_seconds += delta
 tick(delta)

func tick(delta: float) -> void:
 if emergency.is_empty() or not movable() or optional.get("emergency_brief_pending",false): return
 remaining = maxf(0, remaining - delta)
 if remaining <= 0: rescue()

func current() -> Dictionary:
 return Story.resolved_task(step, priority)

func day() -> int:
 return int(current().get("day",3))

func reset() -> void:
 active = true
 step = 0
 room = "exterior"
 position = Vector2(960,545)
 priority = ""
 choices.clear()
 completed.clear()
 visited.clear()
 rescues.clear()
 optional.clear()
 help_level.clear()
 characters.clear()
 inventory = {"filtro_aire":0,"cartucho_agua":1,"agua_reserva":3,"repuesto_reserva":2,"muestras":0,"registros":0}
 emergency = ""
 remaining = 0
 locks = 0
 transition = false
 play_seconds = 0
 changed.emit()

func start_emergency(kind: String, seconds: float) -> void:
 if not emergency.is_empty(): return
 emergency = kind
 remaining = seconds
 optional.emergency_brief_pending=true
 emergency_started.emit(kind)

func complete(answer: int) -> bool:
 var t := current()
 if t.is_empty() or t.id in completed: return false
 if answer < 0 or answer >= t.choices.size(): return false
 if int(t.correct) >= 0 and answer != int(t.correct): return false
 var id: String = t.id
 choices[id] = answer
 completed.append(id)
 match id:
  "priority": priority = "storage" if answer == 0 else "lab"
  "prepare":
   if priority == "storage": inventory.filtro_aire += 1
   else: optional.calibrated = true
  "air_on":
   emergency = ""
   remaining = 0
  "rover_test":
   emergency = ""
   remaining = 0
  "sample2":
   inventory.muestras += 1
   inventory.registros += 1
  "sample_lab":
   optional.calibrated = true
   inventory.registros += 1
  "water_choice":
   if answer == 0: inventory.agua_reserva -= 1
   else: optional.irrigation_paused = true
  "water_filter": inventory.cartucho_agua -= 1
  "restore_crops": optional.irrigation_paused = false
  "survey3": inventory.registros += 1
  "solar_choice":
   if answer == 1:
    remaining = maxf(1.0,remaining - 30.0)
    optional.solar_bag = true
   else: optional.solar_bag = false
  "shelter_all":
   emergency = ""
   remaining = 0
   if optional.get("solar_bag",false): inventory.muestras += 1
 step += 1
 match id:
  "bedtime": start_emergency("air",90)
  "rover_notice": start_emergency("rover",60)
  "survey3": start_emergency("solar",180)
 save_game()
 changed.emit()
 return true

func rescue() -> void:
 if emergency.is_empty(): return
 var kind := emergency
 optional.emergency_brief_pending=false
 rescues.append(kind)
 emergency = ""
 remaining = 0
 var next_id := "day1_report"
 match kind:
  "air": inventory.repuesto_reserva = maxi(0,inventory.repuesto_reserva-1)
  "rover":
   next_id = "sample2"
   inventory.repuesto_reserva = maxi(0,inventory.repuesto_reserva-1)
   optional.sample_cancelled = true
  "solar":
   next_id = "dose_check"
   room = "shelter"
   position = Vector2(640,450)
   inventory.agua_reserva = maxi(0,inventory.agua_reserva-1)
   optional.solar_bag = false
 while step < Story.tasks().size() and current().id != next_id:
  completed.append(current().id)
  step += 1
 save_game()
 changed.emit()
 rescue_requested.emit(kind)

func optional_action(id: String) -> bool:
 if optional.get(id,false): return false
 if id == "extra_sample":
  if day()!=2 or optional.get("sample_cancelled",false) or not emergency.is_empty() or not "sample2" in completed: return false
  inventory.muestras += 1
  inventory.registros += 1
 elif id == "storage_later":
  if priority != "lab" or not "prepare" in completed: return false
  inventory.filtro_aire += 1
 elif id == "lab_later":
  if priority != "storage" or not "prepare" in completed: return false
  optional.calibrated = true
 else: return false
 optional[id] = true
 save_game()
 changed.emit()
 return true

func can_exit() -> bool:
 return ("prebreathe" in completed and day()==2) or ("eva3" in completed and day()==3) or current().is_empty()

func snapshot() -> Dictionary:
 return {"version":1,"step":step,"room":room,"position":[position.x,position.y],"priority":priority,"choices":choices,"completed":completed,"visited":visited,"rescues":rescues,"inventory":inventory,"emergency":emergency,"remaining":remaining,"optional":optional,"help_level":help_level,"characters":characters,"play_seconds":play_seconds}

func save_game() -> bool:
 if not active: return false
 var file := FileAccess.open(save_path+".tmp",FileAccess.WRITE)
 if file == null:
  save_error = "No se pudo guardar. Revisa el espacio disponible."
  return false
 file.store_string(JSON.stringify(snapshot(),"\t"))
 file.flush()
 file.close()
 if FileAccess.file_exists(save_path):
  var previous:=JSON.new()
  if previous.parse(FileAccess.get_file_as_string(save_path))==OK and valid_save(previous.data):
   if DirAccess.copy_absolute(save_path,save_path+".bak")!=OK:
    save_error="No se pudo crear la copia de respaldo; se conserva el guardado anterior."
    return false
 var error := DirAccess.rename_absolute(save_path+".tmp",save_path)
 save_error = "" if error == OK else "No se pudo actualizar el guardado; se conserva la copia anterior."
 return error == OK

func load_game(backup := false) -> bool:
 var path := save_path + (".bak" if backup else "")
 if not FileAccess.file_exists(path): return false
 var parser:=JSON.new()
 if parser.parse(FileAccess.get_file_as_string(path))!=OK: return false
 var data = parser.data
 if not valid_save(data): return false
 step = int(data.step)
 room = data.room
 position = Vector2(float(data.position[0]),float(data.position[1]))
 priority = data.priority
 choices = data.choices
 completed = data.completed
 visited = data.visited
 rescues = data.rescues
 inventory = data.inventory
 emergency = data.emergency
 remaining = float(data.remaining)
 optional = data.optional
 help_level = data.help_level
 characters = data.get("characters",{})
 play_seconds = float(data.get("play_seconds",0))
 locks = 0
 transition = false
 active = true
 changed.emit()
 return true

func valid_save(data: Variant) -> bool:
 if not data is Dictionary: return false
 if data.has("characters") and not data.characters is Dictionary: return false
 for key in ["version","step","room","position","priority","choices","completed","visited","rescues","inventory","emergency","remaining","optional","help_level"]:
  if not data.has(key): return false
 if data.version != 1 or not data.step is float and not data.step is int: return false
 if data.step < 0 or data.step > Story.tasks().size() or not Catalog.ROOMS.has(data.room): return false
 if not data.position is Array or data.position.size()!=2: return false
 for n in data.position:
  if not (n is float or n is int) or not is_finite(float(n)): return false
 if not data.priority in ["","storage","lab"] or not data.emergency in ["","air","rover","solar"]: return false
 if not (data.remaining is float or data.remaining is int) or data.remaining < 0 or data.remaining > 180: return false
 if not is_finite(float(data.remaining)): return false
 for key in ["choices","inventory","optional","help_level"]:
  if not data[key] is Dictionary: return false
 for key in ["completed","visited","rescues"]:
  if not data[key] is Array: return false
 for person in data.get("characters",{}).values():
  if not person is Dictionary or not person.get("position",null) is Array: return false
  if person.position.size()!=2 or not Catalog.ROOMS.has(person.get("room","")): return false
  for n in person.position:
   if not (n is float or n is int) or not is_finite(float(n)): return false
 var seconds=data.get("play_seconds",0)
 if not (seconds is float or seconds is int) or not is_finite(float(seconds)) or seconds<0: return false
 for key in data.choices:
  if not (data.choices[key] is float or data.choices[key] is int): return false
 for value in data.help_level.values():
  if not (value is float or value is int): return false
 for key in ["completed","visited","rescues"]:
  for value in data[key]:
   if not value is String: return false
 for key in inventory:
  if not data.inventory.has(key) or not (data.inventory[key] is float or data.inventory[key] is int) or data.inventory[key] < 0: return false
 return true

func save_settings() -> void:
 settings.reduced_motion = reduced_motion
 var cfg := ConfigFile.new()
 for key in settings: cfg.set_value("options",key,settings[key])
 if not test_mode: cfg.save("user://settings.cfg")

func report() -> String:
 var preparation := "Sin decidir" if priority.is_empty() else ("Almacén" if priority == "storage" else "Laboratorio")
 var water := "Todavía sin decidir"
 if choices.has("water_choice"): water="1 reserva utilizada" if choices.water_choice==0 else "Riego pausado y después comprobado"
 var solar:="Todavía sin alerta solar"
 if choices.has("solar_choice"): solar="Muestras abandonadas: retorno inmediato" if choices.solar_choice==0 else "Bolsa recogida: 30 s invertidos"
 if "solar" in rescues: solar="Retorno asistido: bolsa perdida y 1 reserva utilizada"
 var help:="Ninguna intervención de rescate"
 if not rescues.is_empty():
  var names:={"air":"Ventilación: ingeniero + 1 repuesto","rover":"Rover: equipo + 1 repuesto, muestra extra cancelada","solar":"Alerta solar: retorno asistido"}
  help=""
  for kind in rescues: help+=names[kind]+"\n"
 var menu:="Sin organizar"
 if choices.has("meal"): menu="Suave; especias opcionales" if choices.meal==0 else "Sazonado; alternativa suave"
 return "Preparación inicial: %s\nComida: %s\nAgua: %s\nAlerta solar: %s\n\nRegistros científicos: %d · Muestras conservadas: %d\nAgua de reserva: %d · Repuestos de reserva: %d\nFiltros de aire: %d · Cartuchos de agua: %d\n\n%s\nSistemas consultados: %d / 26\n\nAprendizajes: escuchar, comprobar, cuidar los recursos y poner a las personas primero." % [preparation,menu,water,solar,inventory.registros,inventory.muestras,inventory.agua_reserva,inventory.repuesto_reserva,inventory.filtro_aire,inventory.cartucho_agua,help,visited.size()]

func item_state(id: String) -> String:
 match id:
  "vent","atmosphere":
   if emergency=="air": return "FLUJO BAJO · CO₂ SUBIENDO"
   if "air_on" in completed: return "FLUJO RECUPERADO · CO₂ BAJANDO"
  "water","filter":
   if "water_test" in completed: return "AGUA COMPROBADA · CARTUCHO NUEVO"
   if "water_read" in completed: return "MANTENIMIENTO · CARTUCHO SATURADO"
  "irrigation":
   if optional.get("irrigation_paused",false): return "RIEGO EN PAUSA · RESERVA CONSERVADA"
   if "restore_crops" in completed: return "RIEGO RESTABLECIDO"
  "rover":
   if "rover" in rescues: return "REPARACIÓN ASISTIDA · MUESTRA EXTRA CANCELADA"
   if "rover_test" in completed: return "PARCHE COMPROBADO · ROVER ESTACIONADO"
   if emergency=="rover": return "GUARDABARROS DAÑADO"
  "shield","dose":
   if emergency=="solar": return "ALERTA SOLAR · EQUIPO EN RETORNO"
   if "shelter_all" in completed and not "wait_control" in completed: return "CINCO TRIPULANTES EN EL REFUGIO"
   if "wait_control" in completed: return "CONTROL CONFIRMA FIN DE LA ALERTA"
  "spares": return "FILTROS DE AIRE LOCALIZADOS: %d" % inventory.filtro_aire
  "analyzer": return "CALIBRADO" if optional.get("calibrated",false) else "CALIBRACIÓN PENDIENTE"
  "food":
   if choices.has("meal"): return "MENÚ SUAVE · CONDIMENTOS APARTE" if choices.meal==0 else "MENÚ SAZONADO · OPCIÓN SUAVE"
 return "DISPONIBLE PARA CONSULTA"

func remember_character(id: String, at: Vector2, location: String, activity: String) -> void:
 characters[id]={"position":[at.x,at.y],"room":location,"activity":activity}
