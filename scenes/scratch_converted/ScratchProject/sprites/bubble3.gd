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
		await control.wait(ctx, S.num(_scratch_random(1.1, 3.0)))
		if ctx.cancelled(): return
		looks.go_to_back()
		looks.switch_costume("bubble1")
		if S.boolean(S.equals(_scratch_random(1.0, 2.0), 1.0)):
			motion.go_to("fish2")
		else:
			motion.go_to("fish3")
		looks.set_size(S.num(100.0))
		looks.show()
		while not S.boolean((S.compare(motion.y_position(), 165.0) > 0)) and not ctx.cancelled():
			for _i_2 in int(round(S.num(20.0))):
				looks.change_size(S.num(1.0))
				motion.change_y(S.num(2.0))
				if ctx.cancelled(): break
				await get_tree().process_frame
			for _i_2 in int(round(S.num(10.0))):
				looks.change_size(S.num(-1.0))
				motion.change_y(S.num(2.0))
				if ctx.cancelled(): break
				await get_tree().process_frame
			await get_tree().process_frame
		await get_tree().process_frame
	return
