class_name VisualEffect extends Node2D


@onready var VFXAnimationPlayer: AnimationPlayer = $Animation


func play_animation()-> void:
	VFXAnimationPlayer.play("Activate")
