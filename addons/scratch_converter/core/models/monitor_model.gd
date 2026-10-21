class_name ScratchMonitorModel
extends RefCounted

const MODES = {
    "normal": Mode.NORMAL,
    "large": Mode.LARGE,
    "slider": Mode.SLIDER,
    "list": Mode.LIST
}

enum Mode {
    NORMAL,
    LARGE,
    SLIDER,
    LIST
}

var _id: String = ""
var _mode: Mode = Mode.NORMAL
var _opcode: String = ""
var _value: Variant = null
var _params: Dictionary = {}
var _sprite_name: String = ""
var _width: int = 0
var _height: int = 0
var _x: int = 0
var _y: int = 0
var visible: bool = true
var slider_min := 0.0
var slider_max := 100.0
var is_discrete := true

func load_from_dict(monitor_dict: Dictionary) -> void:
    _id = str(monitor_dict.get("id", ""))
    _opcode = str(monitor_dict.get("opcode", ""))
    _sprite_name = str(monitor_dict.get("spriteName", ""))
    
    _mode = MODES.get(monitor_dict.get("mode", "normal"), Mode.NORMAL)
    
    _value = monitor_dict.get("value", null)
    
    var params_raw = monitor_dict.get("params")
    _params = params_raw if params_raw is Dictionary else {}
    
    _width = int(monitor_dict.get("width", 0))
    _height = int(monitor_dict.get("height", 0))
    _x = int(monitor_dict.get("x", 0))
    _y = int(monitor_dict.get("y", 0))
    
    slider_min = float(monitor_dict.get("sliderMin", 0.0))
    slider_max = float(monitor_dict.get("sliderMax", 100.0))
    is_discrete = bool(monitor_dict.get("isDiscrete", true))
    
    var visible_raw = monitor_dict.get("visible")
    if visible_raw is bool:
        visible = visible_raw
    else:
        visible = bool(visible_raw) if visible_raw != null else true
    
    ScratchLog.v("[MONITOR]" + str(_sprite_name))
    ScratchLog.v("\t- Id: " + str(_id))
    ScratchLog.v("\t- Mode: " + str(_mode))
    ScratchLog.v("\t- Opcode: " + str(_opcode))
    ScratchLog.v("\t- Value: " + str(_value))
    ScratchLog.v("\t- Params: " + str(_params))
    ScratchLog.v("\t- Width: " + str(_width))
    ScratchLog.v("\t- Height: " + str(_height))
    ScratchLog.v("\t- X: " + str(_x))
    ScratchLog.v("\t- Y: " + str(_y))
    ScratchLog.v("\t- Visible: " + str(visible))