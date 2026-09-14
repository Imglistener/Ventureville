class_name Dialogue_Manager extends Node
@onready var game_state_manager: GameStateManager = $"../../../../../../Functionality/GameStateManager"

var enemy_stat_manager: Stat_Manager
var player_stat_manager: Stat_Manager
var dialogue_box: RichTextLabel

var enemy_dialogue: Array
var current_message: String
var current_message_index: int = -1
var is_dialogue_done : bool = false
var speaker: String
signal Dialogue_Done

func _dialogue_logic() -> Array[DialogueLine]:
	var dialogue := game_state_manager.battle_info.get_dialogue(get_tree().get_first_node_in_group('EnemyManager').get_enemy_views().size())
	return dialogue
	
func call_dialogue(enemy: Stat_Manager, DialogueBox : RichTextLabel, Player: Stat_Manager) -> void:
	if not enemy.Entity is EnemyBattlerStats:
		return
	enemy_stat_manager = enemy
	if not game_state_manager.battle_info.is_unique_battle:
		enemy_dialogue = _dialogue_logic()
		if not dialogue_box:
			dialogue_box = DialogueBox
		if not player_stat_manager:
			player_stat_manager = Player
	else:
		if enemy_stat_manager.Entity.Dialogue:
			enemy_dialogue = enemy_stat_manager.Entity.Dialogue
		if not dialogue_box:
			dialogue_box = DialogueBox
		if not player_stat_manager:
			player_stat_manager = Player
	
func update_index() -> void:
	current_message_index += 1
			 

func print_message() -> void:
	update_index()
	if current_message_index == enemy_dialogue.size() - 1:
		current_message_index = -1
		is_dialogue_done = true
	var line: DialogueLine = enemy_dialogue[current_message_index]
	match line.Speaker:
		DialogueLine.SPEAKER.PLAYER:
			speaker = player_stat_manager.Player.entity_name
		DialogueLine.SPEAKER.ENEMY:
			speaker = enemy_stat_manager.Entity.entity_name
		DialogueLine.SPEAKER.NONE:
			speaker = ""
		DialogueLine.SPEAKER.UNKNOWN:
			speaker = "???"

	current_message = speaker + "[br]" + line.Line
	dialogue_box.type_text(current_message)



func on_menus_manager_advance_dialogue() -> void:
	if not is_dialogue_done:
		print_message()
	else:
		emit_signal("Dialogue_Done")
