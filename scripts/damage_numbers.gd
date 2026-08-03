extends Node

const LABEL_SETTINGS = preload("res://assets/Label_Settings.tres")

const COLORS = {
	"Burning": Color.ORANGE,
	"Blood Syphon": Color.RED,
	"damage": Color("#FFF"),
	"crit": Color("#B22"),
	"heal": Color(0.313, 1.0, 0.0, 1.0),
	"zero": Color("#FFF8"),
	"blocked": Color(0.5, 0.85, 1.0),
	"san_damage": Color(0.7, 0.4, 1.0),
	"san_heal": Color(0.9, 0.6, 1.0),
}

const RAND_OFFSET := 30  # Max pixels of random spread


func display_effect(status: StatusEffect, is_from_player: bool, source_position: Vector2, wore_off: bool = false) -> void:
	var color : Color
	var text : String = str(status.status_name)
	var font_size: int = 40
	if text == "BloodSyphon":
		text = "Blood Syphon"
	var offset := Vector2(randf_range(-RAND_OFFSET, RAND_OFFSET), randf_range(-RAND_OFFSET * 0.5, RAND_OFFSET * 0.5))
	_spawn_label(text, color, font_size, is_from_player, source_position + offset, true)
	
	

func display_number(value: int, is_from_player: bool, source_position: Vector2, is_crit: bool = false) -> void:
	var color: Color
	var text: String
	var font_size := 30

	if value == 0:
		text = "BLOCKED"
		color = COLORS["blocked"]
		font_size = 22
	elif is_crit:
		text = str(value)
		color = COLORS["crit"]
		font_size = 40
	else:
		text = str(value)
		color = COLORS["damage"]

	var offset := Vector2(randf_range(-RAND_OFFSET, RAND_OFFSET), randf_range(-RAND_OFFSET * 0.5, RAND_OFFSET * 0.5))
	_spawn_label(text, color, font_size, is_from_player, source_position + offset, false)


func display_healing_number(value: int, is_from_player: bool, source_position: Vector2) -> void:
	var color := COLORS["heal"] if value > 0 else COLORS["zero"]
	var offset := Vector2(randf_range(-RAND_OFFSET, RAND_OFFSET), randf_range(-RAND_OFFSET * 0.5, RAND_OFFSET * 0.5))
	_spawn_label("+" + str(value), color, 30, is_from_player, source_position + offset, true)


func display_san_number(value: int, is_from_player: bool, source_position: Vector2, is_heal: bool = false) -> void:
	var color := COLORS["san_heal"] if is_heal else COLORS["san_damage"]
	var text := ("+" if is_heal else "") + str(value)
	var offset := Vector2(randf_range(-RAND_OFFSET, RAND_OFFSET), randf_range(-RAND_OFFSET * 0.5, RAND_OFFSET * 0.5))
	_spawn_label(text, color, 28, is_from_player, source_position + offset, is_heal)


func _spawn_label(text: String, color: Color, font_size: int, is_from_player: bool, position: Vector2, floats_up: bool) -> void:
	var number := Label.new()
	number.text = text
	number.z_index = 10
	number.label_settings = LABEL_SETTINGS.duplicate()
	number.label_settings.font_color = color
	number.label_settings.font_size = font_size * 2
	number.label_settings.outline_size = 1
	number.modulate.a = 0.0

	var group_index := 1 if is_from_player else 0
	var anchor: Node2D = get_tree().get_nodes_in_group("DamageNumbers")[group_index]
	anchor.add_child(number)
	number.global_position = position

	await get_tree().process_frame
	number.pivot_offset = number.size / 2

	var start_y := number.position.y
	var travel := -40.0 if floats_up else 40.0

	var tween := get_tree().create_tween()
	tween.set_parallel(true)

	# Zoom in from small + fade in
	number.scale = Vector2(0.3, 0.3)
	tween.tween_property(number, "scale", Vector2.ONE, 0.2).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	tween.tween_property(number, "modulate:a", 1.0, 0.15).set_ease(Tween.EASE_OUT)

	# Float upward
	tween.tween_property(number, "position:y", start_y + travel, 0.5).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUART)

	# Fade out after a short hold
	tween.tween_property(number, "modulate:a", 0.0, 0.4).set_ease(Tween.EASE_IN).set_delay(0.35)

	await tween.finished
	number.queue_free()
