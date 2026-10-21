extends ScratchSprite
var _v_my_variable: Variant = 0.0


func _scratch_get_var(id: String) -> Variant:
	match id:
		"`jEk@4|i[#Fk?(8x)AV.-my variable": return _v_my_variable
	return 0.0


func _scratch_set_var(id: String, val: Variant) -> void:
	match id:
		"`jEk@4|i[#Fk?(8x)AV.-my variable": _v_my_variable = val
	return


func _register_monitors() -> void:
	monitors.add_variable(self, "`jEk@4|i[#Fk?(8x)AV.-my variable", "_v_my_variable", "my variable", { "discrete": true, "max": 100.0, "min": 0.0, "mode": "normal", "visible": false, "x": 5, "y": 5 })


func _register_hats() -> void:
	pass

