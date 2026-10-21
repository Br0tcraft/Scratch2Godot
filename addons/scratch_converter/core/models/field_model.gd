class_name ScratchFieldModel
extends RefCounted

var value: String = ""
var id: String = ""


func load_from_array(field_array: Array) -> void:
	if field_array.is_empty():
		return
	
	value = str(field_array[0])
	if field_array.size() > 1 and field_array[1] != null:
		id = str(field_array[1])
	ScratchLog.v("[FIELD] " + value)
	ScratchLog.v("\t- Id: " + id)