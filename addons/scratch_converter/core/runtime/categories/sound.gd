class_name ScratchSoundPlayer
extends RefCounted

const EFFECT_RANGE := {
    "pitch": Vector2(-360.0, 360.0),
    "pan": Vector2(-100.0, 100.0),
}

var _sprite: ScratchSprite
var _effects: Dictionary = {"pitch": 0.0, "pan": 0.0}
var _volume: float = 100.0
var _players: Array[AudioStreamPlayer] = []
var _waiting: Dictionary = {}


func _init(sprite: ScratchSprite) -> void:
    _sprite = sprite
    for i in 3:
        var p := AudioStreamPlayer.new()
        p.bus = "Master"
        sprite.add_child(p)
        _players.append(p)

func play(name: String) -> void:
    _play_internal(name)

func play_until_done(ctx: ScriptContext, name: String) -> void:
    var stream := _find_stream(name)
    if stream == null: return
    _waiting[name] = _waiting.get(name, 0) + 1
    var player := _acquire_player()
    _configure_player(player, stream)
    player.play()
    await player.finished
    _waiting[name] = max(0, _waiting.get(name, 1) - 1)

func stop_all() -> void:
    for p in _players:
        if p.playing: p.stop()
    _waiting.clear()

func _play_internal(name: String) -> void:
    var stream := _find_stream(name)
    if stream == null: return
    var player := _acquire_player()
    _configure_player(player, stream)
    player.play()

func _configure_player(p: AudioStreamPlayer, stream: AudioStream) -> void:
    p.stream = stream
    p.volume_db = linear_to_db(_volume / 100.0)
    p.pitch_scale = pow(2.0, _effects["pitch"] / 1200.0)
    p.panning_strength = _effects["pan"] / 100.0

func _acquire_player() -> AudioStreamPlayer:
    for p in _players:
        if not p.playing: return p
    var p := AudioStreamPlayer.new()
    p.bus = "Master"
    _sprite.add_child(p)
    _players.append(p)
    return p

func _find_stream(name: String) -> AudioStream:
    for s in _sprite.sounds:
        if s.name == name: return s.stream
    if name.is_valid_int():
        var i := int(name) - 1
        if i >= 0 and i < _sprite.sounds.size():
            return _sprite.sounds[i].stream
    return null

func set_volume(v: float) -> void: _volume = clampf(v, 0.0, 100.0)
func change_volume(d: float) -> void: set_volume(_volume + d)
func get_volume() -> float: return _volume

func set_effect_pitch(v: float) -> void:
    _effects["pitch"] = clampf(v, EFFECT_RANGE["pitch"].x, EFFECT_RANGE["pitch"].y)

func change_effect_pitch(d: float) -> void:
    set_effect_pitch(_effects["pitch"] + d)

func set_effect_pan(v: float) -> void:
    _effects["pan"] = clampf(v, EFFECT_RANGE["pan"].x, EFFECT_RANGE["pan"].y)

func change_effect_pan(d: float) -> void:
    set_effect_pan(_effects["pan"] + d)

func clear_effects() -> void:
    _effects["pitch"] = 0.0
    _effects["pan"] = 0.0