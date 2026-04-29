extends Node

var idle_tween : Tween
@onready var target_node = $".."
var base_scale : Vector2

func start(view: Node) -> void:
	target_node = view
	base_scale = view.scale
	_play_loop()

func stop() -> void:
	if idle_tween:
		idle_tween.kill()
	if target_node:
		target_node.scale = base_scale  # reset cleanly

func _play_loop() -> void:
	if idle_tween:
		idle_tween.kill()
	idle_tween = target_node.create_tween()
	idle_tween.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	
	var breathe_scale = base_scale * Vector2(1.02, 1.05)  # subtle x, more y
	
	idle_tween.tween_property(target_node, "scale", breathe_scale, 1.8)
	idle_tween.tween_property(target_node, "scale", base_scale, 1.8)
	idle_tween.tween_callback(_play_loop)  # loop manually
