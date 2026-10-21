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
	motion.go_to("_random_")
	await control.wait(ctx, S.num(1.0))
	if ctx.cancelled(): return
	motion.set_rotation_style(ScratchSprite.RotationStyle.LEFT_RIGHT)
	while not ctx.cancelled():
		motion.point_towards("position")
		for _i_1 in int(round(S.num(_scratch_random(3.0, 13.0)))):
			motion.move_steps(S.num(_scratch_random(3.0, 5.0)))
			if ctx.cancelled(): break
			await get_tree().process_frame
		await control.wait(ctx, S.num(_scratch_random(0.05, 1.0)))
		if ctx.cancelled(): return
		await get_tree().process_frame
	return
