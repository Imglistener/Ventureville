extends Area2D


func _input(event: InputEvent):
	if Dialogic.current_timeline != null:
		return
	
	if event is InputEventKey and event.keycode == KEY_ENTER and event.pressed:
		Dialogic.start('Artist')
		get_viewport().set_input_as_handled()
	
