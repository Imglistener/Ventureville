extends AnimatedSprite2D
@export var autostart := false

func _ready() -> void:
	if autostart:
		play('firefang')
