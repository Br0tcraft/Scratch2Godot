class_name ScratchListModel
extends RefCounted

var name: String = ""
var id: String = ""
var value: Array[Variant] = []

func load_from_dict(data: Dictionary) -> void:
    name = data.get("name", "")
    id = data.get("id", "")
    value = data.get("value", [])
    ScratchLog.v("[LIST]" + str(name))
    ScratchLog.v("\t- Id: " + str(id))
    ScratchLog.v("\t- Value: " + str(value))