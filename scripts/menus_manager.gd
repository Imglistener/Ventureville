class_name MenusManager extends Node
@onready var dialogue_node: NinePatchRect = $"../../Control_Layer/Control_Base/Base_Margin/StandbyContainer/dialogue-node"
@onready var standby_menu: NinePatchRect = $"../../Control_Layer/Control_Base/Base_Margin/StandbyContainer/Background"
@onready var enemy_stat_manager: Stat_Manager = $"../EnemyStatManager"
@onready var player_stat_manager: Stat_Manager = $"../PlayerStatManager"
@onready var hand: CardHand = $"../../Control_Layer/Control_Base/Base_Margin/StandbyContainer/HandLayer/Hand"
@onready var phase_manager: PhaseManager = $"../PhaseManager"
@onready var AP: TextureRect = $"../../Control_Layer/Control_Base/AP_Background"
@onready var mana_ui: Mana_UI = $"../../Control_Layer/Control_Base/Mana_UI"
@onready var deck_pile: TextureButton = $"../../Node2D_Layer/DeckPile"
@onready var discard_pile: TextureButton = $"../../Node2D_Layer/DiscardPile"
@onready var end_turn: TextureButton = $"../../Control_Layer/Control_Base/End Turn"
@onready var toolbar_container: Toolbar = $"../../Control_Layer/Control_Base/toolbar_container"
@onready var pause_menu: PauseMenu = $"../../Control_Layer/Pause Layer/Pause Menu"
@onready var pause_blur: ColorRect = $"../../Control_Layer/Pause Layer/Pause Blur"
@onready var turn_counter: Label = $"../../Control_Layer/TurnCounter"
@onready var items_menu: ItemsMenu = $"../../Control_Layer/Control_Base/ItemsMenu"
@onready var Return: TextureButton = $"../../Control_Layer/Control_Base/Return"
@onready var enemy_manager: Node = $"../EnemyManager"

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
	if not pause_menu.resume.pressed.is_connected(_resume_game):
		pause_menu.resume.pressed.connect(_resume_game)
	if not toolbar_container.pause.pressed.is_connected(_pause_game):
		toolbar_container.pause.pressed.connect(_pause_game)
	if not standby_menu.items.pressed.is_connected(_on_items_pressed):
		standby_menu.items.pressed.connect(_on_items_pressed)
	if not Return.pressed.is_connected(_on_return_pressed):
		Return.pressed.connect(_on_return_pressed)
	phase_manager.connect_signals()
	setup_toolbar_display()

func handle_blur(paused: bool) -> void:
	var t = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
	t.tween_property(pause_blur.material, "shader_parameter/blur_amount", 0.0 if paused else 2.0, 0.4)
	await t.finished
func _resume_game()-> void:
	get_tree().paused = false
	pause_menu.visible = false
	pause_blur.mouse_filter = Control.MOUSE_FILTER_IGNORE
	handle_blur(true)
	
func _pause_game()-> void:
	get_tree().paused = true
	pause_menu.visible = true
	pause_blur.mouse_filter = Control.MOUSE_FILTER_STOP
	handle_blur(false)
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
	to_hide.hide()

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
	
func splash_out(node: Node, direction: Vector2, distance: float, duration: float = 0.3) -> void:
	var start_pos: Vector2 = node.position
	var target_pos: Vector2 = start_pos + direction.normalized() * distance
	

	var tween := create_tween()
	tween.set_parallel(true)
	tween.tween_property(node, "position", target_pos, duration)\
		.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween.tween_property(node, "modulate:a", 0.0, duration)\
		.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	await tween.finished
	node.hide()
	node.position = start_pos
	
func splash_in(node: Node, direction: Vector2, distance: float, duration: float = 0.3) -> void:
	node.show()
	var target_pos: Vector2 = node.position
	var start_pos: Vector2 = target_pos - direction.normalized() * distance

	node.position = start_pos
	node.modulate.a = 0.0

	var tween := create_tween()
	tween.set_parallel(true)
	tween.tween_property(node, "position", target_pos, duration)\
		.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	tween.tween_property(node, "modulate:a", 1.0, duration)\
		.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)

	await tween.finished

func _input(event: InputEvent) -> void:
	if not dialogue_node.visible:
		return
	
	if event.is_action_pressed("interact") or \
	   (event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed):
		Dialogue_manager.on_menus_manager_advance_dialogue()
		get_viewport().set_input_as_handled()


func _on_items_pressed() -> void:
	fade_node(standby_menu, false)
	items_menu.show()
	splash_in(items_menu, Vector2.UP, 250, 0.5)
	splash_in(Return, Vector2.LEFT, 250, 0.5)
	splash_in(AP, Vector2.LEFT, 400, 0.5)
	
	await node_visible

func _on_return_pressed() -> void:
	splash_out(items_menu, Vector2.DOWN, 250, 0.5)
	splash_out(Return, Vector2.RIGHT, 250, 0.5)
	show_node(standby_menu)
	splash_out(AP, Vector2.RIGHT, 400, 0.5)
	await node_visible

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
	turn_counter.animate_turn_label(new_text)
			
func PhaseUI_active(phase : PhaseManager.Phases) -> void:
	match phase:
		PhaseManager.Phases.PlayerStandbyStart:
			_Show_Standby_Menu()
			_update_turn_label(phase)
		PhaseManager.Phases.PlayerStandbyEnd:
			phase_manager.call_deferred('advance_to_next_phase')
		PhaseManager.Phases.PlayerBattleStart:
			splash_in(end_turn, Vector2.LEFT, 300, 0.5)
			end_turn.disabled = false
			for view in enemy_manager.get_enemy_views():
				view.enemy_view.disabled = false
			transition_to(hand, standby_menu)
			splash_in(AP, Vector2.LEFT, 400, 0.5)
			splash_in(mana_ui, Vector2.RIGHT, 300, 0.5)
			splash_in(deck_pile, Vector2.RIGHT, 300, 0.5)
			splash_in(discard_pile, Vector2.RIGHT, 300, 0.5)
			await node_visible
			hand.start_turn() 
		PhaseManager.Phases.PlayerBattleEnd:
			end_turn.disabled = true
			splash_out(end_turn, Vector2.RIGHT, 300, 0.5)
			for view in enemy_manager.get_enemy_views():
				view.enemy_view.disabled = false
			hand.clear_hand()
			splash_out(AP, Vector2.RIGHT, 400, 0.5)
			splash_out(mana_ui, Vector2.LEFT, 300, 0.5)
			splash_out(deck_pile, Vector2.LEFT, 300, 0.5)
			splash_out(discard_pile, Vector2.LEFT, 300, 0.5)
			splash_out(standby_menu, Vector2.DOWN, 300, 0.5)
		PhaseManager.Phases.EnemyStandbyStart:
			_update_turn_label(phase)
		PhaseManager.Phases.EnemyStandbyEnd:
			_update_turn_label(phase) 
		PhaseManager.Phases.EnemyBattleStart:
			pass  
		PhaseManager.Phases.EnemyBattleEnd:
			pass 
	
		
	
	
