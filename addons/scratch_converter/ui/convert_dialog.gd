@tool
extends Control

#export button to set icons
@export_tool_button("set_icons", "EditorIcons") var icons = set_icons

#export szene/window for importing/adding projects
#@export var import_window: PackedScene = preload("res://addons/scratch_converter/TranspileWindow.tscn")
var window


func _ready() -> void:
	if not Engine.is_editor_hint():
		queue_free()
		return
	%ADD.pressed.connect(_on_Add_pressed)
	%Button.pressed.connect(remove)


func _process(delta: float) -> void:
	pass


func set_icons():
	var editor_theme: Theme = EditorInterface.get_editor_theme()
	$"VBoxContainer/HBoxContainer/Add".add_theme_icon_override("icon", editor_theme.get_icon("Add", "EditorIcons"))
	$"VBoxContainer/HBoxContainer/Settings".add_theme_icon_override("icon", editor_theme.get_icon("Sort", "EditorIcons"))


func _on_Add_pressed() -> void:
	window = load("res://addons/scratch_converter/ui/transpile_window.tscn").instantiate()
	get_tree().get_root().add_child(window)
	window.popup_centered()

func remove():
	window.queue_free()
	window = null
