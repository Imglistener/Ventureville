extends BuffCard

@export var HealMultiplier: int = 3
@export var DamageUpDuration: int = 1
@export var damage_up_effect: StatusEffect

func _execute(player: Stat_Manager, targets: Array[Node]) -> void:
	var enemy_view := targets[0] as EnemyView
	if not enemy_view or not enemy_view.Enemy or not enemy_view.Enemy.Entity:
		return
	var enemy: EnemyBattlerStats = enemy_view.Enemy.Entity

	var syphon := _find_status(enemy.ActiveEffects, BloodSyphon) as BloodSyphon
	if not syphon:
		return

	var stacks := syphon.current_duration
	var healing := stacks * HealMultiplier
	syphon.on_remove(enemy)

	player.Player.heal(healing)
	player.Player.san_heal(healing)

	var damage_up := preload("uid://cykpqknfmbckv").duplicate()
	damage_up.amount = (0.05 * stacks) + 1
	_apply_to_self(damage_up, player, DamageUpDuration)
