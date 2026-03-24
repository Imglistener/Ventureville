extends CharacterBody2D


const SPEED = 500.0
var last_direction : Vector2 = Vector2.DOWN

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D


func _physics_process(delta: float) -> void:
	var direction := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	
	if direction != Vector2.ZERO:
		velocity = direction * SPEED
		last_direction = direction
		play_animation("walk", last_direction)

	else:
		velocity = Vector2.ZERO	
		play_animation("idle", last_direction)
	move_and_slide()

func play_animation(prefix : String, dir:Vector2) -> void:
	if dir.x > 0:
		animated_sprite.play(prefix + "_right")
	elif dir.x < 0:
		animated_sprite.play(prefix + "_left")
	elif dir.y > 0:
		animated_sprite.play(prefix + "_down")
	elif dir.y < 0:
		animated_sprite.play(prefix + "_up")
		
	
