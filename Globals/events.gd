extends Node

#card signals:
signal reveal_enemy_resistances(damage_type: DamageType, enemies: Array)
signal hide_enemy_resistances
signal card_aim_started(card_ui : CardUI)
signal card_aim_finished(card_ui : CardUI)
signal card_played(card: Card)
signal effect_applied
# `anchor` is the Node2D the floating label should be parented under
# (e.g. entity.damage_number_anchor) — replaces the old is_from_player
# bool + group-index guess in damage_numbers.gd.
signal effect_display(effect: StatusEffect, anchor: Node2D, source_position: Vector2)
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

signal EnemyActionCompleted(Enemy: EnemyAction)
signal EnemiesDonePlaying
signal EnemyActionReady

#Item Signals
signal item_used(item: Item)
