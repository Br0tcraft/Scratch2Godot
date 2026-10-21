class_name ScratchVariableModel
extends RefCounted

enum VariableTypes {
    NORMAL,
    CLOUD,
    STORAGE
}

var name: String = ""
var gd_name: String = ""
var type: VariableTypes = VariableTypes.NORMAL
var id: String = ""
var value: Variant = null


func load_from_array(data: Array, id: String) -> void:
    if data.size() < 2 or data[0] is not String:
        return
    self.id = id
    name = data[0]
    value = data[1]
    if data.size() > 2 and data[2]:
        type = VariableTypes.CLOUD
    else:
        type = VariableTypes.NORMAL
    ScratchLog.v("[VAR] " + name)
    ScratchLog.v("\t- Id: " + id)
    ScratchLog.v("\t- Value: " + str(value))
    ScratchLog.v("\t- Type: " + VariableTypes.keys()[type])
