class_name CardUI
extends TextureRect

@export var card_data : Card 
@export var HoverSFX	: AudioStream
@export var clickedSFX	: AudioStream
@export var aimingSFX	: AudioStream

signal ReparentRequest(card: CardUI)

@onready var is_playable: ColorRect = $IsPlayable

@onready var card_name: Label = $CardName
@onready var card_type: Label = $CardType
@onready var card_icon: TextureRect = $CardIcon
@onready var card_effect: RichTextLabel = $CardEffect
@onready var drop_point_detector: Area2D = $DropPointDetector
@onready var card_state_manager: CardStateManager = $CardStateManager
@onready var sfx: AudioStreamPlayer = $SFX
@onready var cost: Label = $TextureRect/MarginContainer/APCost
@onready var mp_cost: Label = $TextureRect2/MarginContainer/MPCost

var player_stats: CharacterInstance
var drag_offset: Vector2
var parent : Node2D
var targets: Array[Node] = []
var tween: Tween
var card_dragging : bool = false
var card_targeting: bool = false
var original_scale := self.scale
var is_colliding_card: bool
var cards_colliding:= []
var hand_position: Vector2
var hand_rotation: float
var hand_position_set: bool = false

func _ready() -> void:
	card_name.text = str(card_data.name)
	card_type.text = str(card_data.Type.keys()[card_data.type])
	card_effect.text = str(card_data.Description)
	cost.text = str(card_data.ap_cost)
	mp_cost.text = str(card_data.mp_cost)
	card_state_manager.init(self)

func _process(delta: float) -> void:
	card_state_manager.process(delta)

func play() -> void:
	if not card_data:
		return
	
	card_data.activate_card(targets, player_stats)

	queue_free()

func animate_to_hand() -> void:
	if not hand_position_set:
		return
	if tween and tween.is_running():
		tween.kill()
	tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	tween.parallel().tween_property(self, "position", hand_position, 0.3)
	tween.parallel().tween_property(self, "rotation", hand_rotation, 0.3)

func _on_mouse_exited()-> void:
	if card_dragging:
		return
	if card_targeting:
		return
	is_card_focused(false)

func is_card_focused(value: bool) -> void:
	if card_dragging == true: return
	if value:
		z_index = 100
		sfx.stream = HoverSFX
		sfx.play()
		await animate_card(0)
	else:
		z_index = get_index()              # Restore to hand stack positio
		await animate_card(1)
	
func animate_card(type: int) -> void:
	var t: Tween = create_tween()
	
	match type:
		0:
			t.tween_property(self, "scale", Vector2(0.42 , 0.42), 0.4).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		1:
			t.tween_property(self, "scale", original_scale, 0.55).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
	await t.finished

func move_card(card: CardUI, start_pos:Vector2, target_pos: Vector2, duration: float) -> void:
	var Tw: Tween = create_tween()
	Tw.tween_property(card, "position", target_pos, duration).set_trans(Tween.TRANS_CUBIC).from(start_pos)
	await Tw.finished


func animate_to_position(new_position: Vector2, duration: float) -> void:
	tween = create_tween().set_trans(Tween.TRANS_CIRC).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "global_position", new_position, duration)

func _on_mouse_entered() -> void:
	if card_dragging:
		return
	if card_targeting:
		return
	is_card_focused(true)

func _input(event: InputEvent) -> void:
	card_state_manager.on_input(event)
func _on_gui_input(event: InputEvent) -> void:
	card_state_manager.on_gui_input(event)




func _on_area_2d_area_entered(area: Area2D) -> void:
	if not targets.has(area):
		targets.append(area)
		
func _on_area_2d_area_exited(area: Area2D) -> void:
	targets.erase(area)
