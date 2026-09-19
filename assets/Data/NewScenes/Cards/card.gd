class_name CardUI
extends MarginContainer
enum CardMode{ PLAYABLE , DISPLAYING }

@export var card_data : Card 
@export var HoverSFX	: AudioStream
@export var clickedSFX	: AudioStream
@export var aimingSFX	: AudioStream
@export var Mode : CardMode
signal ReparentRequest(card: CardUI)
signal CardClicked(card: CardUI)

@onready var is_playable: ColorRect = $CardAnchor/CardScaler/CardFrame/IsPlayable
@onready var card_scaler: Control = $CardAnchor/CardScaler

@onready var card_name: Label = $CardAnchor/CardScaler/Frame/VBoxContainer2/VBoxContainer/CardNameMargin/CardName
@onready var card_type: Label = $CardAnchor/CardScaler/Frame/VBoxContainer2/VBoxContainer/CardTypeMargin/CardType
@onready var card_icon: TextureRect = $CardAnchor/CardScaler/CardVisual/MarginContainer2/CardIcon
@onready var card_effect: RichTextLabel = $CardAnchor/CardScaler/Frame/VBoxContainer2/MarginContainer/CardEffect
@onready var drop_point_detector: Area2D = $DropPointDetector
@onready var card_state_manager: CardStateManager = $CardStateManager
@onready var sfx: AudioStreamPlayer = $SFX
@onready var cost: Label = $CardAnchor/CardScaler/CardVisual/APTexture/MarginContainer/APCost
@onready var mp_cost: Label = $CardAnchor/CardScaler/CardVisual/MPTexture/MarginContainer/MPCost
@onready var disabled_mask: TextureRect = $CardAnchor/CardScaler/disabled_mask

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
var deck_position: Vector2
var Discard_position: Vector2
var log : Log
var ControlBase : Control
var is_selected := false

var card_disabled := false
var is_displaying := false
const DESIGN_SIZE := Vector2(694.0, 1013.0)



func _ready() -> void:
	drop_point_detector.monitoring = false
	card_name.text = str(card_data.name)
	card_type.text = str(card_data.Type.keys()[card_data.type]).left(1) + str(card_data.Type.keys()[card_data.type]).right(-1).to_lower()
	card_effect.text = card_data.get_description(player_stats)
	cost.text = str(card_data.ap_cost)
	mp_cost.text = str(card_data.mp_cost)
	card_state_manager.init(self)
	manage_card_rarity()
	log = get_tree().get_first_node_in_group('Log')
	if player_stats:
		if not player_stats.Stats_Changed.is_connected(update_description):
				player_stats.Stats_Changed.connect(update_description)
	if not Events.card_cost_changed.is_connected(_on_cost_changed):
		Events.card_cost_changed.connect(_on_cost_changed)
	if ControlBase:
		if not CardClicked.is_connected(ControlBase.on_trigger_pressed):
			CardClicked.connect(ControlBase.on_trigger_pressed)
			
func _process(delta: float) -> void:
	card_state_manager.process(delta)

	
func manage_card_rarity() -> void:
	match card_data.rarity:
		Card.Rarities.Common:
			card_name.add_theme_color_override("font_color", Color.WHITE)
		Card.Rarities.Rare:
			card_name.add_theme_color_override("font_color", Color.AQUA)
		Card.Rarities.Legendary:
			card_name.add_theme_color_override("font_color", Color.GOLD)

func _on_cost_changed(card: Card) -> void:
	if card == card_data:
		update_costs()

func update_costs() -> void:
	cost.text = str(card_data.ap_cost)
	mp_cost.text = str(card_data.mp_cost)

func play() -> void:
	if not card_data:
		return
	log.text += '[br]' + card_data.LogMessage
	reset_live_preview()
	is_playable.visible = false
	card_data.activate_card(targets, player_stats)
	animate_out()
	if card_data.is_card_nullable:
		nulled()

func update_description() -> void:
	card_effect.text = card_data.get_description(player_stats)

func animate_out() -> void:
	if not deck_position or not Discard_position:
		return
	if tween and tween.is_running():
		tween.kill()
	tween = create_tween().set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC)
	tween.parallel().tween_property(self, "scale", Vector2(0.1, 0.1), 0.2)
	tween.parallel().tween_property(self, "global_position", Discard_position, 0.4)
	tween.parallel().tween_property(self, 'modulate', Color(0.0, 0.0, 0.0, 0.0), 0.4)
	tween.finished.connect(
		func():
			queue_free()
	)
	

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
	Events.card_unselected.emit(self)


	


func move_card(card: CardUI, start_pos:Vector2, target_pos: Vector2, duration: float) -> void:
	var Tw: Tween = create_tween()
	Tw.tween_property(card, "position", target_pos, duration).set_trans(Tween.TRANS_CUBIC).from(start_pos)
	await Tw.finished


func animate_to_position(new_position: Vector2, duration: float) -> void:
	if tween:
		return
	tween = create_tween().set_trans(Tween.TRANS_CIRC).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "global_position", new_position, duration)

func _on_mouse_entered() -> void:
	if card_dragging or card_targeting:
		return
	Events.card_selected.emit(self)

func _input(event: InputEvent) -> void:
	var hand = get_parent() as CardHand
	if hand and hand.is_arranging or card_disabled:
		return
	card_state_manager.on_input(event)

		
func _gui_input(event: InputEvent) -> void:
	card_state_manager.on_gui_input(event)
	if event is InputEventMouseButton:
		if event.pressed and event.button_index == MOUSE_BUTTON_LEFT and Mode == CardMode.PLAYABLE:
			CardClicked.emit(self)


func _on_area_2d_area_entered(area: Area2D) -> void:
	if not targets.has(area):
		targets.append(area)
	_update_live_preview()
	
func _on_area_2d_area_exited(area: Area2D) -> void:
	targets.erase(area)
	_update_live_preview()
func _on_display_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		CardClicked.emit(self) 

func _update_live_preview() -> void:
	if not card_data:
		return
	if targets.is_empty():
		reset_live_preview()
		return
	var live_targets := targets if card_data.is_SingleTarget() else card_data._get_targets(targets)
	card_effect.text = card_data.get_live_description(player_stats, live_targets)

func reset_live_preview() -> void:
	if not card_data:
		return
	card_effect.text = card_data.get_description(player_stats)
	Events.hide_enemy_resistances.emit()

func set_display_size(size: Vector2) -> void:
	custom_minimum_size = size
	custom_maximum_size = size
	card_scaler.size = DESIGN_SIZE
	card_scaler.pivot_offset = Vector2.ZERO
	card_scaler.scale = size / DESIGN_SIZE

func nulled() -> void:
	var Deck_Manager := get_tree().get_first_node_in_group('DeckManager') as DeckManager
	for card in Deck_Manager.CardDeck.Discard_Pile:
		if card is Card:
			if card == self.card_data:
				Deck_Manager.CardDeck.Discard_Pile.erase(card)
