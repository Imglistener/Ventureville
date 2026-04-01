class_name Battle_Manager extends Node

@onready var ENEMY: Combat_Entity = %Combat_Entity
@onready var PLAYER: Player_Battle_Handler = %Player_Battle_Entity

@export var card_scene: PackedScene
#Battle Variables:
var turn_counter : int		= 1
var mana_counter : int		= 5
var action_points: int		= 3
var active_effects : Array	= []

#Stattes:
enum TURN_PHASE {
	player_standby_phase_start,
	player_standby_phase_end,
	player_battle_phase_start,
	player_battle_phase_end,
	enemy_standby_phase_start,
	enemy_standby_phase_end,
	enemy_battle_phase_start,
	enemy_battle_phase_end
}

var PHASES : Array = [
TURN_PHASE.player_standby_phase_start, 
TURN_PHASE.player_standby_phase_end, 
TURN_PHASE.player_battle_phase_start,
TURN_PHASE.player_battle_phase_end,
TURN_PHASE.enemy_standby_phase_start,
TURN_PHASE.enemy_standby_phase_end,
TURN_PHASE.enemy_battle_phase_start,
TURN_PHASE.enemy_battle_phase_end
]
var CURRENT_PHASE : Variant
var Phases_index : int = 0



signal player_standby_phase_start
signal player_standby_phase_end
signal player_battle_phase_start
signal player_battle_phase_end
signal enemy_standby_phase_start
signal enemy_standby_phase_end
signal enemy_battle_phase_start
signal enemy_battle_phase_end


signal card_played(card_data)
signal turn_changed()

func _process(_delta: float) -> void:
	pass

func turn_phase_check() -> void:
	match CURRENT_PHASE:
		TURN_PHASE.player_standby_phase_start:
			emit_signal("player_standby_phase_start")
		TURN_PHASE.player_standby_phase_end:
			emit_signal("player_standby_phase_end")
		TURN_PHASE.player_battle_phase_start:
			emit_signal("player_battle_phase_start")
		TURN_PHASE.player_battle_phase_end:
			emit_signal("player_battle_phase_end")
		TURN_PHASE.enemy_standby_phase_start:
			emit_signal("enemy_standby_phase_start")
		TURN_PHASE.enemy_standby_phase_end:
			emit_signal("enemy_standby_phase_end")
		TURN_PHASE.enemy_battle_phase_start:
			emit_signal("enemy_battle_phase_start")
		TURN_PHASE.enemy_battle_phase_end:
			emit_signal("enemy_battle_phase_end")

func _ready() -> void:
	update_turn_phase()
	pass

func turn_tick() -> void:
	turn_counter += 1
	action_points = 3
	mana_counter += 1
	emit_signal("turn_changed", turn_counter)
	

func _onCard_Pressed(card_data : Player_Attack_Instance)-> void:
	action_points -= card_data.Action_Cost_AP
	mana_counter -= card_data.Action_Cost_MP
	card_data.apply_effect(PLAYER, ENEMY)
	emit_signal("card_played", card_data)

func update_turn_phase() -> void:
	CURRENT_PHASE = PHASES[Phases_index]
	turn_phase_check()
	
func advance_turn_phase() -> void:
		Phases_index = (Phases_index + 1) % PHASES.size()

func register_card(card):
	card.card_clicked.connect(_onCard_Pressed)

func _on_end_turn_pressed() -> void:
	advance_turn_phase()
	update_turn_phase()

func _on_battle_pressed() -> void:
	advance_turn_phase()
	update_turn_phase()


func _on_player_battle_phase_end() -> void:
	ENEMY.enemy_view.disabled
	turn_tick()
	advance_turn_phase()
	update_turn_phase()
	

func _on_combat_entity_enemy_done_attacking() -> void:
	advance_turn_phase()
	update_turn_phase()


func _on_status_effect_manager_effects_checked() -> void:
	advance_turn_phase()
	update_turn_phase()


func _on_combat_entity_enemy_battle_ready() -> void:
	advance_turn_phase()
	update_turn_phase()

func _on_ui_manager_cards_drawn() -> void:
	advance_turn_phase()
	update_turn_phase()

	


func _on_enemy_battle_phase_end() -> void:
	turn_tick()
