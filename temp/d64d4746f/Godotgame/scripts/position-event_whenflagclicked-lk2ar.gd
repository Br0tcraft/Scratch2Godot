extends Node2D

var main = ""
var object = ""
var animation = ""
var mat = ""
# clone meta (set when creating a clone):
var __is_clone: bool = false
var __clone_id: int = 0
var target_node = null
var goTo = null
func _ready() -> void:
	main = $"../../../.."
	object = $"../../.."
	animation = $"../.."
	call_deferred("_init_after_ready")

func _init_after_ready():
	mat = animation.material as ShaderMaterial

	object.hide()
	while true:

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
				correctur.print_not_existing("res://scripts/position-event_whenflagclicked-lk2ar.gd", "go to ()", str(goTo))

		await get_tree().process_frame

	await get_tree().process_frame
