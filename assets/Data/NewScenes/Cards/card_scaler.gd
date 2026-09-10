extends Control
# on CardUI (the root), or a small script on CardScaler
const DESIGN_SIZE := Vector2(694.0, 1013.0)   # whatever CardVisual was originally built at

@export var display_size := DESIGN_SIZE:
	set(value):
		display_size = value
		_apply_display_scale()

@onready var card_visual: Control = $CardVisual

func _ready() -> void:
	_apply_display_scale()


func _apply_display_scale() -> void:
	if not card_visual:
		return
	custom_minimum_size = display_size
	card_visual.size = DESIGN_SIZE
	card_visual.pivot_offset = Vector2.ZERO
	card_visual.scale = display_size / DESIGN_SIZE
