class_name Enemy extends TextureButton
const Enemy_name_phase1: String = "Gladius, Guardian of Hell"
const Enemy_name_phase2: String = "Gladius, Flames of Oblivion"

@onready var battle: Battle = $"../../../../../../.."
@onready var e_healthbar: Healthbar = %E_Heathbar
@onready var phase_2: Array = [preload("res://assets/Enemybattlers/gladius_phase_2.png"), preload("res://assets/Enemybattlers/gladius_phase_2_highlighted.png")]
@onready var sfx: AudioStreamPlayer2D = $"../../../../../../../SFX"
@onready var played_sfx : bool = false
@onready var bgm: AudioStreamPlayer2D = $"../../../../../../../BGM"
@onready var battle_log: RichTextLabel = %Log
@onready var player_healthbar = $"../../NinePatchRect2/Player_container/player_portrait/player_stats_container/VBoxContainer/player_hp"
@onready var message: Label = $"../../../../../EnemyInfo/NinePatchRect2/Message"

signal StandbyPhase_Done()


var enemy_actions : Array = []

const Enemy_basestats : Dictionary = {
	"eHealth": 300,
	"eSanity": 250,
	"eAttackBonus": 15,
	"eDamagetype": "Fire", 
	"eResitances": "Psychic",
	"eWeaknesses": "Blood",
	"eAction_points" : 3
}


func initialize_enemy_moves() -> Array:
	var spin_slash = Attack_Action.new()
	spin_slash.name = "Blazing Chained Blade"
	spin_slash.Action_type = "Attack"
	spin_slash.damage_type = Enemy_basestats["eDamagetype"]
	spin_slash.damage_base = 20
	spin_slash.Action_target = player_healthbar
	spin_slash.Action_soundeffect = preload("uid://bbvqa2xxno57n")
	spin_slash.Action_log_message = "Gladius drops its superheated Blade on you!\n "
	enemy_actions.append(spin_slash)
	return enemy_actions

func choose_action(enemy_actions) -> void:
	battle.execute_action(enemy_actions[0], player_healthbar)
	message.text = enemy_actions[0].name
	pass

func _ready() -> void:
	initialize_enemy_moves()
	
func _process(_delta: float) -> void:
	if not e_healthbar.is_node_ready():
		await e_healthbar.ready
	if not battle.is_player_turn:
		if battle.is_standbyphase_enemy:

			emit_signal("StandbyPhase_Done")
	if e_healthbar.value_changed:
		if e_healthbar.value >= e_healthbar.max_value/2:
			if not played_sfx:
				sfx.stream = preload("uid://cdpg4x53v00cu")
				sfx.play()
				bgm.play(60*3+14)
				played_sfx = true
				battle_log.text = battle_log.text + "\nGladius lets loose a bonechilling howl!"
			self.texture_normal=phase_2[0]
			self.texture_focused=phase_2[1]
			self.texture_hover=phase_2[1]
			self.texture_pressed=phase_2[0]
