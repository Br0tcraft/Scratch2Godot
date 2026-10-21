class_name ScratchSensing
extends RefCounted

var _sprite: ScratchSprite
var _answer: String = ""
var _timer_start: float = 0.0

func _init(sprite: ScratchSprite) -> void:
	_sprite = sprite
	_timer_start = Time.get_ticks_msec() / 1000.0

func _resolve_target(name: String) -> ScratchSprite:
	var proj := _sprite.get_scratch_project()
	if proj == null: return null
	if name == "_stage_" or name == "Stage": return proj.get_stage()
	for s in proj.get_sprites():
		if s.name == name: return s
	return null

func touching(target: String) -> bool:
	if target == "_mouse_":
		return _area_has_global_point(_sprite, _sprite.get_global_mouse_position())
	if target == "_edge_":
		return _touching_edge()
	var other := _resolve_target(target)
	if other == null: return false
	return _areas_overlap(_sprite, other)

func _touching_edge() -> bool:
	var proj := _sprite.get_scratch_project()
	if proj == null: return false
	var vp := proj.stage_size() * 0.5
	var p := _sprite.position
	var area := _sprite.get_hitbox_area()
	if area != null and area.get_child_count() > 0:
		var has_any_poly := false
		for shape_node in area.get_children():
			if shape_node is CollisionPolygon2D and shape_node.polygon.size() > 0:
				has_any_poly = true
				for pt in shape_node.polygon:
					var world_pt: Vector2 = _sprite.to_global(pt)
					if world_pt.x <= -vp.x or world_pt.x >= vp.x or \
					   world_pt.y <= -vp.y or world_pt.y >= vp.y:
						return true
		if has_any_poly:
			return false
	return p.x <= -vp.x or p.x >= vp.x or p.y <= -vp.y or p.y >= vp.y

func _areas_overlap(a: ScratchSprite, b: ScratchSprite) -> bool:
	var area_a := a.get_hitbox_area()
	var area_b := b.get_hitbox_area()
	if area_a == null or area_b == null:
		return _aabb_overlap(a, b)
	return area_a.overlaps_area(area_b)

func _area_has_global_point(s: ScratchSprite, p: Vector2) -> bool:
	var area := s.get_hitbox_area()
	if area == null: return _aabb_has_point(s, p)
	var space := s.get_world_2d().direct_space_state
	if space == null: return _aabb_has_point(s, p)
	var params := PhysicsPointQueryParameters2D.new()
	params.position = p
	params.collision_mask = area.collision_layer
	params.collide_with_areas = true
	var results := space.intersect_point(params)
	for r in results:
		if r.get("collider") == area:
			return true
	return false

func touching_color(target_color: Color) -> bool:
	var img := _capture_viewport_image()
	if img == null: return false
	for poly in _hitbox_polygons_in_viewport():
		if _any_pixel_matches(img, poly, target_color, false):
			return true
	return false

func color_is_touching_color(sprite_color: Color, scene_color: Color) -> bool:
	var img := _capture_viewport_image()
	if img == null: return false
	for poly in _hitbox_polygons_in_viewport():
		if _any_pixel_matches(img, poly, scene_color, false):
			return true
	return false

func _capture_viewport_image() -> Image:
	var vp := _sprite.get_viewport()
	if vp == null: return null
	var tex := vp.get_texture()
	if tex == null: return null
	return tex.get_image()

func _hitbox_polygons_in_viewport() -> Array[PackedVector2Array]:
	var area := _sprite.get_hitbox_area()
	var vp := _sprite.get_viewport()
	if area == null or vp == null:
		return [_aabb_polygon_in_viewport()]
	var vp_size := vp.get_visible_rect().size
	var result: Array[PackedVector2Array] = []
	for shape_node in area.get_children():
		if shape_node is CollisionPolygon2D and shape_node.polygon.size() >= 3:
			var out := PackedVector2Array()
			for local_pt in shape_node.polygon:
				var world_pt: Vector2 = _sprite.to_global(local_pt)
				var px := world_pt.x + vp_size.x * 0.5
				var py := world_pt.y + vp_size.y * 0.5
				out.append(Vector2(px, py))
			result.append(out)
	if result.is_empty():
		return [_aabb_polygon_in_viewport()]
	return result

func _hitbox_polygon_in_viewport() -> PackedVector2Array:
	var polys := _hitbox_polygons_in_viewport()
	return polys[0] if not polys.is_empty() else PackedVector2Array()

