class_name InflameVFX
extends Node2D
@onready var animation_player: AnimationPlayer = $Sprite2D/FireTransitionVFX/AnimationPlayer

func play_vfx() -> void:
	scale *= 5
	position += Vector2(0, 50)
	animation_player.play("firewall")
	await animation_player.animation_finished
	queue_free()
