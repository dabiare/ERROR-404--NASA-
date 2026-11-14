extends Node
## Mission state; UI and physics never award progress themselves.
signal changed
enum Stage { MENU, LANDING, ENTRY, COMMUNICATIONS, CHOICE, TASK, REPORT, EXPLORE }
var stage: Stage = Stage.MENU
var choice := ""
var inspected: Array[String] = []
var presented: Array[String] = []
var lab_power := false
var filters := 0
var records := 0
var reduced_motion := false
var volume := 0.65
var modal := false
var paused := false
var transition := false

func reset() -> void:
	stage = Stage.MENU
	choice = ""
	inspected.clear()
	presented.clear()
	lab_power = false
	filters = 0
	records = 0
	modal = false
	paused = false
	transition = false
	changed.emit()

func advance(expected: Stage, next: Stage) -> bool:
	if stage != expected:
		return false
	stage = next
	changed.emit()
	return true

func select_priority(value: String) -> bool:
	if stage != Stage.CHOICE or value not in ["storage", "lab"] or not choice.is_empty():
		return false
	choice = value
	stage = Stage.TASK
	changed.emit()
	return true

func inspect_shelf(id: String) -> bool:
	if stage != Stage.TASK or choice != "storage" or id not in ["shelf_a", "shelf_b"] or id in inspected:
		return false
	inspected.append(id)
	if inspected.size() == 2:
		filters = 1
		stage = Stage.REPORT
	changed.emit()
	return true

func power_lab() -> bool:
	if stage != Stage.TASK or choice != "lab" or lab_power:
		return false
	lab_power = true
	changed.emit()
	return true

func register_sample() -> bool:
	if stage != Stage.TASK or choice != "lab" or not lab_power:
		return false
	records = 1
	stage = Stage.REPORT
	changed.emit()
	return true

func can_move() -> bool:
	return not (modal or paused or transition) and stage in [Stage.ENTRY, Stage.COMMUNICATIONS, Stage.CHOICE, Stage.TASK, Stage.EXPLORE]

func objective() -> String:
	match stage:
		Stage.ENTRY: return "Entra en la base lunar"
		Stage.COMMUNICATIONS: return "Contacta al equipo desde la radio"
		Stage.CHOICE: return "Elige tu primera prioridad en mando"
		Stage.TASK:
			if choice == "storage": return "Revisa los dos estantes · %d/2" % inspected.size()
			return "Registra la muestra de calibración" if lab_power else "Enciende la consola del laboratorio"
		Stage.REPORT: return "Revisa tu primer informe"
		Stage.EXPLORE: return "Conoce la base y conversa con tu equipo"
	return "Comienza tu misión lunar"
