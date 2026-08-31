extends Node

const LABEL_SETTINGS = preload("res://assets/Label_Settings.tres")

const COLORS = {
	"Burning": Color.ORANGE,
	"Blood Syphon": Color.RED,
	"DamageUp": Color.ORANGE,
	"damage": Color("#FFF"),
	"crit": Color("#B22"),
	"heal": Color(0.313, 1.0, 0.0, 1.0),
	"zero": Color("#FFF8"),
	"blocked": Color(0.5, 0.85, 1.0),
	"san_damage": Color(0.7, 0.4, 1.0),
	"san_heal": Color(0.9, 0.6, 1.0),
}

const RAND_OFFSET := 30  # Max pixels of random spread


func display_effect(status: StatusEffect, anchor: Node2D, source_position: Vector2, wore_off: bool = false) -> void:
	if not anchor:
		return

	var text: String
	var color: Color
	var font_size: int = 30

	if status is BloodSyphon:
		text = "Blood Syphon"
		color = COLORS["Blood Syphon"]
	elif status is DamageUP:
		text = "Damage Up"
		color = COLORS["DamageUp"]
	elif status is Regeneration:
		text = "Regeneration"
		color = COLORS["heal"]
	elif status is Concussed:
		text = "Concussed"
		color = Color.REBECCA_PURPLE
	else:
		return

	_spawn_label(text, color, font_size, anchor, source_position - Vector2(150, -150), wore_off)


func display_number(value: int, anchor: Node2D, source_position: Vector2, is_crit: bool = false) -> void:
	if not anchor:
		return

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
	_spawn_label(text, color, font_size, anchor, source_position + offset, false)


func display_healing_number(value: int, anchor: Node2D, source_position: Vector2) -> void:
	if not anchor:
		return

	var color := COLORS["heal"] if value > 0 else COLORS["zero"]
	var offset := Vector2(randf_range(-RAND_OFFSET, RAND_OFFSET), randf_range(-RAND_OFFSET * 0.5, RAND_OFFSET * 0.5))
	_spawn_label("+" + str(value), color, 30, anchor, source_position + offset, true)


func display_san_number(value: int, anchor: Node2D, source_position: Vector2, is_heal: bool = false) -> void:
	if not anchor:
		return

	var color := COLORS["san_heal"] if is_heal else COLORS["san_damage"]
	var text := ("+" if is_heal else "") + str(value)
	var offset := Vector2(randf_range(-RAND_OFFSET, RAND_OFFSET), randf_range(-RAND_OFFSET * 0.5, RAND_OFFSET * 0.5))
	_spawn_label(text, color, 28, anchor, source_position + offset, is_heal)


func _spawn_label(text: String, color: Color, font_size: int, anchor: Node2D, position: Vector2, floats_up: bool) -> void:
	var number := Label.new()
	number.text = text
	number.z_as_relative = false
	number.z_index = 500
	number.label_settings = LABEL_SETTINGS.duplicate()
	number.label_settings.font_color = color
	number.label_settings.font_size = font_size * 2
	number.label_settings.outline_size = 1
	number.modulate.a = 0.0

	anchor.add_child(number)
	
	number.top_level = true 
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
