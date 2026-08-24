class_name MP_Label
extends Label

signal mp_changed(value: int)

var _last_text: String = ""

func _ready() -> void:
	_last_text = text

func _process(_delta: float) -> void:
	if text != _last_text:
		_last_text = text
		if text.is_valid_int():
			mp_changed.emit(text.to_int())
