extends Node

var _shown: Dictionary = {}

const COLORS := {
	"Burning": Color.ORANGE,
	"Blood Syphon": Color.RED,
	"DamageUp": Color.ORANGE,
	"Regeneration": Color(0.313, 1.0, 0.0, 1.0),
	"Concussed": Color.REBECCA_PURPLE,
	"Condition": Color.WHITE,
	"SanguineShell": Color(0.85, 0.1, 0.2),
	"DamageDown": Color(0.6, 0.5, 0.9),
	"Stalking": Color(1.0, 0.55, 0.1),
	"Charging": Color(1.0, 0.4, 0.1),
	"Stunned": Color(0.94, 0.9, 0.55),
	"Horrified": Color(0.627, 0.361, 0.839),

}

const FONT_SIZE := 30
const LABEL_OFFSET := Vector2.ZERO  # applied to source_position


func display_effect(status: Resource, anchor: Node2D, source_position: Vector2, wore_off: bool = false) -> void:
	if not anchor:
		return
	var _shown: Dictionary = {}
   # inside display_effect, after the null check:
	var key := "%s_%d" % [status.get_script().resource_path, anchor.get_instance_id()]
	var frame := Engine.get_process_frames()
	if _shown.get(key, -1) == frame:
		return
	_shown[key] = frame
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
	elif status is SanguineShell:
		text = "Sanguine Shell"
		color = COLORS["SanguineShell"]
	elif status is DamageDown:
		text = "Damage Down"
		color = COLORS["DamageDown"]
	elif status is BattleCondition:
		text = status.condition_name.to_upper()
		color = COLORS["Condition"]
	elif status is StalkingEffect:
		text = "Stalking"
		color = COLORS["Stalking"]
	elif status is Burning:
		text = "Burning"
		color = COLORS["Burning"]
	elif status is Charging:
		text = "Charging!"
		color = COLORS["Charging"]
	elif status is Stunned:
		text = "Stunned"
		color = COLORS["Stunned"]
	elif status is Horrified:
		text = "Horrified"
		color = COLORS["Horrified"]
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
