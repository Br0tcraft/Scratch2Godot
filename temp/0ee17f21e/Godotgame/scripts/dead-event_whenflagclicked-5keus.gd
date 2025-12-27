extends Node2D

var main = ""
var object = ""
var animation = ""
var mat = ""
# clone meta (set when creating a clone):
var __is_clone: bool = false
var __clone_id: int = 0
var spin = 0
var times = 0
var rotate = 0
var Ynew = 0
var Xnew = 0
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

		secs = correctur.ms(op.rand("3","10"), "float", "res://scripts/dead-event_whenflagclicked-5keus.gd", "wait (!) secs")
		await get_tree().create_timer(secs).timeout

		Xnew = correctur.ms(op.rand("-240","240"), "float", "res://scripts/dead-event_whenflagclicked-5keus.gd", "go to x:(!) y:()")
		Ynew = correctur.ms("180", "float", "res://scripts/dead-event_whenflagclicked-5keus.gd", "go to x:() y:(!)")
		object.position = Vector2(Xnew, Ynew * -1.0)

		object.show()

		object.direction = correctur.ms("90", "float", "res://scripts/dead-event_whenflagclicked-5keus.gd", "point in direction (!)")
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

		times = correctur.ms("72", "float", "res://scripts/dead-event_whenflagclicked-5keus.gd", "repeat (): {}")
		for _j in int(times):

			Ynew = correctur.ms("-5", "float", "res://scripts/dead-event_whenflagclicked-5keus.gd", "change y by (!)")
			object.position.y -= Ynew

			spin = correctur.ms(op.mul(op.rand(op.mul(op.mod((object.position.y * -1),"10"),"-1"),op.mod((object.position.y * -1),"10")),"2"), "float", "res://scripts/dead-event_whenflagclicked-5keus.gd", "turn right (!)")
			object.direction += spin
			object.direction = op.rotate(object.direction)
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

			await get_tree().process_frame

		await get_tree().process_frame

	await get_tree().process_frame
