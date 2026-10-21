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
	looks.hide()
	while not ctx.cancelled():
		motion.go_to("_random_")
		await get_tree().process_frame
	return
