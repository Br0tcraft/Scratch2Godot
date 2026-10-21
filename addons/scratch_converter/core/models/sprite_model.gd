class_name ScratchSpriteModel
extends RefCounted

var is_stage: bool = false
var sprite_name: String = ""

var variables: Array[ScratchVariableModel] = []
var lists: Array[ScratchListModel] = []
var costumes: Array[ScratchCostumeModel] = []
var sounds: Array[ScratchSoundModel] = []
var broadcasts: Array[ScratchBroadcastModel] = []
var scripts: Dictionary[String, ScratchBlockModel] = {}
#looks
var current_costume_index: int = 0
var visible: bool = true
var size: float = 100.0
var layer_order: int = 0
#effects
var effect_color: float = 0.0
var effect_fisheye: float = 0.0
var effect_whirl: float = 0.0
var effect_pixelate: float = 0.0
var effect_ghost: float = 0.0
var effect_mosaic: float = 0.0
var effect_brightness: float = 0.0
#motion
var direction: float = 90.0
var rotation_style: ScratchSprite.RotationStyle = ScratchSprite.RotationStyle.ALL_AROUND
var x: float = 0.0
var y: float = 0.0
#sound
var volume: float = 100.0
#sensing
var draggable: bool = false


func load_from_dict(target: Dictionary) -> void:
    sprite_name = target.get("name", "")
    is_stage = target.get("isStage", false)

    current_costume_index = target.get("currentCostume", 0)
    visible = target.get("visible", true)
    size = target.get("size", 100.0)
    layer_order = target.get("layerOrder", 0)

    draggable = target.get("draggable", false)

    volume = target.get("volume", 100.0)

    x = target.get("x", 0.0)
    y = target.get("y", 0.0)
    direction = target.get("direction", 90.0)
    match target.get("rotationStyle", "all around"):
        "all around":
            rotation_style = ScratchSprite.RotationStyle.ALL_AROUND
        "left-right":
            rotation_style = ScratchSprite.RotationStyle.LEFT_RIGHT
        "don't rotate":
            rotation_style = ScratchSprite.RotationStyle.DONT_ROTATE
        _:
            rotation_style = ScratchSprite.RotationStyle.ALL_AROUND

    variables = _load_vars(target)
    lists = _load_lists(target)
    costumes = _load_costumes(target)
    sounds = _load_sounds(target)
    broadcasts = _load_broadcasts(target)
    scripts = _load_scripts(target)


func _load_vars(target: Dictionary) -> Array[ScratchVariableModel]:
    ScratchLog.v("[SPRITE] (" + sprite_name + ") load Vars:")
    var vars: Dictionary = target.get("variables", {})
    if vars is not Dictionary:
        return []

    var variables: Array[ScratchVariableModel] = []
    for id in vars.keys():
        if id is not String or vars[id] is not Array:
            continue
        var scratch_variable := ScratchVariableModel.new()
        scratch_variable.load_from_array(vars[id], id)
        variables.append(scratch_variable)

    return variables


func _load_lists(target: Dictionary) -> Array[ScratchListModel]:
    ScratchLog.v("[SPRITE] (" + sprite_name + ") load Lists:")
    var lists_data = target.get("lists", {})
    var scratch_lists: Array[ScratchListModel] = []
    if not lists_data is Dictionary:
        return scratch_lists
    for id in lists_data.keys():
        var entry = lists_data[id]
        if not entry is Array or entry.size() < 1:
            continue
        var scratch_list := ScratchListModel.new()
        scratch_list.id = str(id)
        scratch_list.name = str(entry[0])
        if entry.size() > 1 and entry[1] is Array:
            scratch_list.value = entry[1]
        scratch_lists.append(scratch_list)
    return scratch_lists


func _load_costumes(target: Dictionary) -> Array[ScratchCostumeModel]:
    ScratchLog.v("[SPRITE] (" + sprite_name + ") load Costumes:")
    var costumes := target.get("costumes", [])
    if costumes is not Array:
        return []

    var scratch_costumes: Array[ScratchCostumeModel] = []
    for costume in costumes:
        var scratch_costume := ScratchCostumeModel.new()
        scratch_costume.load_from_dict(costume)
        scratch_costumes.append(scratch_costume)

    return scratch_costumes


func _load_sounds(target: Dictionary) -> Array[ScratchSoundModel]:
    ScratchLog.v("[SPRITE] (" + sprite_name + ") load Sounds:")
    var sounds := target.get("sounds", [])
    if sounds is not Array:
        return []

    var scratch_sounds: Array[ScratchSoundModel] = []
    for sound in sounds:
        var scratch_sound := ScratchSoundModel.new()
        scratch_sound.load_from_dict(sound)
        scratch_sounds.append(scratch_sound)

    return scratch_sounds


func _load_broadcasts(target: Dictionary) -> Array[ScratchBroadcastModel]:
    ScratchLog.v("[SPRITE] (" + sprite_name + ") load Broadcasts:")
    var scratch_broadcasts: Array[ScratchBroadcastModel] = []
    var broadcasts := target.get("broadcasts", {})
    if not broadcasts is Dictionary:
        return scratch_broadcasts

    for broadcast in broadcasts.keys():
        var broadcast_name = broadcasts[broadcast]
        if not broadcast_name is String:
            continue
        var scratch_broadcast := ScratchBroadcastModel.new(broadcast, broadcast_name)
        scratch_broadcasts.append(scratch_broadcast)

    return scratch_broadcasts


func _load_scripts(target: Dictionary) -> Dictionary[String, ScratchBlockModel]:
    ScratchLog.v("[SPRITE] (" + sprite_name + ") load Scripts:")
    var scripts: Dictionary[String, ScratchBlockModel] = {}
    if not target.has("blocks") or typeof(target["blocks"]) != TYPE_DICTIONARY:
        return scripts
    
    var all_blocks_data: Dictionary = target["blocks"]
    for block_id in all_blocks_data.keys():
        var block_data = all_blocks_data[block_id]
        if not block_data is Dictionary or not block_data.has("opcode"):
            continue

        var scratch_block := ScratchBlockModel.new()
        scratch_block.load_from_dict(block_id, block_data, all_blocks_data)
        scripts[block_id] = scratch_block

    return scripts

func get_cloud_vars() -> Array[ScratchVariableModel]:
    var cloud_vars: Array[ScratchVariableModel] = []
    ScratchLog.v("get cloud")
    for variable in variables:
        if variable.type == ScratchVariableModel.VariableTypes.CLOUD:
            cloud_vars.append(variable)

    return cloud_vars