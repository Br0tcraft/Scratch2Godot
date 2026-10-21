class_name ScriptContext
extends RefCounted

var sprite: ScratchSprite
var generation: int
var script_id: int
var _self_cancelled: bool = false

func _init(s: ScratchSprite, gen: int, id: int) -> void:
    sprite = s
    generation = gen
    script_id = id

func cancel_self() -> void:
    _self_cancelled = true

func cancelled() -> bool:
    return _self_cancelled or sprite._generation != generation