func _aabb_polygon_in_viewport() -> PackedVector2Array:
	var spr := _sprite.get_node_or_null("Sprite2D") as Sprite2D
	if spr == null or spr.texture == null:
		return PackedVector2Array()
	var vp := _sprite.get_viewport()
	var vp_size := vp.get_visible_rect().size if vp else Vector2.ZERO
	var sz := spr.texture.get_size()
	var cx := _sprite.position.x + vp_size.x * 0.5
	var cy := _sprite.position.y + vp_size.y * 0.5
	return PackedVector2Array([
		Vector2(cx - sz.x * 0.5, cy - sz.y * 0.5),
		Vector2(cx + sz.x * 0.5, cy - sz.y * 0.5),
		Vector2(cx + sz.x * 0.5, cy + sz.y * 0.5),
		Vector2(cx - sz.x * 0.5, cy + sz.y * 0.5),
	])

const MASK_R := 0xF8
const MASK_G := 0xF8
const MASK_B := 0xF0

func _any_pixel_matches(img: Image, poly: PackedVector2Array, target: Color, _unused: bool) -> bool:
	if poly.size() < 3: return false
	var bounds := _poly_bounds(poly)
	var img_size := img.get_size()
	var x0 := int(clampf(bounds.position.x, 0, img_size.x - 1))
	var y0 := int(clampf(bounds.position.y, 0, img_size.y - 1))
	var x1 := int(clampf(bounds.position.x + bounds.size.x, 0, img_size.x - 1))
	var y1 := int(clampf(bounds.position.y + bounds.size.y, 0, img_size.y - 1))
	for y in range(y0, y1 + 1):
		for x in range(x0, x1 + 1):
			if _point_in_poly(Vector2(x + 0.5, y + 0.5), poly):
				var px := img.get_pixel(x, y)
				if _color_close(px, target):
					return true
	return false

func _poly_bounds(poly: PackedVector2Array) -> Rect2:
	var min_x := poly[0].x; var max_x := poly[0].x
	var min_y := poly[0].y; var max_y := poly[0].y
	for p in poly:
		min_x = minf(min_x, p.x); max_x = maxf(max_x, p.x)
		min_y = minf(min_y, p.y); max_y = maxf(max_y, p.y)
	return Rect2(Vector2(min_x, min_y), Vector2(max_x - min_x, max_y - min_y))

func _point_in_poly(pt: Vector2, poly: PackedVector2Array) -> bool:
	var inside := false
	var j := poly.size() - 1
	for i in range(poly.size()):
		var pi := poly[i]; var pj := poly[j]
		if ((pi.y > pt.y) != (pj.y > pt.y)) and \
		   (pt.x < (pj.x - pi.x) * (pt.y - pi.y) / (pj.y - pi.y) + pi.x):
			inside = !inside
		j = i
	return inside

func _color_close(a: Color, b: Color) -> bool:
	var ar := int(a.r * 255.0) & MASK_R
	var ag := int(a.g * 255.0) & MASK_G
	var ab := int(a.b * 255.0) & MASK_B
	var br := int(b.r * 255.0) & MASK_R
	var bg := int(b.g * 255.0) & MASK_G
	var bb := int(b.b * 255.0) & MASK_B
	return ar == br and ag == bg and ab == bb


func _aabb_rect(s: ScratchSprite) -> Rect2:
	var spr := s.get_node_or_null("Sprite2D") as Sprite2D
	if spr == null or spr.texture == null:
		return Rect2(s.position, Vector2.ZERO)
	var tex_size := spr.texture.get_size() * spr.scale
	var half := tex_size * 0.5
	var corners := PackedVector2Array([
		Vector2(-half.x, -half.y),
		Vector2(half.x, -half.y),
		Vector2(half.x, half.y),
		Vector2(-half.x, half.y),
	])
	var min_x := INF
	var min_y := INF
	var max_x := -INF
	var max_y := -INF
	for i in range(corners.size()):
		var world := s.to_global(corners[i])
		min_x = minf(min_x, world.x)
		min_y = minf(min_y, world.y)
		max_x = maxf(max_x, world.x)
		max_y = maxf(max_y, world.y)
	return Rect2(Vector2(min_x, min_y), Vector2(max_x - min_x, max_y - min_y))

