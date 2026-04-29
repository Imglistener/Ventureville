extends Node2D
@onready var bang: AnimatedSprite2D = $Bang
@onready var buildup: AnimatedSprite2D = $Buildup
@onready var claw: AnimatedSprite2D = $Claw
@onready var animation_player: AnimationPlayer = $AnimationPlayer

func _ready() -> void:
	animation_player.play("BloodClaw")
