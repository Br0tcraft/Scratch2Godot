extends Node2D

var main = ""
var object = ""
var animation = ""
var mat = ""
# clone meta (set when creating a clone):
var __is_clone: bool = false
var __clone_id: int = 0
var steps = 0
var times = 0
var lookat = ""
var secs = 0
var target_node = null
var goTo = null
func _ready() -> void:
	main = $"../../../.."
	object = $"../../.."
	animation = $"../.."
	call_deferred("_init_after_ready")

func _init_after_ready():
	mat = animation.material as ShaderMaterial

	goTo = "_random_"
	if str(goTo) == "_mouse_":
		object.position = get_global_mouse_position()
	elif str(goTo) == "_random_":
		object.position = Vector2(randf_range(get_viewport().get_visible_rect().size.x / -2, get_viewport().get_visible_rect().size.x / 2), randf_range(get_viewport().get_visible_rect().size.y / -2, get_viewport().get_visible_rect().size.y / 2))
	else:
		target_node = main.get_node_or_null(str(goTo))
		if target_node and target_node is Node2D:
			object.position = target_node.position
		else:
			correctur.print_not_existing("res://scripts/fish1-event_whenflagclicked-7vjtq.gd", "go to ()", str(goTo))

	secs = correctur.ms("1", "float", "res://scripts/fish1-event_whenflagclicked-7vjtq.gd", "wait (!) secs")
	await get_tree().create_timer(secs).timeout

	object.rotation_type = "left-right"
	if object.rotation_type == "all around":
		animation.rotation = deg_to_rad(object.direction - 90)
	elif object.rotation_type == "left-right":
		animation.rotation = 0
		if object.direction > 0:
			animation.scale.x = object.stretch.x / 100
		else:
			animation.scale.x = -1 * object.stretch.x / 100
	else:
		animation.rotation = 0
	while true:

		lookat = "position"
		if str(lookat) == "_mouse_":
			animation.look_at(get_global_mouse_position())
			object.direction  = rad_to_deg(animation.rotation) + 90
		else:
			lookat = main.get_node_or_null(str(lookat))
			if lookat and lookat is Node2D:
				animation.look_at(lookat.position)
				object.direction = op.rotate(rad_to_deg(animation.rotation) + 90)
			else:
				correctur.print_not_existing("res://scripts/fish1-event_whenflagclicked-7vjtq.gd", "point towards (!)", str(lookat))
		if object.rotation_type == "don't rotate":
			animation.rotation = 0
		elif object.rotation_type == "left-right":
			animation.rotation = 0
			if object.direction > 0:
				animation.scale.x = object.stretch.x / 100
			else:
				animation.scale.x = -1 * object.stretch.x / 100

		times = correctur.ms(op.rand("3","13"), "float", "res://scripts/fish1-event_whenflagclicked-7vjtq.gd", "repeat (): {}")
		for _j in int(times):

			steps = correctur.ms(op.rand("3","5"), "float", "res://scripts/fish1-event_whenflagclicked-7vjtq.gd", "move steps (!)")
			object.position += Vector2(cos(deg_to_rad(object.direction - 90)), sin(deg_to_rad(object.direction - 90))) * steps

			await get_tree().process_frame

		secs = correctur.ms(op.rand("0.05","1"), "float", "res://scripts/fish1-event_whenflagclicked-7vjtq.gd", "wait (!) secs")
		await get_tree().create_timer(secs).timeout

		await get_tree().process_frame

	await get_tree().process_frame
