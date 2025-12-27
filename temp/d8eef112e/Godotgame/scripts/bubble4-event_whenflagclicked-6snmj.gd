extends Node2D

var main = ""
var object = ""
var animation = ""
var mat = ""
var Ynew = 0
var times = 0
var size = 0
var target_node = null
var goTo = null
var condition = false
var costume = ""
var secs = 0
func _ready() -> void:
	main = $"../../../.."
	object = $"../../.."
	animation = $"../.."
	call_deferred("_init_after_ready")

func _init_after_ready():
	mat = animation.material as ShaderMaterial
	while true:

		object.hide()

		secs = correctur.ms(op.rand("1.1","3"), "float", "res://scripts/bubble4-event_whenflagclicked-6snmj.gd", "wait (!) secs")
		await get_tree().create_timer(secs).timeout

		main.move_child(object, 2)

		costume = correctur.ms("bubble1", "string", "res://scripts/bubble4-event_whenflagclicked-6snmj.gd", "switch costume to (!)")
		$"../..".get_node("Area2D/Collision-" + animation.animation).disabled = true
		if str(costume).is_valid_int():
			animation.play(animation.sprite_frames.get_animation_names()[int(costume) % animation.sprite_frames.get_animation_names().size()])
		elif costume in animation.sprite_frames.get_animation_names():
			animation.play(main.normalize_to_latin(str(costume)))
		$"../..".get_node("Area2D/Collision-" + animation.animation).disabled = false

		condition = correctur.ms(op.equal(op.rand("1","2"),"1"), "bool", "res://scripts/bubble4-event_whenflagclicked-6snmj.gd", "if <!> then: {} else: {}")
		if condition:

			goTo = "fish1"
			if str(goTo) == "_mouse_":
				object.position = get_global_mouse_position()
			elif str(goTo) == "_random_":
				object.position = Vector2(randf_range(get_viewport().get_visible_rect().size.x / -2, get_viewport().get_visible_rect().size.x / 2), randf_range(get_viewport().get_visible_rect().size.y / -2, get_viewport().get_visible_rect().size.y / 2))
			else:
				target_node = main.get_node_or_null(str(goTo))
				if target_node and target_node is Node2D:
					object.position = target_node.position
				else:
					correctur.print_not_existing("res://scripts/bubble4-event_whenflagclicked-6snmj.gd", "go to ()", str(goTo))

			await get_tree().process_frame

		else:

			goTo = "fish4"
			if str(goTo) == "_mouse_":
				object.position = get_global_mouse_position()
			elif str(goTo) == "_random_":
				object.position = Vector2(randf_range(get_viewport().get_visible_rect().size.x / -2, get_viewport().get_visible_rect().size.x / 2), randf_range(get_viewport().get_visible_rect().size.y / -2, get_viewport().get_visible_rect().size.y / 2))
			else:
				target_node = main.get_node_or_null(str(goTo))
				if target_node and target_node is Node2D:
					object.position = target_node.position
				else:
					correctur.print_not_existing("res://scripts/bubble4-event_whenflagclicked-6snmj.gd", "go to ()", str(goTo))

			await get_tree().process_frame

		size = correctur.ms("100", "float", "res://scripts/bubble4-event_whenflagclicked-6snmj.gd", "set size to (!)")
		if size < 0:
			size = 0
		animation.scale.x = size / 100 * object.size_x * object.stretch.x / 100
		animation.scale.y = size / 100 * object.stretch.y / 100

		object.show()

		condition = correctur.ms(op.greater((object.position.y * -1),"165"), "bool", "res://scripts/bubble4-event_whenflagclicked-6snmj.gd", "repeat until <!>: {}")
		while not(condition):
			condition = correctur.ms(op.greater((object.position.y * -1),"165"), "bool", "res://scripts/bubble4-event_whenflagclicked-6snmj.gd", "repeat until <!>: {}")

			times = correctur.ms("20", "float", "res://scripts/bubble4-event_whenflagclicked-6snmj.gd", "repeat (): {}")
			for _k in int(times):

				size = correctur.ms("1", "float", "res://scripts/bubble4-event_whenflagclicked-6snmj.gd", "change size by (!)")
				if (object.size + size) < 0:
					size = 0
				animation.scale.x += size / 100 * object.size_x * object.stretch.x / 100
				animation.scale.y += size / 100 * object.stretch.y / 100 

				Ynew = correctur.ms("2", "float", "res://scripts/bubble4-event_whenflagclicked-6snmj.gd", "change y by (!)")
				object.position.y -= Ynew

				await get_tree().process_frame

			times = correctur.ms("10", "float", "res://scripts/bubble4-event_whenflagclicked-6snmj.gd", "repeat (): {}")
			for _k in int(times):

				size = correctur.ms("-1", "float", "res://scripts/bubble4-event_whenflagclicked-6snmj.gd", "change size by (!)")
				if (object.size + size) < 0:
					size = 0
				animation.scale.x += size / 100 * object.size_x * object.stretch.x / 100
				animation.scale.y += size / 100 * object.stretch.y / 100 

				Ynew = correctur.ms("2", "float", "res://scripts/bubble4-event_whenflagclicked-6snmj.gd", "change y by (!)")
				object.position.y -= Ynew

				await get_tree().process_frame

			await get_tree().process_frame

		await get_tree().process_frame

	await get_tree().process_frame
