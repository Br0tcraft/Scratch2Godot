class_name ScratchMotion
extends RefCounted

var _sprite: ScratchSprite

func _init(sprite: ScratchSprite) -> void:
	_sprite = sprite


func x_position() -> float:
	return _sprite.position.x

func y_position() -> float:
	return -_sprite.position.y


func set_x(x: float) -> void:
	_sprite.position.x = x

func set_y(y: float) -> void:
	_sprite.position.y = -y

func change_x(dx: float) -> void:
	_sprite.position.x += dx

func change_y(dy: float) -> void:
	_sprite.position.y -= dy

func go_to_xy(x: float, y: float) -> void:
	_sprite.position = Vector2(x, -y)


func get_direction() -> float:
	return _sprite.direction

func set_direction(scratch_dir: float) -> void:
	_sprite.direction = scratch_dir
	_apply_rotation_style()


func move_steps(steps: float) -> void:
	var dir_rad := deg_to_rad(get_direction())
	var dx := sin(dir_rad) * steps
	var dy := cos(dir_rad) * steps
	_sprite.position += Vector2(dx, -dy)


func turn_right(degrees: float) -> void:
	set_direction(get_direction() + degrees)


func turn_left(degrees: float) -> void:
	set_direction(get_direction() - degrees)


func point_in_direction(scratch_dir: float) -> void:
	set_direction(scratch_dir)


func go_to(target: String) -> void:
	if target == "_mouse_":
		var mp := _sprite.get_global_mouse_position()
		go_to_xy(mp.x, -mp.y)
		return
	if target == "_random_":
		var proj := _sprite.get_scratch_project()
		if proj != null:
			var vp := proj.stage_size()
			go_to_xy(randf_range(-vp.x * 0.5, vp.x * 0.5),
			          randf_range(-vp.y * 0.5, vp.y * 0.5))
		return
	var other := _resolve_target(target)
	if other != null:
		go_to_xy(other.position.x, -other.position.y)


func point_towards(target: String) -> void:
	var tx: float; var ty: float
	if target == "_mouse_":
		var mp := _sprite.get_global_mouse_position()
		tx = mp.x; ty = - mp.y
	else:
		var other := _resolve_target(target)
		if other == null: return
		tx = other.position.x; ty = - other.position.y
	point_towards_xy(tx, ty)

func point_towards_xy(target_x: float, target_y: float) -> void:
	var dx := target_x - x_position()
	var dy := target_y - y_position()
	var dir := rad_to_deg(atan2(dx, dy))
	set_direction(dir)


func glide_to_xy(ctx: ScriptContext, x: float, y: float, seconds: float) -> void:
	var start := Vector2(x_position(), y_position())
	var end_pos := Vector2(x, y)

	if seconds <= 0.0:
		go_to_xy(x, y)
		return

	var elapsed := 0.0
	var tree := _sprite.get_tree()

	while elapsed < seconds:
		if ctx.cancelled():
			return
		await tree.process_frame
		elapsed += tree.root.get_process_delta_time()
		var t: float = clampf(elapsed / seconds, 0.0, 1.0)
		var cur := start.lerp(end_pos, t)
		go_to_xy(cur.x, cur.y)

	go_to_xy(x, y)


func glide_to(ctx: ScriptContext, seconds: float, target: String) -> void:
	var tx: float; var ty: float
	if target == "_mouse_":
		var mp := _sprite.get_global_mouse_position()
		tx = mp.x; ty = - mp.y
	elif target == "_random_":
		var proj := _sprite.get_scratch_project()
		if proj != null:
			var vp := proj.stage_size()
			tx = randf_range(-vp.x * 0.5, vp.x * 0.5)
			ty = randf_range(-vp.y * 0.5, vp.y * 0.5)
		else:
			tx = 0.0; ty = 0.0
	else:
		var other := _resolve_target(target)
		if other == null: return
		tx = other.position.x; ty = - other.position.y
	await glide_to_xy(ctx, tx, ty, seconds)


