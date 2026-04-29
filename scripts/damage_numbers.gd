extends Node

func display_number(value: int, is_from_player: bool, source_position: Vector2, is_crit: bool = false) -> void:
	var number = Label.new()
	number.text = str(-value)
	number.z_index = 10
	number.label_settings = preload("res://assets/Label_Settings.tres").duplicate()

	var color = "#FFF"
	if is_crit:
		color = "#B22"
	if value == 0:
		color = "#FFF8"
	number.label_settings.font_color = color
	number.label_settings.font_size = 30
	number.label_settings.outline_size = 1

	var anchor: Node2D
	if is_from_player:
		anchor = get_tree().get_nodes_in_group('DamageNumbers')[1]
	else:
		anchor = get_tree().get_nodes_in_group('DamageNumbers')[0]

	anchor.add_child(number)
	number.global_position = source_position  # Use the passed-in position

	await get_tree().process_frame
	number.pivot_offset = number.size / 2

	var start_y = number.position.y
	var tween = get_tree().create_tween()
	tween.set_parallel(true)
	tween.tween_property(number, "position:y", start_y - 21, 0.25).set_ease(Tween.EASE_OUT)
	tween.tween_property(number, "position:y", start_y, 0.5).set_ease(Tween.EASE_IN).set_delay(0.30)
	tween.tween_property(number, "scale", Vector2.ZERO, 0.25).set_ease(Tween.EASE_IN).set_delay(0.5)
	await tween.finished
	number.queue_free()

func display_healing_number(value: int, is_from_player: bool, source_position: Vector2) -> void:
	var number = Label.new()
	number.text = str(+ value)
	number.z_index = 10
	number.label_settings = preload("res://assets/Label_Settings.tres").duplicate()

	var color = Color(0.313, 1.0, 0.0, 1.0)
	if value == 0:
		color = "#FFF8"
	number.label_settings.font_color = color
	number.label_settings.font_size = 30
	number.label_settings.outline_size = 1

	var anchor: Node2D
	if is_from_player:
		anchor = get_tree().get_nodes_in_group('DamageNumbers')[1]
	else:
		anchor = get_tree().get_nodes_in_group('DamageNumbers')[0]

	anchor.add_child(number)
	number.global_position = source_position  

	await get_tree().process_frame
	number.pivot_offset = number.size / 2

	var start_y = number.position.y
	var tween = get_tree().create_tween()
	tween.set_parallel(true)
	tween.tween_property(number, "position:y", start_y + 21, 0.25).set_ease(Tween.EASE_OUT)
	tween.tween_property(number, "position:y", start_y, 0.5).set_ease(Tween.EASE_IN).set_delay(0.30)
	tween.tween_property(number, "scale", Vector2.ZERO, 0.25).set_ease(Tween.EASE_IN).set_delay(0.5)
	await tween.finished
	number.queue_free()
