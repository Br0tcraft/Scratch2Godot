@tool
extends EditorPlugin

var dock


const CLOUD_MANAGER_SINGELTON = "CloudManager"
const CLOUD_MANAGER_SINGELTON_PATH = "res://addons/scratch_converter/core/autoloads/cloud_manager.gd"

func _enable_plugin() -> void:
	if not Engine.has_singleton(CLOUD_MANAGER_SINGELTON):
		add_autoload_singleton(CLOUD_MANAGER_SINGELTON, CLOUD_MANAGER_SINGELTON_PATH)

func _disable_plugin() -> void:
	if Engine.has_singleton(CLOUD_MANAGER_SINGELTON):
		remove_autoload_singleton(CLOUD_MANAGER_SINGELTON)

func _enter_tree():
	load_dock()

func load_dock() -> void:
	if dock:
		remove_dock(dock)
	dock = EditorDock.new()
	var dock_scene = load("res://addons/scratch_converter/ui/convert_dialog.tscn").instantiate()
	dock.add_child(dock_scene)

	dock.title = "Scratch Converter"

	dock.default_slot = DOCK_SLOT_LEFT_UL

	dock.available_layouts = EditorDock.DOCK_LAYOUT_VERTICAL | EditorDock.DOCK_LAYOUT_FLOATING
	add_dock(dock)

func _exit_tree():
	remove_dock(dock)
	dock.queue_free()