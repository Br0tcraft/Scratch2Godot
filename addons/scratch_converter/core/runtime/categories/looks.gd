class_name ScratchLooks
extends RefCounted

var _sprite: ScratchSprite
var _effects: Dictionary[String, float] = {}
var _bubble: Label
var _bubble_usage_id: int = 0
var _next_usage_id: int = 0

func _init(sprite: ScratchSprite) -> void:
	_sprite = sprite

func _ensure_bubble() -> Label:
	if _bubble == null or not is_instance_valid(_bubble):
		_bubble = Label.new()
		_bubble.name = "ScratchSayBubble"
		_bubble.z_index = 4096
		_bubble.add_theme_color_override("font_color", Color.WHITE)
		_bubble.add_theme_color_override("font_outline_color", Color.BLACK)
		_bubble.add_theme_constant_override("outline_size", 4)
		_bubble.visible = false
		_sprite.add_child(_bubble)
	return _bubble

func _set_bubble(text: String, think: bool) -> void:
	var b := _ensure_bubble()
	b.text = text
	b.visible = not text.is_empty()
	b.position = Vector2(-50, -70)
	b.modulate = Color(0.9, 0.9, 1.0) if think else Color.WHITE

func say(msg: String) -> void:
	_next_usage_id += 1
	_bubble_usage_id = _next_usage_id
	_set_bubble(msg, false)

func say_for(ctx: ScriptContext, msg: String, secs: float) -> void:
	_next_usage_id += 1
	var my_id := _next_usage_id
	_bubble_usage_id = my_id
	_set_bubble(msg, false)
	if secs > 0.0:
		var end_time := Time.get_ticks_msec() / 1000.0 + secs
		while Time.get_ticks_msec() / 1000.0 < end_time:
			if ctx.cancelled(): return
			await _sprite.get_tree().process_frame
	if _bubble_usage_id == my_id:
		_set_bubble("", false)

func think(msg: String) -> void:
	_next_usage_id += 1
	_bubble_usage_id = _next_usage_id
	_set_bubble(msg, true)

func think_for(ctx: ScriptContext, msg: String, secs: float) -> void:
	_next_usage_id += 1
	var my_id := _next_usage_id
	_bubble_usage_id = my_id
	_set_bubble(msg, true)
	if secs > 0.0:
		var end_time := Time.get_ticks_msec() / 1000.0 + secs
		while Time.get_ticks_msec() / 1000.0 < end_time:
			if ctx.cancelled(): return
			await _sprite.get_tree().process_frame
	if _bubble_usage_id == my_id:
		_set_bubble("", true)

func _sprite2d() -> Sprite2D:
	return _sprite.get_node_or_null("Sprite2D") as Sprite2D

func switch_costume(to: Variant) -> void:
	if _sprite.costumes.is_empty(): return
	var idx := -1
	if to is String and not to.is_valid_float():
		for i in _sprite.costumes.size():
			if _sprite.costumes[i].name == to: idx = i; break
	else:
		var n := int(round(S.num(to)))
		var count := _sprite.costumes.size()
		var zero_idx := posmod(n - 1, count)
		_sprite.current_costume = zero_idx
		_apply_costume()
	if idx >= 0:
		_sprite.current_costume = idx
		_apply_costume()

func next_costume() -> void:
	if _sprite.costumes.is_empty(): return
	_sprite.current_costume = (_sprite.current_costume + 1) % _sprite.costumes.size()
	_apply_costume()

func costume_number() -> int: return _sprite.current_costume + 1
func costume_name() -> String:
	if _sprite.costumes.size() > _sprite.current_costume:
		return _sprite.costumes[_sprite.current_costume].name
	return ""

