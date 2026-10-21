class_name ScratchProject
extends Control

@export_group("Runtime")
@export var start_project_automatically: bool = false
@export var close_window_when_project_stops: bool = false
@export var infinite_clones: bool = false

@export_group("Player UI")
@export var show_green_flag: bool = true
@export var show_stop_button: bool = true
@export var background_color: Color = Color.BLACK
@export var accent_color: Color = Color(1.0, 0.3, 0.3)
@export var variable_color: Color = Color(1.0, 0.5, 0.1)
@export var list_color: Color = Color(1.0, 0.4, 1.0, 0.2)
@export var editable_lists: bool = true
@export var stage_color: Color = Color.WHITE
@export var monitor_scale: float = 1.0
@export var log_level: ScratchLog.Level = ScratchLog.Level.WARN
@export var max_clones: int = 300

@export_group("Cloud")
@export var cloud_variable_mode: ScratchSettings.CloudVariableMode = ScratchSettings.CloudVariableMode.SERVER
@export var cloud_variable_server_url: String = "wss://clouddata.turbowarp.org"
@export var project_id: String = ""
@export var advanced_cloud_variable_settings: Dictionary = {}
@export var cloud_sync_debounce_ms: int = 100

@export_group("Stage")
@export var screen_dimensions: Vector2 = Vector2(480, 360)
@export var screen_dimension_mode: ScratchSettings.ScreenDimensionsMode = ScratchSettings.ScreenDimensionsMode.PRESERVE

var clone_count: int = 0
var _cloud: CloudManager
var _sprites: Array[ScratchSprite] = []
var _sub_viewport: SubViewport
var monitors: MonitorManager


func _ready() -> void:
	ScratchLog.level = log_level
	_sub_viewport = find_child("SubViewport", true, false) as SubViewport
	_setup_ui()
	_collect_sprites(self if _sub_viewport == null else _sub_viewport)
	_setup_cloud()

	monitors = MonitorManager.new()
	monitors.variable_color = variable_color
	monitors.list_color = list_color
	monitors.editable_lists = editable_lists
	monitors.monitor_scale = monitor_scale
	(_sub_viewport if _sub_viewport else self).add_child(monitors)
	for s in _sprites:
		if not s.is_clone: s._register_monitors()
	if start_project_automatically:
		_green_flag.call_deferred()
	

func _setup_ui() -> void:
	var bg := find_child("Background", true, false) as ColorRect
	if bg:
		bg.color = background_color
	var stage_canvas := find_child("ColorRect", true, false) as ColorRect
	if stage_canvas:
		stage_canvas.color = stage_color

	var flag_btn := find_child("GreenFlagButton", true, false) as Button
	if flag_btn:
		flag_btn.pressed.connect(_on_green_flag_pressed)

	var stop_btn := find_child("StopButton", true, false) as Button
	if stop_btn:
		stop_btn.pressed.connect(_on_stop_pressed)


func _setup_cloud() -> void:
	_cloud = CloudManager.new()
	_cloud.name = "CloudManager"
	_cloud.debounce_ms = cloud_sync_debounce_ms
	_cloud.bind_stage(get_stage())
	add_child(_cloud)
	_cloud.configure(
		cloud_variable_mode,
		cloud_variable_server_url,
		project_id if not project_id.is_empty() else str(name.hash()),
		advanced_cloud_variable_settings,
	)


func _collect_sprites(node: Node) -> void:
	if node is ScratchSprite and not _sprites.has(node):
		_sprites.append(node)
	for child in node.get_children():
		_collect_sprites(child)


func get_stage() -> ScratchSprite:
	var sv := _sub_viewport
	if sv == null:
		sv = find_child("SubViewport", true, false) as SubViewport
	if sv:
		return sv.get_node_or_null("Stage") as ScratchSprite
	return get_node_or_null("Stage") as ScratchSprite


func get_sprites() -> Array[ScratchSprite]:
	return _sprites


func _on_green_flag_pressed() -> void:
	_green_flag()


func _on_stop_pressed() -> void:
	stop_all_project_scripts()


func stage_size() -> Vector2:
	if screen_dimension_mode == ScratchSettings.ScreenDimensionsMode.RESIZE and _sub_viewport:
		return Vector2(_sub_viewport.size)
	return screen_dimensions

func _green_flag() -> void:
	ScratchLog.v("Green flag clicked")
	_reset_scripts()
	for s in _sprites.duplicate():
		s.trigger_hats(ScratchSprite.Trigger.GREEN_FLAG)


func stop_all_project_scripts() -> void:
	_reset_scripts()
	clone_count = 0
	if close_window_when_project_stops:
		var w := get_window()
		if w and w != get_tree().root:
			w.hide()
		else:
			queue_free()

func _reset_scripts() -> void:
	for s in _sprites.duplicate():
		s.stop_all_scripts()
		if s.is_clone: s._remove_clone()
	clone_count = 0

func broadcast(bc_name: String) -> void:
	for s in _sprites.duplicate():
		s.trigger_hats(ScratchSprite.Trigger.BROADCAST, bc_name)

func cloud_set(var_name: String, value: Variant) -> void:
	if _cloud:
		_cloud.cloud_set(var_name, value)

func register_sprite(s: ScratchSprite) -> void:
	if not _sprites.has(s): _sprites.append(s)

func unregister_sprite(s: ScratchSprite) -> void:
	_sprites.erase(s)

var _clone_serial := 0
func next_clone_id() -> int:
	_clone_serial += 1
	return _clone_serial

func cloud_mark_dirty(n: String) -> void:
	if _cloud: _cloud.mark_dirty(n)