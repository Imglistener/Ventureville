extends TextureProgressBar

func change_value(new_value: int) -> void:
	var tween: Tween = create_tween()
	tween.tween_property(self, "value", new_value, 0.4).set_ease(Tween.EASE_OUT)
	
func _ready() -> void:
	set_meta("tooltip_desc", "Enemy Health")
