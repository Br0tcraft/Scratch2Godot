class_name ScratchControl
extends RefCounted

var _sprite: ScratchSprite

func _init(sprite: ScratchSprite) -> void:
	_sprite = sprite

func wait(ctx: ScriptContext, seconds: float) -> void:
	if seconds <= 0.0:
		await _sprite.get_tree().process_frame
		return
	var end_time := Time.get_ticks_msec() / 1000.0 + seconds
	while Time.get_ticks_msec() / 1000.0 < end_time:
		if ctx.cancelled():
			return
		await _sprite.get_tree().process_frame

func wait_until(ctx: ScriptContext, condition: Callable) -> void:
	while not condition.call():
		if ctx.cancelled():
			return
		await _sprite.get_tree().process_frame

func create_clone_of(target: ScratchSprite) -> void:
	if target == null:
		return
	target._spawn_clone()

func create_clone_of_named(target_name: String) -> void:
	var proj := _sprite.get_scratch_project()
	if proj == null: return
	for s in proj.get_sprites():
		if s.name == target_name:
			s._spawn_clone()
			return

func delete_this_clone() -> void:
	if _sprite.is_clone:
		_sprite._remove_clone()
