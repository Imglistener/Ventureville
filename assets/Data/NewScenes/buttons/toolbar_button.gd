class_name ToolbarButton
extends TextureButton

var tooltip_tween : Tween
@onready var label: Label = $TooltipBase/PanelContainer/Label
@onready var tooltip_base: Control = $TooltipBase

func set_label_text(text : String) -> void:
	label.text = text

func _on_hover_show() -> void:
	show_tooltip()
	
func _on_hover_hide() -> void:
	hide_tooltip()
	
func show_tooltip() -> void:
	if tooltip_base.is_visible_in_tree():
		return
	else:
		tooltip_base.show()

	if tooltip_tween:
		tooltip_tween.kill()
	tooltip_tween = create_tween()
	tooltip_tween.tween_property(tooltip_base, 'modulate', Color(1.0, 1.0, 1.0, 1.0), 0.2).set_ease(Tween.EASE_IN)
	await tooltip_tween.finished
	tooltip_tween = null
func hide_tooltip() -> void:
	if not tooltip_base.is_visible_in_tree():
		return
	if tooltip_tween:
		tooltip_tween.kill()

	tooltip_tween = create_tween()
	tooltip_tween.tween_property(tooltip_base, 'modulate', Color(0.0, 0.0, 0.0, 0.0), 0.2).set_ease(Tween.EASE_IN)
	await tooltip_tween.finished 
	tooltip_tween = null
	tooltip_base.hide()