func if_on_edge_bounce() -> void:
	var proj := _sprite.get_scratch_project()
	if proj == null: return
	var vp := proj.stage_size()
	var half_w := vp.x * 0.5
	var half_h := vp.y * 0.5
	var pos := _sprite.position
	var dir := get_direction()
	var changed := false

	var min_ox := 0.0
	var max_ox := 0.0
	var min_oy := 0.0
	var max_oy := 0.0
	var has_bounds := false

	var area := _sprite.get_hitbox_area()
	if area != null:
		for shape in area.get_children():
			if shape is CollisionPolygon2D and shape.polygon.size() > 0:
				for pt in shape.polygon:
					var world_pt: Vector2 = _sprite.to_global(pt)
					var ox: float = world_pt.x - pos.x
					var oy: float = world_pt.y - pos.y
					if not has_bounds:
						min_ox = ox; max_ox = ox
						min_oy = oy; max_oy = oy
						has_bounds = true
					else:
						min_ox = minf(min_ox, ox); max_ox = maxf(max_ox, ox)
						min_oy = minf(min_oy, oy); max_oy = maxf(max_oy, oy)

	if not has_bounds:
		var spr := _sprite.get_node_or_null("Sprite2D") as Sprite2D
		if spr and spr.texture:
			var sz := spr.texture.get_size() * spr.scale * _sprite.scratch_size
			min_ox = - sz.x * 0.5; max_ox = sz.x * 0.5
			min_oy = - sz.y * 0.5; max_oy = sz.y * 0.5

	if pos.x + min_ox < -half_w:
		pos.x = - half_w - min_ox
		if sin(deg_to_rad(dir)) < 0: dir = - dir; changed = true
	elif pos.x + max_ox > half_w:
		pos.x = half_w - max_ox
		if sin(deg_to_rad(dir)) > 0: dir = - dir; changed = true

	if pos.y + min_oy < -half_h:
		pos.y = - half_h - min_oy
		if cos(deg_to_rad(dir)) > 0: dir = 180.0 - dir; changed = true
	elif pos.y + max_oy > half_h:
		pos.y = half_h - max_oy
		if cos(deg_to_rad(dir)) < 0: dir = 180.0 - dir; changed = true

	if changed:
		_sprite.position = pos
		set_direction(dir)


func set_rotation_style(style: ScratchSprite.RotationStyle) -> void:
	_sprite.rotation_style = style
	_apply_rotation_style()


func clamp_to_stage(stage_size: Vector2) -> void:
	var half_w := stage_size.x * 0.5
	var half_h := stage_size.y * 0.5
	var pos := _sprite.position
	pos.x = clampf(pos.x, -half_w, half_w)
	pos.y = clampf(pos.y, -half_h, half_h)
	_sprite.position = pos

func _apply_rotation_style() -> void:
	match _sprite.rotation_style:
		ScratchSprite.RotationStyle.ALL_AROUND:
			_sprite.rotation_degrees = _sprite.direction - 90.0
			_sprite.scale = Vector2(_sprite.scratch_size, _sprite.scratch_size)
		ScratchSprite.RotationStyle.LEFT_RIGHT:
			_sprite.rotation_degrees = 0.0
			var d := fmod(_sprite.direction, 360.0)
			if d < 0: d += 360.0
			var facing_left := (d > 90.0 and d < 270.0)
			_sprite.scale = Vector2(-_sprite.scratch_size if facing_left else _sprite.scratch_size, _sprite.scratch_size)
		ScratchSprite.RotationStyle.DONT_ROTATE:
			_sprite.rotation_degrees = 0.0
			_sprite.scale = Vector2(_sprite.scratch_size, _sprite.scratch_size)

func _resolve_target(name: String) -> ScratchSprite:
	var proj := _sprite.get_scratch_project()
	if proj == null: return null
	if name == "_stage_" or name == "Stage": return proj.get_stage()
	for s in proj.get_sprites():
		if s.name == name:
			return s
	return null