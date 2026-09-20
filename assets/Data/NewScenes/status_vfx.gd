class_name StatusConditionVFX
extends Sprite2D

@export var displayed_icon: Texture2D

@onready var animation_player: AnimationPlayer = $AnimationPlayer
const animation_name : StringName = 'StatusVFX_basic'

func set_displayed_icon(icon: Texture2D)-> void:
	displayed_icon = icon

func play_and_free() -> void:
	texture = displayed_icon
	animation_player.play(animation_name)
	await animation_player.animation_finished
	queue_free()
