class_name EndTurnButton
extends TextureButton

var tooltip_tween : Tween

@onready var control_base: Control = $Control
func show_tooltip() -> void:
	if control_base.is_visible_in_tree():
		return
	else:
		control_base.show()

	if tooltip_tween:
		tooltip_tween.kill()
	tooltip_tween = create_tween()
	tooltip_tween.tween_property(control_base, 'modulate', Color(1.0, 1.0, 1.0, 1.0), 0.2).set_ease(Tween.EASE_IN)
	await tooltip_tween.finished
	tooltip_tween = null
func hide_tooltip() -> void:
	if not control_base.is_visible_in_tree():
		return
	if tooltip_tween:
		tooltip_tween.kill()

	tooltip_tween = create_tween()
	tooltip_tween.tween_property(control_base, 'modulate', Color(0.0, 0.0, 0.0, 0.0), 0.2).set_ease(Tween.EASE_IN)
	await tooltip_tween.finished 
	tooltip_tween = null
	control_base.hide()
