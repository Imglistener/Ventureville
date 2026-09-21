extends Node
## Autoload: floating damage / healing / sanity numbers.
## Status and condition labels live in StatusLabels.

const COLORS := {
	"damage": Color("#FFF"),
	"crit": Color("#B22"),
	"heal": Color(0.313, 1.0, 0.0, 1.0),
	"zero": Color("#FFF8"),
	"blocked": Color(0.5, 0.85, 1.0),
	"san_damage": Color(0.7, 0.4, 1.0),
	"san_heal": Color(0.9, 0.6, 1.0),
}

const RAND_OFFSET := 30  # Max pixels of random spread


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

	FloatingLabel.spawn(text, color, font_size, anchor, source_position + _random_offset(), false)


func display_healing_number(value: int, anchor: Node2D, source_position: Vector2) -> void:
	if not anchor:
		return

	var color: Color = COLORS["heal"] if value > 0 else COLORS["zero"]
	FloatingLabel.spawn("+" + str(value), color, 30, anchor, source_position + _random_offset(), true)


func display_san_number(value: int, anchor: Node2D, source_position: Vector2, is_heal: bool = false) -> void:
	if not anchor:
		return

	var color: Color = COLORS["san_heal"] if is_heal else COLORS["san_damage"]
	var text := ("+" if is_heal else "") + str(value)
	FloatingLabel.spawn(text, color, 28, anchor, source_position + _random_offset(), is_heal)


func _random_offset() -> Vector2:
	return Vector2(
		randf_range(-RAND_OFFSET, RAND_OFFSET),
		randf_range(-RAND_OFFSET * 0.5, RAND_OFFSET * 0.5)
	)
