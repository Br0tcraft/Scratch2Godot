@tool
extends Window

var settings: ScratchSettings = null
var project: ScratchProjectModel

var cloud_settings_menu_scene = preload("res://addons/scratch_converter/ui/cloud_variable_menu.tscn")

@onready var bind_properties = {
	%CLONES: "infinite_clones",
	%CLOSE: "close_window_when_project_stops",
	%START: "start_project_automatically",
	%FLAG: "show_green_flag",
	%STOP: "show_stop_button",
	%EDITABLE: "editable_lists",
	%DELETE: "delete_temporary_folders_after_conversion",
	%LOG: "log_conversion_process",
	%CONTINUE: "continue_on_error",
	%OVERWRITE: "overwrite_existing_scenes",
	
	# Colors
	%BACKGROUND: "background_color",
	%ACCENT: "accent_color",
	%VARIABLE: "variable_color",
	%LIST: "list_color",
	
	# LineEdits
	%HOST: "cloud_variable_server_url",
	%ID: "project_id"
}


func _ready() -> void:
	if not Engine.is_editor_hint():
		queue_free()
		return
	settings = ScratchSettings.new()
	_setup_dropdowns()
	%OPTIONS.hide()
	
	close_requested.connect(func(): queue_free())

	%FILE.pressed.connect(func(): %OPEN_PROJECT.popup())
	%OPEN_PROJECT.file_selected.connect(_on_file_selected)

	%EXPORT.pressed.connect(%EXPORT_SETTINGS.popup)
	%EXPORT_SETTINGS.file_selected.connect(settings.export_settings)

	%IMPORT.pressed.connect(%IMPORT_SETTINGS.popup)
	%IMPORT_SETTINGS.file_selected.connect(import_settings)

	%RESET.pressed.connect(func(): settings = ScratchSettings.new()) # ToDo: evtl a popup that asks if you are sure that you want to reset
	
	%TRANSPILE.pressed.connect(_on_transpile_pressed)

	for node in bind_properties:
		var prop_name = bind_properties[node]
		if node is CheckButton or node is CheckBox:
			node.toggled.connect(func(val: bool): settings.set(prop_name, val))

		elif node is ColorPickerButton:
			node.color_changed.connect(func(val: Color): settings.set(prop_name, val))

		elif node is LineEdit:
			node.text_changed.connect(func(val: String): settings.set(prop_name, val))


	%SIZE_X.value_changed.connect(func(val): settings.screen_dimensions.x = val)
	%SIZE_Y.value_changed.connect(func(val): settings.screen_dimensions.y = val)
	%SCREEN.item_selected.connect(func(val): settings.screen_dimension_mode = val)
	%CLOUD_MODE.item_selected.connect(_on_cloud_mode_selected)
	update_ui()

func update_ui() -> void:
	if not settings: return
	for node in bind_properties:
		var prop_name = bind_properties[node]
		var value = settings.get(prop_name)
		
		if node is CheckButton or node is CheckBox:
			node.button_pressed = value

		elif node is ColorPickerButton:
			node.color = value

		elif node is LineEdit:
			node.text = value
	
	%SIZE_X.value = settings.screen_dimensions.x
	%SIZE_Y.value = settings.screen_dimensions.y
	%SCREEN.selected = settings.screen_dimension_mode
	%CLOUD_MODE.selected = settings.cloud_variable_mode
	_on_cloud_mode_selected(%CLOUD_MODE.selected)


func _setup_dropdowns() -> void:
	%SCREEN.clear()
	%SCREEN.add_item("Preserve aspect ratio when resized (recommended)", settings.ScreenDimensionsMode.PRESERVE)
	%SCREEN.add_item("Stretch stage to fill screen without changing actual size", settings.ScreenDimensionsMode.STRETCH)
	%SCREEN.add_item("Dynamically resize size to match window size (experimental)", settings.ScreenDimensionsMode.RESIZE)
	%CLOUD_MODE.clear()
	%CLOUD_MODE.add_item("Connect to cloud variable server", settings.CloudVariableMode.SERVER)
	%CLOUD_MODE.add_item("Store in local storage", settings.CloudVariableMode.CLIENT)
	%CLOUD_MODE.add_item("Ignore", settings.CloudVariableMode.IGNORE)
	%CLOUD_MODE.add_item("Advanced", settings.CloudVariableMode.ADVANCED)
	%LOG_LEVEL.clear()
	%LOG_LEVEL.add_item("Silent", ScratchLog.Level.SILENT)
	%LOG_LEVEL.add_item("Warn", ScratchLog.Level.WARN)
	%LOG_LEVEL.add_item("Verbose", ScratchLog.Level.VERBOSE)


func import_settings(path: String) -> void:
	var loaded = ScratchSettings.load_settings(path)
	if loaded:
		settings = loaded
		update_ui()


func _on_cloud_mode_selected(mode: int) -> void:
	settings.cloud_variable_mode = mode
	if mode == ScratchSettings.CloudVariableMode.ADVANCED:
		%ADVANCED.show()
	else:
		%ADVANCED.hide()
	
func _on_file_selected(path: String) -> void:
	project = ScratchProjectModel.new()
	var error := project.load(path)
	if error != ScratchProjectModel.Error.OK:
		print("Invalid Scratch project file selected: %s" % ScratchProjectModel.Error.keys()[error] + " (file: %s)" % path)
		queue_free()
		return

	%OPTIONS.show()
	for variable in project.stage.get_cloud_vars():
		var cloud_menu = cloud_settings_menu_scene.instantiate()
		cloud_menu.use(variable)
		%ADVANCED.add_child(cloud_menu)

	var file_name = path.get_file().replace(".sb3", "")
	%NAME.text = file_name
	project.name = file_name

func _on_transpile_pressed() -> void:
	if project == null:
		push_warning("No project loaded.")
		return
	if settings == null:
		push_warning("No settings configured.")
		return

	var transpiler := ProjectTranspiler.new()
	transpiler.set_settings(settings)
	transpiler.set_project(project)
	
	if project.name.strip_edges() == "":
		project.name = "myProject"

	var err := transpiler.transpile()
	match err:
		OK:
			print("[ScratchConverter] Transpilation complete.")
			EditorInterface.get_resource_filesystem().scan()
			var root_scene := settings.scratch_scene_output_path.path_join(project.name + ".tscn")
			if FileAccess.file_exists(root_scene):
				EditorInterface.open_scene_from_path(root_scene)
		ERR_INVALID_DATA:
			push_error("[ScratchConverter] Transpilation failed with validation errors. Check the console.")
		_:
			push_error("[ScratchConverter] Transpilation failed: " + error_string(err))

func _process(delta: float) -> void:
	pass