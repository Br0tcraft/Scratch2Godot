class_name ScratchBroadcastModel
extends RefCounted

var id: String = ""
var name: String = ""


func _init(id: String, name: String) -> void:
    self.id = id
    self.name = name
    ScratchLog.v("[BROADCAST]" + str(name))
    ScratchLog.v("\t- Id: " + str(id))