func _aabb_overlap(a: ScratchSprite, b: ScratchSprite) -> bool:
	return _aabb_rect(a).intersects(_aabb_rect(b))

func _aabb_has_point(s: ScratchSprite, p: Vector2) -> bool:
	return _aabb_rect(s).has_point(p)

func distance_to(target: String) -> float:
	if target == "_mouse_":
		var mp := _sprite.get_global_mouse_position()
		return _sprite.position.distance_to(mp)
	var other := _resolve_target(target)
	if other == null: return 10000.0
	return _sprite.position.distance_to(other.position)

func key_pressed(key: String) -> bool:
	var k := key.strip_edges().to_lower()
	if k == "any": return _any_keyboard_key_pressed()
	if k == "space": return Input.is_key_pressed(KEY_SPACE)
	if k == "enter": return Input.is_key_pressed(KEY_ENTER)
	if k == "up arrow" or k == "up": return Input.is_key_pressed(KEY_UP)
	if k == "down arrow" or k == "down": return Input.is_key_pressed(KEY_DOWN)
	if k == "left arrow" or k == "left": return Input.is_key_pressed(KEY_LEFT)
	if k == "right arrow" or k == "right": return Input.is_key_pressed(KEY_RIGHT)
	if k.length() == 1:
		var code := OS.find_keycode_from_string(k.to_upper())
		if code != KEY_NONE: return Input.is_key_pressed(code)
	return false

func _any_keyboard_key_pressed() -> bool:
	var letters := "abcdefghijklmnopqrstuvwxyz0123456789"
	for ch in letters:
		var code := OS.find_keycode_from_string(ch.to_upper())
		if code != KEY_NONE and Input.is_key_pressed(code):
			return true
	for key_code in [
		KEY_SPACE, KEY_ENTER, KEY_TAB, KEY_ESCAPE, KEY_BACKSPACE, KEY_DELETE,
		KEY_UP, KEY_DOWN, KEY_LEFT, KEY_RIGHT, KEY_HOME, KEY_END,
		KEY_PAGEUP, KEY_PAGEDOWN, KEY_SHIFT, KEY_ALT, KEY_CTRL,
		KEY_CAPSLOCK, KEY_PRINT, KEY_PAUSE, KEY_MENU
	]:
		if Input.is_key_pressed(key_code):
			return true
	return false

func mouse_down() -> bool: return Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT)

func mouse_x() -> float:
	var mp := _sprite.get_global_mouse_position()
	return mp.x

func mouse_y() -> float:
	var mp := _sprite.get_global_mouse_position()
	return -mp.y

func ask_and_wait(ctx: ScriptContext, prompt: String) -> void:
	push_warning("Scratch ask: " + prompt)
	_answer = ""
	await _sprite.get_tree().process_frame

func answer() -> String: return _answer


func timer() -> float:
	return Time.get_ticks_msec() / 1000.0 - _timer_start

func reset_timer() -> void:
	_timer_start = Time.get_ticks_msec() / 1000.0

func of(attribute: String, target: String) -> Variant:
	var t := _resolve_target(target)
	if t == null: return 0.0
	match attribute:
		"x position": return t.motion.x_position()
		"y position": return t.motion.y_position()
		"direction": return t.motion.get_direction()
		"size": return t.looks.get_size()
		"volume": return 100.0 # TODO sound
		"costume #", "costume number": return t.looks.costume_number()
		"costume name": return t.looks.costume_name()
		"backdrop #", "backdrop number": return t.looks.costume_number()
		"backdrop name": return t.looks.costume_name()
	var v = t._scratch_get_var(attribute)
	if v != null: return v
	return 0.0

func current(unit: String) -> Variant:
	var d := Time.get_datetime_dict_from_system()
	var key := unit.strip_edges().to_lower().replace(" ", "").replace("_", "").replace("-", "")
	match key:
		"year": return d.year
		"month": return d.month
		"date": return d.day
		"dayofweek": return (d.weekday + 1)
		"hour": return d.hour
		"minute": return d.minute
		"second": return d.second
	return 0

func days_since_2000() -> float:
	var now := Time.get_unix_time_from_system()
	var base := Time.get_unix_time_from_datetime_string("2000-01-01T00:00:00")
	return (now - base) / 86400.0

func username() -> String:
	var user := OS.get_environment("USER")
	if user.is_empty():
		user = OS.get_environment("USERNAME")
	return user