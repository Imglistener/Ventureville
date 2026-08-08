class_name GameStateManager extends Node
@onready var defeat: Label = $"../../Control_Layer/Pause Layer/Pause Blur/Defeat"
@onready var victory: Label = $"../../Control_Layer/Pause Layer/Pause Blur/Victory"
@onready var pause_blur: ColorRect = $"../../Control_Layer/Pause Layer/Pause Blur"
@onready var menus_manager: MenusManager = $"../MenusManager"

func _ready() -> void:
	for child in get_parent().get_children():
		if child is Stat_Manager:
			if child.Entity:				
				if not child.Player:
					child.Entity.entity_died.connect(track_healthbars.bind(true).unbind(1))
				else:
					child.Player.entity_died.connect(track_healthbars.bind(false).unbind(1))
				

func handle_blur(paused: bool) -> void:
	var t = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
	t.tween_property(pause_blur.material, "shader_parameter/blur_amount", 0.0 if paused else 2.0, 0.4)
	await t.finished
	pause_blur.mouse_filter = Control.MOUSE_FILTER_STOP

func track_healthbars(Won: bool) -> void:
	await get_tree().create_timer(0.4).timeout
	if Won:
		_play_win_sequence()
	else:
		_play_lose_sequence()
	

func _play_win_sequence() -> void:
	victory.visible = true
	handle_blur(false)
	get_tree().paused = true

func _play_lose_sequence() -> void:
	defeat.visible = true
	handle_blur(false)
	get_tree().paused = true
