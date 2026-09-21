class_name FloatingLabel
extends RefCounted


const LABEL_SETTINGS := preload("res://assets/Label_Settings.tres")


static func spawn(text: String, color: Color, font_size: int, anchor: Node2D, global_pos: Vector2, floats_up: bool) -> void:
	if not is_instance_valid(anchor) or not anchor.is_inside_tree():
		return

	var label := Label.new()
	label.text = text
	label.z_as_relative = false
	label.z_index = 500
	label.label_settings = LABEL_SETTINGS.duplicate()
	label.label_settings.font_color = color
	label.label_settings.font_size = font_size * 2
	label.label_settings.outline_size = 1
	label.modulate.a = 0.0

	anchor.add_child(label)
	label.top_level = true
	label.global_position = global_pos

	# One frame so the label has a size before we compute its pivot.
	await anchor.get_tree().process_frame
	if not is_instance_valid(label):
		return
	label.pivot_offset = label.size / 2

	var start_y := label.position.y
	var travel := -40.0 if floats_up else 40.0
	label.scale = Vector2(0.3, 0.3)

	var tween := label.create_tween().set_parallel(true)
	# Zoom in + fade in
	tween.tween_property(label, "scale", Vector2.ONE, 0.2).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	tween.tween_property(label, "modulate:a", 1.0, 0.15).set_ease(Tween.EASE_OUT)
	# Drift
	tween.tween_property(label, "position:y", start_y + travel, 0.5).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUART)
	# Fade out after a short hold
	tween.tween_property(label, "modulate:a", 0.0, 0.4).set_ease(Tween.EASE_IN).set_delay(0.35)

	tween.finished.connect(label.queue_free)
