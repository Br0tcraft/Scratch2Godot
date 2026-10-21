extends ScratchSprite


func _scratch_get_var(id: String) -> Variant:
	return 0.0


func _scratch_set_var(id: String, val: Variant) -> void:
	return


func _register_monitors() -> void:
	pass


func _register_hats() -> void:
	register_hat(Trigger.GREEN_FLAG, hat_whenflagclicked)

func hat_whenflagclicked(ctx: ScriptContext) -> void:
	while not ctx.cancelled():
		looks.hide()
		await control.wait(ctx, S.num(_scratch_random(3.0, 10.0)))
		if ctx.cancelled(): return
		motion.go_to_xy(S.num(_scratch_random(-240.0, 240.0)), S.num(180.0))
		looks.show()
		motion.point_in_direction(S.num(90.0))
		for _i_1 in int(round(S.num(72.0))):
			motion.change_y(S.num(-5.0))
			motion.turn_right(S.num((S.num(_scratch_random((S.num(fmod(S.num(motion.y_position()), S.num(10.0))) * S.num(-1.0)), fmod(S.num(motion.y_position()), S.num(10.0)))) * S.num(2.0))))
			if ctx.cancelled(): break
			await get_tree().process_frame
		await get_tree().process_frame
	return
