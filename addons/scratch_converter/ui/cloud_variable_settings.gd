@tool
extends Control

func _ready() -> void:
	if not Engine.is_editor_hint():
		queue_free()
		return
	%MODE.clear()
	%MODE.add_item("Connect to cloud variable Server", ScratchVariableModel.VariableTypes.CLOUD)
	%MODE.add_item("Store in local Storage", ScratchVariableModel.VariableTypes.STORAGE)
	%MODE.add_item("Ignore", ScratchVariableModel.VariableTypes.NORMAL)


func use(variable: ScratchVariableModel) -> void:
	%MODE.selected = variable.type
	%MODE.item_selected.connect(func(mode: int): variable.type = mode)
	%VARIABLE.text = variable.name
	if not variable.name.contains("☁"):
		%VARIABLE.text = "☁ " + variable.name
