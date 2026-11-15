extends Control
## The repository root remains importable; F5 launches the canonical project.
## Each project keeps its own res:// root, resource imports and autoloads.
var importer_pid := -1
var status: Label
var project_path := ""
var testing := false

func _ready() -> void:
 Sound.shutdown()
 testing = "--launcher-test" in OS.get_cmdline_user_args()
 var background := ColorRect.new()
 background.color = Color("0b1829")
 background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
 add_child(background)
 var box := VBoxContainer.new()
 box.position = Vector2(90, 210)
 box.size = Vector2(1100, 300)
 box.add_theme_constant_override("separation", 24)
 add_child(box)
 var title := Label.new()
 title.text = "MISSION KILLA WASI · THREE-DAY CAMPAIGN"
 title.add_theme_font_size_override("font_size", 30)
 box.add_child(title)
 status = Label.new()
 status.text = "Preparing your lunar adventure…\nThe first import may take a few moments."
 status.add_theme_font_size_override("font_size", 22)
 box.add_child(status)
 project_path = ProjectSettings.globalize_path("res://mision-killa-wasi")
 if not FileAccess.file_exists(project_path.path_join("project.godot")):
  fail("Could not find mision-killa-wasi/project.godot beside this launcher.")
  return
 importer_pid = OS.create_process(OS.get_executable_path(), PackedStringArray([
  "--headless", "--editor", "--path", project_path, "--import", "--quit"
 ]))
 if importer_pid < 0: fail("Could not start Godot to import the campaign.")

func _process(_delta: float) -> void:
 if importer_pid < 0 or OS.is_process_running(importer_pid): return
 importer_pid = -1
 var args := PackedStringArray(["--path", project_path])
 if testing:
  args.append_array(PackedStringArray([
   "--headless", "--log-file", project_path.path_join("artifacts/launcher_child.log"),
   "--", "--daily-test"
  ]))
 var child := OS.create_process(OS.get_executable_path(), args)
 if child < 0:
  fail("Could not start the campaign. Import mision-killa-wasi/project.godot directly.")
  return
 print("CAMPAIGN_LAUNCHER: opened ", project_path, "; pid=", child)
 get_tree().quit()

func fail(message: String) -> void:
 importer_pid = -1
 status.text = message
 push_error(message)
 if testing: get_tree().quit(1)
