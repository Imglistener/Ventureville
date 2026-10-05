class_name ConfirmationMenuBase
extends PanelContainer
## Reusable yes/no confirmation dialog.
## Any system that needs "are you sure?" calls open_confirmation() with a
## message and a Callable, instead of this scene owning a specific action
## (compare to the old messagebox_functionality.gd, which only knew how to quit).

signal confirmed
signal cancelled
signal animated_out   # kept so existing hookups (e.g. buttons_manager.gd) still work

@export var notice_text: String = "Message:"
@export_multiline var default_message: String = "Are you sure?"
@export var OFFSET: Vector2 = Vector2(0, 500)

@onready var notice_label: Label = $ConfirmationMargin/VBoxContainer/Notice
@onready var message_label: Label = $ConfirmationMargin/VBoxContainer/Message
@onready var options: HBoxContainer = $ConfirmationMargin/VBoxContainer/options
@onready var yes_button: Button = $ConfirmationMargin/VBoxContainer/options/Yes
@onready var no_button: Button = $ConfirmationMargin/VBoxContainer/options/No

var _on_confirm: Callable = Callable()
var _on_cancel: Callable = Callable()
var _is_open := false


func _ready() -> void:
	notice_label.text = notice_text
	message_label.text = default_message
	yes_button.pressed.connect(_handle_yes)
	no_button.pressed.connect(_handle_no)
	visible = false


## confirm_action and cancel_action are optional. cancel_action usually isn't
## needed — "No" just closes the dialog — but it's there for cases like
## re-enabling a button that was disabled while the dialog was open.
func open_confirmation(message: String, confirm_action: Callable = Callable(), cancel_action: Callable = Callable()) -> void:
	if _is_open:
		return
	message_label.text = message
	_on_confirm = confirm_action
	_on_cancel = cancel_action
	_is_open = true
	_set_buttons_enabled(true)
	await animate_in()


func _handle_yes() -> void:
	if not _is_open:
		return
	_set_buttons_enabled(false)
	confirmed.emit()
	if _on_confirm.is_valid():
		_on_confirm.call()
	await animate_out()


func _handle_no() -> void:
	if not _is_open:
		return
	_set_buttons_enabled(false)
	cancelled.emit()
	if _on_cancel.is_valid():
		_on_cancel.call()
	await animate_out()


func _set_buttons_enabled(value: bool) -> void:
	for btn in options.get_children():
		if btn is Button:
			btn.disabled = not value


func animate_in() -> void:
	visible = true
	var t1 := get_tree().create_tween().tween_property(self, "modulate", Color(1, 1, 1, 1), 0.3) \
		.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_LINEAR)
	var t2 := get_tree().create_tween().tween_property(self, "global_position", global_position - OFFSET, 0.3) \
		.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_LINEAR)
	await t2.finished


func animate_out() -> void:
	var t1 := get_tree().create_tween().tween_property(self, "global_position", global_position + OFFSET, 0.3) \
		.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_LINEAR)
	var t2 := get_tree().create_tween().tween_property(self, "modulate", Color(0, 0, 0, 0), 0.3) \
		.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_LINEAR)
	await t2.finished
	visible = false
	_is_open = false
	animated_out.emit()
