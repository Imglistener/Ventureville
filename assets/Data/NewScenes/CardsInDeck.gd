class_name AnimatedCountLabel extends Label

var _current_value: int = 0
var _tween: Tween

@export var reset_on_decrease: bool = false

func display(to: int) -> void:
	if to >= _current_value:
		_count(to)
	elif reset_on_decrease:
		_count_down_then_up(to)
	else:
		_count(to) # simply decrement directly
		
func _count(to: int) -> void:
	_kill_tween()
	_tween = create_tween()
	_tween.tween_method(_set_value, float(_current_value), float(to), abs(to - _current_value) * 0.04)

func _count_down_then_up(to: int) -> void:
	_kill_tween()
	_tween = create_tween()
	_tween.tween_method(_set_value, float(_current_value), 0.0, _current_value * 0.04)
	_tween.tween_callback(func(): _count(to))

func _set_value(v: float) -> void:
	var val := int(v)
	if val != _current_value:
		_current_value = val
		text = str(_current_value)
		_pulse()

func _pulse() -> void:
	var t := create_tween()
	t.tween_property(self, "scale", Vector2(1.3, 1.3), 0.05)
	t.tween_property(self, "scale", Vector2(1.0, 1.0), 0.05)

func _kill_tween() -> void:
	if _tween and _tween.is_valid():
		_tween.kill()
