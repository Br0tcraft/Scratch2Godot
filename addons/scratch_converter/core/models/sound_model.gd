class_name ScratchSoundModel
extends RefCounted

var name: String = ""
var dataFormat: String = ""
var md5ext: String = ""

func load_from_dict(data: Dictionary) -> void:
    name = data.get("name", "")
    dataFormat = data.get("dataFormat", "")
    md5ext = data.get("md5ext", "")
    self.name = name
    self.dataFormat = dataFormat
    self.md5ext = md5ext
    ScratchLog.v("[SOUND]" + str(name))
    ScratchLog.v("\t- DataFormat: " + str(dataFormat))
    ScratchLog.v("\t- Md5ext: " + str(md5ext))