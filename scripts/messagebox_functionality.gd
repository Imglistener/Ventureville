class_name Messagebox extends Node

signal animated_out

@onready var options: HBoxContainer = $"../ConfirmationMargin/VBoxContainer/options"
@onready var confirmation_menu: PanelContainer = $".."

@export var notice : String
@export_multiline var message: String

@export var OFFSET: Vector2

func _ready() -> void:
	_connect_signals()

func _connect_signals() -> void:
	var option_btns = options.get_children()
	for btn in option_btns:
		if btn is Button:
			match btn.name:
				"No":
					btn.pressed.connect(_option_no)
				"Yes":
					btn.pressed.connect(_option_yes)


func _option_no() -> void:
	for btn in options.get_children():
		if btn is Button:
			btn.disabled = true
	animate_out()
	await get_tree().process_frame
	
func animate_in() -> void:
	for btn in options.get_children():
		if btn is Button:
			btn.disabled = false
	var t1 = get_tree().create_tween().tween_property(confirmation_menu, "modulate", Color(1.0, 1.0, 1.0, 1.0), 0.3).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_LINEAR)
	var t2 = get_tree().create_tween().tween_property(confirmation_menu, "global_position", confirmation_menu.global_position - OFFSET, 0.3).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_LINEAR)

func _option_yes() -> void:
	get_tree().quit()

func animate_out() -> void:
	var t1 = get_tree().create_tween().tween_property(confirmation_menu, "global_position", confirmation_menu.global_position + OFFSET, 0.3).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_LINEAR)
	var t2 = get_tree().create_tween().tween_property(confirmation_menu, "modulate", Color(0.0, 0.0, 0.0, 0.0), 0.3).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_LINEAR)
	await t2.finished
	animated_out.emit()
