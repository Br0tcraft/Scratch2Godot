extends Node2D
@export_group("Properties")
@export_range(-179, 180) var direction: float = -131.2549885120333
@export var stretch = Vector2i(100, 100)
@export var size = 100
var size_x = -1
@export_enum("all around", "left-right", "don't rotate") var rotation_type: String = "left-right"
@export_group("Variables")
func _on_ready() -> void:
	var animation = $Sprite
	animation.scale = Vector2(size / 100 * size_x * stretch.x / 100, size / 100 * stretch.y / 100)
	animation.rotation = deg_to_rad(direction - 90)

func is_mouse_over_hitbox() -> bool:
	var mouse_pos = get_global_mouse_position()
	return $CharacterBody2D/Area2D.get_polygon().has_point(
		$CharacterBody2D/CollisionPolygon2D.to_local(mouse_pos)
	)

func is_touching_other_sprite(other_name: String) -> bool:
	var other: Node2D = $"..".get_node_or_null(other_name)
	if other == null:
		return false
	var anim = $Sprite.animation
	var poly: CollisionPolygon2D = $Sprite/Area2D.get_node_or_null("Collision-" + anim)
	if poly == null or not poly.visible:
		return false

	var other_sprite = other.get_node("Sprite")
	var other_anim = other_sprite.animation
	var other_poly: CollisionPolygon2D = other_sprite.get_node("Area2D").get_node_or_null("Collision-" + other_anim)
	if other_poly == null or not other_poly.visible:
		return false

	var shape = ConvexPolygonShape2D.new()
	shape.points = poly.polygon

	var query = PhysicsShapeQueryParameters2D.new()
	query.shape = shape
	query.transform = poly.global_transform
	query.collide_with_areas = true
	query.collide_with_bodies = true

	var hits = get_world_2d().direct_space_state.intersect_shape(query, 32)
	var other_area = other_sprite.get_node("Area2D")

	for hit in hits:
		if hit.get("collider") == other_area:
			return true
	return false
func stop(node: Node, script_path: String) -> void:
	node.set_script(null)
	await get_tree().process_frame
	node.set_script(load(script_path))
