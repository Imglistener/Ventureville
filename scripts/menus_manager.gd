class_name MenusManager extends Node
@onready var dialogue_node: NinePatchRect = $"../../Control_Layer/Control_Base/Base_Margin/StandbyContainer/dialogue-node"
@onready var standby_menu: NinePatchRect = $"../../Control_Layer/Control_Base/Base_Margin/StandbyContainer/Background"
@onready var enemy_stat_manager: Stat_Manager = $"../EnemyStatManager"
@onready var player_stat_manager: Stat_Manager = $"../PlayerStatManager"
@onready var hand: CardHand = $"../../Control_Layer/Control_Base/Base_Margin/StandbyContainer/HandLayer/Hand"
@onready var phase_manager: PhaseManager = $"../PhaseManager"
@onready var ap_bar: TextureProgressBar = $"../../Control_Layer/Control_Base/AP_Bar"
@onready var mana_ui: Mana_UI = $"../../Control_Layer/Control_Base/Mana_UI"
@onready var enemy: EnemyView = $"../../Control_Layer/Enemy"
@onready var deck_pile: TextureButton = $"../../Node2D_Layer/DeckPile"
@onready var discard_pile: TextureButton = $"../../Node2D_Layer/DiscardPile"
@onready var end_turn: Button = $"../../Control_Layer/Control_Base/End Turn"
@onready var toolbar_container: Toolbar = $"../../Control_Layer/Control_Base/toolbar_container"

var Dialogue_manager: Dialogue_Manager 
var talk: Button
var battle: Button
signal node_visible
signal input_received(event)


func transition_to(node_shown: Node, hide_node: Node = null) -> void:
	if hide_node:
		fade_node(hide_node, true)
	show_node(node_shown)

func _ready() -> void:
	if not dialogue_node.is_node_ready():
		await dialogue_node.ready
	if not standby_menu.is_node_ready():
		await standby_menu.ready
	if not talk:
		talk = standby_menu.talk
	if not battle:
		battle = standby_menu.battle
	if not Dialogue_manager:
		Dialogue_manager = dialogue_node.dialogue_manager
	if not talk.pressed.is_connected(_on_talk_pressed):
		talk.pressed.connect(_on_talk_pressed)
	if not battle.pressed.is_connected(phase_manager.advance_to_next_phase):
		battle.pressed.connect(phase_manager.advance_to_next_phase)
	if not Dialogue_manager.Dialogue_Done.is_connected(_on_dialogue_end):
		Dialogue_manager.Dialogue_Done.connect(_on_dialogue_end)
	if not phase_manager.is_node_ready():
		await phase_manager.ready
	phase_manager.connect_signals()
	setup_toolbar_display()


func setup_toolbar_display() -> void:
	var player_data: String
	player_data = player_stat_manager.Player.entity_name
	player_data += " | "
	match player_stat_manager.Player.player_class:
		CharacterInstance.PlayerClasses.BloodMagus:
			player_data += "Blood Magus"
		CharacterInstance.PlayerClasses.DarkMagus:
			player_data += "Dark Magus"
		CharacterInstance.PlayerClasses.VoiceMagus:
			player_data += "Illusionist"
		CharacterInstance.PlayerClasses.FoulTarnished:
			player_data += "Tarnished"
	
	toolbar_container.player_name.text = str(player_data)
	toolbar_container.currency.text = "Forbidden Forest" + " | " + str(player_stat_manager.Player.character_level)
func fade_node(to_hide : Node, remove_from_container: bool) -> void:
	if to_hide:
		var original_scale = to_hide.scale
		var t = create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
		t.tween_property(to_hide, "modulate:a", 0.0, 0.25)
		t.parallel().tween_property(to_hide, "scale", Vector2(0.95, 0.95), 0.25)
		await t.finished
		if to_hide:
			to_hide.scale = original_scale
	if remove_from_container:
		to_hide.visible = false

func show_node(to_show : Node) -> void:
	to_show.visible = true
	to_show.modulate.a = 0.0
	var keep_scale = to_show.scale
	to_show.scale = Vector2(0.1, 0.1)
	var t2 = create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	
	t2.tween_property(to_show, "modulate:a", 1.0, 0.3)
	t2.parallel().tween_property(to_show, "scale", keep_scale, 0.3)
	await t2.finished
	
	emit_signal("node_visible")
	

func _input(event: InputEvent) -> void:
	if not dialogue_node.visible:
		return
	
	if event.is_action_pressed("interact") or \
	   (event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed):
		Dialogue_manager.on_menus_manager_advance_dialogue()
		get_viewport().set_input_as_handled()



func _on_talk_pressed() -> void:
	Dialogue_manager.call_dialogue(enemy_stat_manager, dialogue_node.dialogue_box, player_stat_manager)
	talk.disabled = true
	transition_to(dialogue_node, standby_menu)
	await node_visible
	Dialogue_manager.on_menus_manager_advance_dialogue()
	
	
func _on_dialogue_end() -> void:
	transition_to(standby_menu, dialogue_node)
	await get_tree().process_frame
	Dialogue_manager.dialogue_box.text = ""
	Dialogue_manager.is_dialogue_done = false
	talk.disabled = false

func _Show_Standby_Menu() -> void:
	transition_to(standby_menu)
	await get_tree().process_frame

func _update_turn_label(phase: PhaseManager.Phases) -> void:
	var new_text := ""
	match phase:
		PhaseManager.Phases.PlayerStandbyStart:
			new_text = "Your Turn!"
		PhaseManager.Phases.EnemyStandbyStart , PhaseManager.Phases.EnemyStandbyEnd :
			new_text = "Enemy Turn!"
		_:
			return
	toolbar_container.turn_counter_label.animate_turn_label(new_text)
			
func PhaseUI_active(phase : PhaseManager.Phases) -> void:
	match phase:
		PhaseManager.Phases.PlayerStandbyStart:
			_Show_Standby_Menu()
			_update_turn_label(phase)
		PhaseManager.Phases.PlayerStandbyEnd:
			phase_manager.call_deferred('advance_to_next_phase')
		PhaseManager.Phases.PlayerBattleStart:
			transition_to(end_turn)
			end_turn.disabled = false
			enemy.enemy_view.disabled = false
			transition_to(hand, standby_menu)
			transition_to(ap_bar)
			transition_to(mana_ui)
			transition_to(deck_pile)
			transition_to(discard_pile)
			await node_visible
			hand.start_turn() 
		PhaseManager.Phases.PlayerBattleEnd:
			end_turn.disabled = true
			fade_node(end_turn, true)
			enemy.enemy_view.disabled = true
			for i in hand.get_children():
				fade_node(i, false)
				i.queue_free()
			fade_node(hand, false)
			fade_node(ap_bar, false)
			fade_node(mana_ui, false)
			fade_node(deck_pile, false)
			fade_node(discard_pile, false)
			fade_node(standby_menu, false)
		PhaseManager.Phases.EnemyStandbyStart:
			_update_turn_label(phase)
		PhaseManager.Phases.EnemyStandbyEnd:
			_update_turn_label(phase) 
		PhaseManager.Phases.EnemyBattleStart:
			pass  
		PhaseManager.Phases.EnemyBattleEnd:
			pass 
	
		
	
	
