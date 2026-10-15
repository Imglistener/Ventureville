class_name Slash_VFX
extends Node2D

@onready var animation_player: AnimationPlayer = $AnimationPlayer


func play_vfx(vertical : bool) -> void:
	if vertical:
		animation_player.play("slash")
	else:
		animation_player.play("slash_2")
	await animation_player.animation_finished
	queue_free()
