extends Node

@onready var color: ColorRect = $Color
@onready var state: Label = $state
@onready var card_state_manager: CardStateManager = $CardState
@onready var drop_point_detector: Area2D = $Area2D

var parent : Control
var targets: Array[Node] = []
var tween: Tween


	
func _input(event: InputEvent) -> void:
	card_state_manager.on_input(event)

func animate_to_position(new_position: Vector2, duration: float) -> void:
	tween = create_tween().set_trans(Tween.TRANS_CIRC).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "global_position", new_position, duration)


func _on_gui_input(event: InputEvent) -> void:
	card_state_manager.on_gui_input(event)


func _on_mouse_entered() -> void:
	card_state_manager.on_mouse_entered()

func _on_mouse_exited() -> void:
	card_state_manager.on_mouse_exited()


func _on_area_2d_area_entered(area: Area2D) -> void:
	if not targets.has(area):
		targets.append(area)
		
func _on_area_2d_area_exited(area: Area2D) -> void:
	targets.erase(area)
