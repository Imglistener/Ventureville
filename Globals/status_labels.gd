extends Node


const COLORS := {
	"Burning": Color.ORANGE,
	"Blood Syphon": Color.RED,
	"DamageUp": Color.ORANGE,
	"Regeneration": Color(0.313, 1.0, 0.0, 1.0),
	"Concussed": Color.REBECCA_PURPLE,
	"Condition": Color.WHITE,
}

const FONT_SIZE := 30
const LABEL_OFFSET := Vector2.ZERO  # applied to source_position


func display_effect(status: Resource, anchor: Node2D, source_position: Vector2, wore_off: bool = false) -> void:
	if not anchor:
		return
	var text: String
	var color: Color

	if status is BloodSyphon:
		text = "Blood Syphon"
		color = COLORS["Blood Syphon"]
	elif status is DamageUP:
		text = "Damage Up"
		color = COLORS["DamageUp"]
	elif status is Regeneration:
		text = "Regeneration"
		color = COLORS["Regeneration"]
	elif status is Concussed:
		text = "Concussed"
		color = COLORS["Concussed"]
	elif status is BattleCondition:
		text = status.condition_name.to_upper()
		color = COLORS["Condition"]
	else:
		return

	_play_vfx(status, anchor)
	FloatingLabel.spawn(text, color, FONT_SIZE, anchor, source_position + LABEL_OFFSET, wore_off)


func _play_vfx(status: Resource, anchor: Node2D) -> void:
	var vfx := StatusVisualPlay.new()
	if status is StatusEffect:
		vfx.icon = status.effect_texture
		vfx.activate(anchor)
	elif status is BattleCondition:
		vfx.icon = status.condition_texture
		vfx.activate(anchor)
