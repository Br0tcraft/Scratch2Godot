class_name ScratchSprite
extends Node2D

enum Trigger {
	GREEN_FLAG,
	BROADCAST,
	KEY_PRESSED,
	CLICKED,
	TOUCHING,
	GREATER_THAN,
	CLONE_START,
	BACKDROP_SWITCH,
}
enum RotationStyle {ALL_AROUND, LEFT_RIGHT, DONT_ROTATE}
var motion: ScratchMotion
var control: ScratchControl
var looks: ScratchLooks
var sound: ScratchSoundPlayer
var sensing: ScratchSensing

@export var costumes: Array[ScratchCostume] = []
@export var sounds: Array[ScratchSound] = []
@export var current_costume: int = 0:
	set(v):
		var idx := v
		if costumes.size() > 0:
			idx = clampi(v, 0, costumes.size() - 1)
		current_costume = idx
		_apply_costume()
@export var direction: float = 90.0
@export var rotation_style: RotationStyle = RotationStyle.ALL_AROUND
@export var scratch_visible: bool = true:
	set(v): scratch_visible = v; _apply_visible()
@export var scratch_size: float = 1.0
@export var scratch_volume: float = 1.0
@export var draggable: bool = false

var _stage_cache: ScratchSprite = null
var stage: ScratchSprite:
	get:
		if _stage_cache == null or not is_instance_valid(_stage_cache):
			_stage_cache = _get_stage_ref()
		return _stage_cache

var _hats: Dictionary = {}
var _generation: int = 0
var _active_scripts: Dictionary = {}
var _next_script_id: int = 0

var monitors: MonitorManager:
	get:
		var p := get_scratch_project()
		return p.monitors if p else null
func _register_monitors() -> void: pass

const CLONE_LIMIT := 300
var is_clone: bool = false
var _clone_origin: ScratchSprite = null

var _hitbox_area: Area2D = null
var _hitbox_shape: CollisionPolygon2D = null

var cloud_var_map: Dictionary = {}

func get_scratch_project() -> ScratchProject:
	var parent: Node = get_parent()
	while parent:
		if parent is ScratchProject:
			return parent
		parent = parent.get_parent()
	return null

func _get_stage_ref() -> ScratchSprite:
	var proj := get_scratch_project()
	if proj:
		return proj.get_stage()
	return get_parent().get_node_or_null("Stage") as ScratchSprite

func _ready() -> void:
	motion = ScratchMotion.new(self)
	control = ScratchControl.new(self)
	looks = ScratchLooks.new(self)
	sound = ScratchSoundPlayer.new(self)
	sensing = ScratchSensing.new(self)

	_setup_hitbox()
	_apply_costume()
	_register_hats()

	set_process_input(true)

func _apply_costume() -> void:
	if costumes.is_empty():
		return
	if current_costume < 0:
		current_costume = 0
	if costumes.size() > current_costume:
		if looks != null:
			looks._apply_costume()
		else:
			var s := get_node_or_null("Sprite2D") as Sprite2D
			if s != null and costumes[current_costume].texture != null:
				s.texture = costumes[current_costume].texture
	_apply_hitbox_for_costume(current_costume)

func _setup_hitbox() -> void:
	_hitbox_area = get_node_or_null("HitboxArea") as Area2D
	if _hitbox_area != null:
		return
	_hitbox_area = Area2D.new()
	_hitbox_area.name = "HitboxArea"
	_hitbox_area.collision_layer = 1
	_hitbox_area.collision_mask = 1
	_hitbox_area.monitoring = true
	_hitbox_area.monitorable = true
	_hitbox_area.input_pickable = true
	add_child(_hitbox_area)
	_hitbox_area.input_event.connect(_on_hitbox_input_event)

