extends Node

#card signals:

signal card_aim_started(card_ui : CardUI)
signal card_aim_finished(card_ui : CardUI)
signal card_played(card: Card)

#Phase Signals
signal PlayerStandbyStart(current_phase: PhaseManager.Phases)
signal PlayerStandbyEnd(current_phase: PhaseManager.Phases)
signal PlayerBattleStart(current_phase: PhaseManager.Phases)
signal PlayerBattleEnd(current_phase: PhaseManager.Phases)
signal EnemyStandbyStart(current_phase: PhaseManager.Phases)
signal EnemyStandbyEnd(current_phase: PhaseManager.Phases)
signal EnemyBattleStart(current_phase: PhaseManager.Phases)
signal EnemyBattleEnd(current_phase: PhaseManager.Phases)


#EnemyActionComplete:

signal EnemyActionCompleted(Enemy: EnemyBattlerStats)
signal EnemyActionReady
