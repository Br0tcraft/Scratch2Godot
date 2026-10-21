class_name ScratchCostumeModel

var name: String = ""
var assetId: String = ""
var bitmapResolution: float = 0
var dataFormat: String = ""
var md5ext: String = ""
var rotationCenterX: float = 0
var rotationCenterY: float = 0


func load_from_dict(data: Dictionary) -> void:
    name = data.get("name", "")
    assetId = data.get("assetId", "")
    dataFormat = data.get("dataFormat", "svg")
    md5ext = data.get("md5ext", "")
    rotationCenterX = data.get("rotationCenterX", 0)
    rotationCenterY = data.get("rotationCenterY", 0)
    bitmapResolution = data.get("bitmapResolution", 1)
    ScratchLog.v("[COSTUME]" + str(name))
    ScratchLog.v("\t- AssetId: " + str(assetId))
    ScratchLog.v("\t- DataFormat: " + str(dataFormat))
    ScratchLog.v("\t- Md5ext: " + str(md5ext))
    ScratchLog.v("\t- RotationCenterX: " + str(rotationCenterX))
    ScratchLog.v("\t- RotationCenterY: " + str(rotationCenterY))
    ScratchLog.v("\t- BitmapResolution: " + str(bitmapResolution))