func _apply_costume() -> void:
	var s := _sprite2d()
	if s == null or _sprite.costumes.size() <= _sprite.current_costume: return
	var c := _sprite.costumes[_sprite.current_costume]
	if c.texture == null: return
	s.texture = c.texture
	s.centered = true
	s.scale = Vector2.ONE / maxf(c.bitmap_resolution, 1.0)           # child scale, independent of sprite size
	s.offset = c.texture.get_size() * 0.5 - c.rotation_center        # in texture px: pivot = node origin

func set_size(pct: float) -> void:
	_sprite.scratch_size = pct / 100.0
	_apply_scale()
func change_size(delta: float) -> void:
	set_size(_sprite.scratch_size * 100.0 + delta)
func get_size() -> float: return _sprite.scratch_size * 100.0

func _apply_scale() -> void:
	_sprite.scale = Vector2(_sprite.scratch_size, _sprite.scratch_size)

func show() -> void: _sprite.scratch_visible = true
func hide() -> void: _sprite.scratch_visible = false

func go_to_front() -> void:
	ScratchLayers.to_front(_sprite)

func go_to_back() -> void:
	ScratchLayers.to_back(_sprite)

func go_forward_layers(n: int) -> void:
	ScratchLayers.shift(_sprite, n)
	
func go_backward_layers(n: int) -> void:
	ScratchLayers.shift(_sprite, -n)

func _max_sibling_z() -> int:
	var max_z := _sprite.z_index
	for sib in _sprite.get_parent().get_children():
		if sib is ScratchSprite and sib != _sprite:
			max_z = max(max_z, sib.z_index)
	return max_z

func _min_sibling_z() -> int:
	var min_z := _sprite.z_index
	for sib in _sprite.get_parent().get_children():
		if sib is ScratchSprite and sib != _sprite:
			min_z = min(min_z, sib.z_index)
	return min_z

func set_effect_ghost(v: float) -> void: _set_effect("GHOST", clampf(v, 0.0, 100.0))
func set_effect_brightness(v: float) -> void: _set_effect("BRIGHTNESS", clampf(v, -100.0, 100.0))
func set_effect_color(v: float) -> void: _set_effect("COLOR", v)
func set_effect_fisheye(v: float) -> void: _set_effect("FISHEYE", v)
func set_effect_whirl(v: float) -> void: _set_effect("WHIRL", v)
func set_effect_pixelate(v: float) -> void: _set_effect("PIXELATE", v)
func set_effect_mosaic(v: float) -> void: _set_effect("MOSAIC", v)

func change_effect_ghost(d: float) -> void: _change_effect("GHOST", d)
func change_effect_brightness(d: float) -> void: _change_effect("BRIGHTNESS", d)
func change_effect_color(d: float) -> void: _change_effect("COLOR", d)
func change_effect_fisheye(d: float) -> void: _change_effect("FISHEYE", d)
func change_effect_whirl(d: float) -> void: _change_effect("WHIRL", d)
func change_effect_pixelate(d: float) -> void: _change_effect("PIXELATE", d)
func change_effect_mosaic(d: float) -> void: _change_effect("MOSAIC", d)

func _set_effect(name: String, value: float) -> void:
	_effects[name] = value
	_apply_effects()

func _change_effect(name: String, delta: float) -> void:
	_effects[name] = _effects.get(name, 0.0) + delta; _apply_effects()

func clear_graphic_effects() -> void:
	_effects.clear()
	_apply_effects()

func get_effect(name: String) -> float:
	return _effects.get(name, 0.0)

func _apply_effects() -> void:
	var s := _sprite2d()
	if s == null: return
	var ghost := _effects.get("GHOST", 0.0) / 100.0 as float
	var bright := _effects.get("BRIGHTNESS", 0.0) / 100.0 as float
	var hue := _effects.get("COLOR", 0.0) / 200.0 as float
	var a := clampf(1.0 - ghost, 0.0, 1.0)
	var v := clampf(1.0 + bright, 0.0, 2.0)
	if hue != 0.0:
		s.modulate = Color.from_hsv(hue, 1.0, v, a)
	else:
		s.modulate = Color(v, v, v, a)