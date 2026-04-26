class_name turn_manager extends Node

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
var Phases_index : int = -1



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


func advance_turn_phase() -> void:
		Phases_index = (Phases_index + 1) % PHASES.size()
		CURRENT_PHASE = PHASES[Phases_index]
		turn_phase_check()

func _ready() -> void:
	await get_tree().process_frame
	advance_turn_phase()
