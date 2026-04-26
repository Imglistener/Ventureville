extends Label


func animate_turn_label(new_text: String) -> void:
	var tween_out := create_tween().set_trans(Tween.TRANS_QUINT).set_parallel(true)
	
	# Spin and fade out current text
	tween_out.tween_property(self, "rotation_degrees", 360.0, 0.3)
	tween_out.tween_property(self, "modulate:a", 0.0, 0.25)
	
	await tween_out.finished
	
	# Swap text, reset transform and start invisible
	pivot_offset = Vector2(size.x/2, size.y/2)
	text = new_text
	rotation_degrees = -360.0
	modulate.a = 0.0
	
	# Spin and fade in new text
	var tween_in := create_tween().set_trans(Tween.TRANS_QUINT).set_parallel(true)
	tween_in.tween_property(self, "rotation_degrees", 0.0, 0.3)
	tween_in.tween_property(self, "modulate:a", 1.0, 0.3)
