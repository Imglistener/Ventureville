extends Card

@export var HealMultiplier: int = 3
@export var DamageUpDuration: int = 1

func apply_effect(targets: Array[Node]) -> void:
	if targets.is_empty() or not targets[0]:
		return

	var enemy_view := targets[0] as EnemyView
	if not enemy_view or not enemy_view.Enemy or not enemy_view.Enemy.Entity:
		return
	var enemy: EnemyBattlerStats = enemy_view.Enemy.Entity

	var tree := targets[0].get_tree()
	var player_stat_manager := tree.get_first_node_in_group('player') as Stat_Manager
	if not player_stat_manager:
		return
	var player: CharacterInstance = player_stat_manager.Player

	var syphon := _find_blood_syphon(enemy.ActiveEffects)
	if not syphon:
		return

	var stacks := syphon.current_duration
	var healing := stacks * HealMultiplier

	syphon.on_remove(enemy)

	player.heal(healing)
	player.san_heal(healing)

	var damage_up := DamageUP.new()
	damage_up.amount = stacks
	damage_up.on_apply([player_stat_manager], DamageUpDuration)


func _find_blood_syphon(effects: Array) -> BloodSyphon:
	for effect in effects:
		if effect is BloodSyphon:
			return effect
	return null
