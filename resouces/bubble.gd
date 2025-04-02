extends Node2D

@warning_ignore("unused_parameter")
func write(text = "Hello!", secs = 1, speech_bubble = true, font_size = 14, font_color = "#000000", border_color = "#9595958c", fill_color = "#ffffff", minimum_width = 0, maximum_width = 0, border_line_width = 0, padding_size = 0, corner_radius = 0, tail_height = 0, font_pading_percent = 0, text_lenght_limit = 0) -> void:
	'''make a speech or think bubble'''
	$Box/Seperator/text.text = text
	$secs.stop()
	if speech_bubble:
		$think.hide()
		$speech.show()
	else:
		$think.show()
		$speech.hide()
	if secs != INF:
		$secs.start(secs)
	show()


func _on_secs_timeout() -> void:
	hide()
