extends Label


func animate_turn_label(new_text: String) -> void:
	text = new_text
	pivot_offset = Vector2(size.x / 2, size.y / 2)
	modulate.a = 0.0
	scale = Vector2(0.5, 0.5)
	
	# Zoom and fade in
	var tween_in := create_tween().set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT).set_parallel(true)
	tween_in.tween_property(self, "modulate:a", 1.0, 0.3)
	tween_in.tween_property(self, "scale", Vector2(1.0, 1.0), 0.3)
	
	await tween_in.finished
	await get_tree().create_timer(0.5).timeout
	
	# Zoom and fade out
	var tween_out := create_tween().set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_IN).set_parallel(true)
	tween_out.tween_property(self, "modulate:a", 0.0, 0.3)
	tween_out.tween_property(self, "scale", Vector2(1.5, 1.5), 0.3)
	
	await tween_out.finished
	scale = Vector2(1.0, 1.0)
