@tool
class_name ScratchListItem
extends HBoxContainer

@export var index: int = 1:
	set(value):
		index = value
		if is_node_ready():
			%Index.text = str(value)

@export var item_text: String = "":
	set(value):
		item_text = value
		if is_node_ready():
			%ItemText.text = value

func _ready() -> void:
	%Index.text = str(index)
	%ItemText.text = item_text