func _on_hitbox_input_event(_vp: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		trigger_hats(Trigger.CLICKED)

func _apply_hitbox_for_costume(idx: int) -> void:
	if _hitbox_area == null or costumes.size() <= idx:
		return
	var c := costumes[idx]

	var target_polys: Array[PackedVector2Array] = []
	if not c.hitbox_polygons.is_empty():
		target_polys = c.hitbox_polygons
	elif c.hitbox_polygon.size() >= 3:
		target_polys = [c.hitbox_polygon]
	elif c.texture != null:
		var res := maxf(c.bitmap_resolution, 1.0)
		var sz := c.texture.get_size() / res
		var rc := c.rotation_center / res
		target_polys = [PackedVector2Array([
			Vector2(-rc.x, -rc.y), Vector2(sz.x - rc.x, -rc.y),
			Vector2(sz.x - rc.x, sz.y - rc.y), Vector2(-rc.x, sz.y - rc.y)])]

	var existing_shapes: Array[CollisionPolygon2D] = []
	for child in _hitbox_area.get_children():
		if child is CollisionPolygon2D:
			existing_shapes.append(child)

	for i in target_polys.size():
		var shape_node: CollisionPolygon2D
		if i < existing_shapes.size():
			shape_node = existing_shapes[i]
		else:
			shape_node = CollisionPolygon2D.new()
			shape_node.name = "HitboxShape" if i == 0 else "HitboxShape_%d" % i
			_hitbox_area.add_child(shape_node)
		shape_node.polygon = target_polys[i]

	for i in range(target_polys.size(), existing_shapes.size()):
		existing_shapes[i].queue_free()

func get_hitbox_area() -> Area2D:
	return _hitbox_area

func _register_hats() -> void:
	ScratchLog.v("register_hats not defined in " + name)
	pass

func register_hat(trigger: Trigger, callable: Callable, extra: Variant = null) -> void:
	if not _hats.has(trigger):
		_hats[trigger] = []
	_hats[trigger].append({"callable": callable, "extra": extra})

func trigger_hats(trigger: Trigger, extra: Variant = null) -> void:
	ScratchLog.v("Triggering hat '" + str(trigger) + "' for: " + name)
	for entry in _hats.get(trigger, []):
		ScratchLog.v("  - Found hat: " + str(entry.callable))
		if not _matches_hat_extra(entry.extra, extra):
			continue
		ScratchLog.v("    > Launching hat")
		_launch_hat(entry.callable)

func _matches_hat_extra(expected: Variant, actual: Variant) -> bool:
	if expected == null:
		return true
	if actual == null:
		return false
	if expected == actual:
		return true
	if expected is Dictionary and actual is Dictionary:
		var expected_dict: Dictionary = expected
		var actual_dict: Dictionary = actual
		for key in expected_dict.keys():
			if not actual_dict.has(key):
				return false
			if actual_dict[key] != expected_dict[key]:
				return false
		return true
	return false

func _launch_hat(callable: Callable) -> void:
	var id := _next_script_id
	_next_script_id += 1
	var ctx := ScriptContext.new(self, _generation, id)
	_active_scripts[id] = ctx
	await callable.call(ctx)
	release_script(ctx)

func stop_all_scripts() -> void:
	_generation += 1
	_active_scripts.clear()


func stop_other_scripts(current: ScriptContext) -> void:
	for id in _active_scripts:
		if id != current.script_id:
			_active_scripts[id].cancel_self()


func clear_effects() -> void:
	#_set_effect("ghost", 0.0)
	#_set_effect("color", 0.0)
	#_set_effect("pixelate", 0.0)
	#_set_effect("fisheye", 0.0)
	#_set_effect("whirl", 0.0)
	#_set_effect("brightness", 0.0)
	#_set_effect("mosaic", 0.0)
	pass

func release_script(ctx: ScriptContext) -> void:
	_active_scripts.erase(ctx.script_id)

func _apply_visible() -> void:
	visible = scratch_visible

func _spawn_clone() -> ScratchSprite:
	if not _can_spawn_clone(): return null
	var proj := get_scratch_project()
	var clone: ScratchSprite
	if scene_file_path != "":
		clone = (load(scene_file_path) as PackedScene).instantiate()
	else:
		clone = duplicate(DUPLICATE_SCRIPTS | DUPLICATE_GROUPS)
	clone.is_clone = true
	clone._clone_origin = self
	clone.name = "%s_clone_%d" % [name, proj.next_clone_id()]
	clone.position = position
	clone.direction = direction
	clone.rotation_style = rotation_style
	clone.current_costume = current_costume
	clone.scratch_visible = scratch_visible
	clone.scratch_size = scratch_size
	clone.scratch_volume = scratch_volume
	clone.draggable = draggable
	get_parent().add_child(clone)
	clone._on_becoming_clone(self)
	ScratchLayers.place_behind(clone, self)
	proj.register_sprite(clone)
	proj.clone_count += 1
	clone.trigger_hats(Trigger.CLONE_START)
	return clone

func _on_becoming_clone(src: ScratchSprite) -> void:
	_copy_locals_from(src)
	looks.copy_state_from(src.looks)
	motion._apply_rotation_style()

func _copy_locals_from(_src: ScratchSprite) -> void:
	pass

func _remove_clone() -> void:
	if not is_clone: return
	stop_all_scripts()
	var proj := get_scratch_project()
	if proj:
		proj.unregister_sprite(self)
		proj.clone_count = maxi(0, proj.clone_count - 1)
	hide()
	queue_free()


func _can_spawn_clone() -> bool:
	var proj := get_scratch_project()
	if proj and proj.infinite_clones:
		return true
	var count := proj.clone_count if proj else 0
	var limit := proj.max_clones if (proj and "max_clones" in proj) else CLONE_LIMIT
	return count < limit

func _event_broadcast_and_wait(ctx: ScriptContext, bc_name: String) -> void:
	var proj := get_scratch_project()
	if proj == null: return
	proj.broadcast(bc_name)
	await get_tree().process_frame
	while not ctx.cancelled():
		var busy := false
		for s in proj.get_sprites():
			for id in s._active_scripts:
				if s._active_scripts[id] != ctx:
					busy = true
					break
			if busy: break
		if not busy: break
		await get_tree().process_frame

static func _scratch_random(lo, hi) -> Variant:
	var a := S.num(lo)
	var b := S.num(hi)
	if a == floor(a) and b == floor(b):
		var lo_i := int(a)
		var hi_i := int(b)
		if lo_i > hi_i:
			var t := lo_i
			lo_i = hi_i
			hi_i = t
		return randi_range(lo_i, hi_i)
	return randf_range(min(a, b), max(a, b))


func _cloud_set(var_name: String, _value: Variant = null) -> void:
	_cloud_sync(var_name)


func _apply_cloud_value(var_name: String, value: String) -> void:
	if not cloud_var_map.has(var_name):
		return
	var gd_name: String = cloud_var_map[var_name]
	set(gd_name, _coerce_cloud_value(value))


static func _coerce_cloud_value(v: String) -> Variant:
	if v.is_valid_float():
		var f := v.to_float()
		if f == floor(f) and absf(f) < 9.0e15:
			return int(f)
		return f
	return v

func _cloud_sync(cloud_name: String) -> void:
	var proj := get_scratch_project()
	if proj: proj.cloud_mark_dirty(cloud_name)

func read_cloud(cloud_name: String) -> Variant:
	return get(cloud_var_map[cloud_name]) if cloud_var_map.has(cloud_name) else null


func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		var key_name := _scratch_key_name(event.keycode)
		if key_name != "":
			trigger_hats(Trigger.KEY_PRESSED, key_name)
		trigger_hats(Trigger.KEY_PRESSED, "any")


static func _scratch_key_name(kc: int) -> String:
	match kc:
		KEY_SPACE: return "space"
		KEY_ENTER, KEY_KP_ENTER: return "enter"
		KEY_UP: return "up arrow"
		KEY_DOWN: return "down arrow"
		KEY_LEFT: return "left arrow"
		KEY_RIGHT: return "right arrow"
		KEY_TAB: return "tab"
		KEY_ESCAPE: return "escape"
		KEY_BACKSPACE: return "backspace"
		KEY_DELETE: return "delete"
		KEY_SHIFT: return "shift"
		KEY_CTRL: return "control"
		KEY_ALT: return "alt"
		KEY_CAPSLOCK: return "caps lock"
	if kc >= KEY_A and kc <= KEY_Z:
		return char(kc).to_lower()
	if kc >= KEY_0 and kc <= KEY_9:
		return char(kc)
	return ""