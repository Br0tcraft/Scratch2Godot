@tool
class_name ScratchVariableMonitor
extends Control

enum DisplayMode {
	NORMAL,
	LARGE,
	SLIDER
}
signal value_committed(value: float)
@export var accent_color := Color(1, 0.5, 0.1)
@export var slider_step := 1.0

@export var mode: DisplayMode = DisplayMode.NORMAL:
	set(value):
		mode = value
		if is_node_ready():
			_update_display_mode()

@export var variable_name: String = "my variable":
	set(value):
		variable_name = value
		if is_node_ready():
			%NormalLabel.text = variable_name
			%SliderLabel.text = variable_name

@export var slider_min: float = 0.0:
	set(value):
		slider_min = value
		if is_node_ready():
			%ScratchSlider.min_value = slider_min

@export var slider_max: float = 100.0:
	set(value):
		slider_max = value
		if is_node_ready():
			%ScratchSlider.max_value = slider_max

@export var variable_value: Variant:
	set(value):
		variable_value = value
		if is_node_ready():
			_update_value_display()


func _ready() -> void:
	_update_display_mode()
	_update_value_display()
	%ScratchSlider.value_changed.connect(_on_slider_value_changed)

func _update_display_mode() -> void:
	%Normal.visible = (mode == DisplayMode.NORMAL)
	%Large.visible = (mode == DisplayMode.LARGE)
	%Slider.visible = (mode == DisplayMode.SLIDER)

func _update_value_display() -> void:
	var formatted_text := S.str(variable_value)
	
	%NormalValue.text = formatted_text
	%LargeValue.text = formatted_text
	%SliderValue.text = formatted_text
	if formatted_text.is_valid_float():
		%ScratchSlider.set_value_no_signal(float(variable_value))

func _on_slider_value_changed(new_value: float) -> void:
	variable_value = new_value
	value_committed.emit(new_value)