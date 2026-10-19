extends AttackCard
## Hits ALL enemies for half the normal scaled damage, then applies Blood Syphon to each.
## Set target = ALLENEMIES in the .tres, plus the &"BloodWeapon" tag.
## {scaled} in the description (and live preview) shows the halved number.

@export var blood_syphon: BloodSyphon
@export var damage_fraction: float = 0.5
@export var syphon_stacks: int = 2


func _calculate_total(character: CharacterInstance) -> int:
	return int(super(character) * damage_fraction)


func _execute(player: Stat_Manager, targets: Array[Node]) -> void:
	var enemies: Array[Node] = []
	for t in targets:
		if t is EnemyView:
			enemies.append(t)
	if enemies.is_empty():
		return

	_deal_damage(enemies, _calculate_total(player.Player))

	# Don't stack Syphon onto enemies the hit just killed.
	var survivors: Array[Node] = []
	for view in enemies:
		if view.Enemy and view.Enemy.Entity and view.Enemy.Entity.current_health > 0:
			survivors.append(view)
	_apply_status(blood_syphon, survivors, syphon_stacks)
