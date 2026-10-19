extends DefendCard
## Strips all Shield (and SAN Shield) from the target enemy, then grants the player Shield:
## BaseShield, doubled if the target has Blood Syphon.
## target = ONEENEMY. Costs, rarity and BaseShield = 16 are set in the .tres.

@export var syphon_multiplier: int = 2


func _has_syphon(entity: BaseBattlerStats) -> bool:
	return _find_status(entity.ActiveEffects, BloodSyphon) != null


func _shield_amount(entity: BaseBattlerStats) -> int:
	return BaseShield * (syphon_multiplier if _has_syphon(entity) else 1)


func _execute(player: Stat_Manager, targets: Array[Node]) -> void:
	var view := targets[0] as EnemyView
	if not view or not view.Enemy or not view.Enemy.Entity:
		return
	var entity: BaseBattlerStats = view.Enemy.Entity
	_pay_blood_tax(player)

	# Read the Syphon BEFORE stripping anything, then break the shield.
	var amount := _shield_amount(entity)
	if entity.current_block > 0:
		entity.current_block = 0
	if entity.current_san_block > 0:
		entity.current_san_block = 0

	# Gain the Shield on the player, not on the target.
	var self_target: Array[Node] = [player]
	var block := BlockEffect.new()
	block.amount = amount
	block.activate(self_target)
	if VFX:
		_play_vfx(player)


func get_live_description(_character: CharacterInstance, live_targets: Array[Node]) -> String:
	var enemies := _resolve_enemies(live_targets)
	if enemies.is_empty():
		return Description
	var entity := enemies[0]
	if _has_syphon(entity):
		return Description + "\n(Empowered: Gain %d Shield)" % _shield_amount(entity)
	return Description + "\n(Gain %d Shield)" % _shield_amount(entity)
