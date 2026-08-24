class_name EnemyWorldAI
extends CharacterBody2D

@export var speed: float = 80.0
@export var stop_distance: float = 5.0

var _player: CharacterBody2D = null
var _is_chasing: bool = false
var _last_direction: Vector2 = Vector2.DOWN  

@onready var _anim: AnimatedSprite2D = $AnimatedSprite2D

func _physics_process(delta: float) -> void:
	if _is_chasing and is_instance_valid(_player):
		var direction = (_player.global_position - global_position)
		var distance = direction.length()

		if distance > stop_distance:
			velocity = direction.normalized() * speed
			_last_direction = direction 
			_update_animation(direction)
		else:
			velocity = Vector2.ZERO
			_play_idle()
	else:
		velocity = Vector2.ZERO
		_is_chasing = false
		_play_idle()

	move_and_slide()

func _update_animation(direction: Vector2) -> void:
	if abs(direction.x) > abs(direction.y):
		if direction.x > 0:
			_play_animation("walk_right")
		else:
			_play_animation("walk_left")
	else:
		if direction.y > 0:
			_play_animation("walk_down")
		else:
			_play_animation("walk_up")

func _play_idle() -> void:
	if abs(_last_direction.x) > abs(_last_direction.y):
		if _last_direction.x > 0:
			_play_animation("idle_right")
		else:
			_play_animation("idle_left")
	else:
		if _last_direction.y > 0:
			_play_animation("idle_down")
		else:
			_play_animation("idle_up")

func _play_animation(anim_name: String) -> void:
	if _anim.animation != anim_name:
		_anim.play(anim_name)

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is CharacterBody2D and body.is_in_group("player"):
		_player = body
		_is_chasing = true

func _on_area_2d_body_exited(body: Node2D) -> void:
	if body == _player:
		_player = null
		_is_chasing = false
