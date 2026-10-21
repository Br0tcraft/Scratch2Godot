@tool
class_name ScratchListMonitor
extends PanelContainer
signal item_edited(index: int, text: String)
@onready var list_item = preload("res://addons/scratch_converter/core/runtime/monitor/list_item.tscn")
@export var editable := true
@export var accent_color := Color(1, 0.4, 1, 0.2)

@export var list_name: String = "List Name":
	set(value):
		list_name = value
		if is_node_ready():
			%ListTitle.text = list_name
			update_list(default_values)

@export_tool_button("Update Values", "ReloadSmall") var generate = func(): update_list(default_values)

@export var default_values: Array[String] = []

const MAX_ROWS := 100

func _ready() -> void:
	%ListTitle.text = list_name
	update_list(default_values)


func update_list(list_values: Array[Variant]) -> void:
	var items_count := list_values.size()
	var children := %ListItems.get_children()
	var items_visible := children.size()
	%FooterLength.text = "length %s" % items_count
	for i in range(items_count):
		if i < items_visible:
			children[i].item_text = S.str(list_values[i])
		else:
			var item: ScratchListItem = list_item.instantiate()
			item.item_text = S.str(list_values[i])
			item.index = i + 1
			%ListItems.add_child(item)
	for i in range(items_count, items_visible):
		children[i].queue_free()
