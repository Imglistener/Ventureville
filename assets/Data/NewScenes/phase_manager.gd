class_name PhaseManager extends Node

@onready var menus_manager: MenusManager = $"../MenusManager"

enum Phases {PlayerStandbyStart, PlayerStandbyEnd, PlayerBattleStart, PlayerBattleEnd, EnemyStandbyStart, EnemyStandbyEnd, EnemyBattleStart, EnemyBattleEnd}
const PHASE_CYCLE := [
	Phases.PlayerStandbyStart,
	Phases.PlayerStandbyEnd,
	Phases.PlayerBattleStart,
	Phases.PlayerBattleEnd,
	Phases.EnemyStandbyStart,
	Phases.EnemyStandbyEnd,
	Phases.EnemyBattleStart,
	Phases.EnemyBattleEnd,
]
var current_phase : Phases
var _phase_index := 0

func emit_current_phase() -> void:
	match current_phase:
		Phases.PlayerStandbyStart:
			Events.PlayerStandbyStart.emit(current_phase)
		Phases.PlayerStandbyEnd:
			Events.PlayerStandbyEnd.emit(current_phase)
		Phases.PlayerBattleStart:
			Events.PlayerBattleStart.emit(current_phase)  
		Phases.PlayerBattleEnd:
			Events.PlayerBattleEnd.emit(current_phase)
		Phases.EnemyStandbyStart:
			Events.EnemyStandbyStart.emit(current_phase)
		Phases.EnemyStandbyEnd:
			Events.EnemyStandbyEnd.emit(current_phase)
		Phases.EnemyBattleStart:
			Events.EnemyBattleStart.emit(current_phase)
		Phases.EnemyBattleEnd:
			Events.EnemyBattleEnd.emit(current_phase)

func advance_to_next_phase() -> void:
	_phase_index = (_phase_index + 1) % PHASE_CYCLE.size()
	current_phase = PHASE_CYCLE[_phase_index]
	emit_current_phase.call_deferred()

func connect_signals() -> void:
	for i in PHASE_CYCLE:
		if i is PhaseManager.Phases:
			var current_signal : StringName = Phases.keys()[i]
			if Events.has_signal(current_signal):
				Events.connect(current_signal, menus_manager.PhaseUI_active)
				
				
func emit_specific_phase(Phase: StringName) -> void:
	if Phase in Phases:
		_phase_index = Phases.keys().find(str(Phase)) % PHASE_CYCLE.size()
		current_phase = PHASE_CYCLE[_phase_index]
	if Events.has_signal(Phase):
		Events.emit_signal(Phase, current_phase)
			
