extends AttackCard
## Sacrifice, then hit ALL enemies once for (scaled / 4) x the number of Blood Weapons
## played this turn. This card counts itself, so it never hits for less than one weapon's worth.
## Set blood_tax = 8, 1 AP / 2 MP, target = ALLENEMIES and the &"BloodWeapon" tag in the .tres.
## {scaled} in the description (and live preview) is the damage PER Blood Weapon.

@export var damage_fraction: float = 0.25


func _calculate_total(character: CharacterInstance) -> int:
	return int(super(character) * damage_fraction)


## card_played fires before _execute, so by now this card is already in the tracker's list.
func _weapons_played(player: Stat_Manager) -> int:
	var tracker := _get_turn_tracker(player)
	if not tracker:
		return 1
	return maxi(tracker.count_tag_played_this_turn(TAG_BLOOD_WEAPON), 1)


func _execute(player: Stat_Manager, targets: Array[Node]) -> void:
	var enemies: Array[Node] = []
	for t in targets:
		if t is EnemyView:
			enemies.append(t)
	if enemies.is_empty():
		return
	_pay_blood_tax(player)
	var per_weapon := _calculate_total(player.Player)
	_deal_damage(enemies, per_weapon * _weapons_played(player))


func get_live_description(character: CharacterInstance, live_targets: Array[Node]) -> String:
	var text := super(character, live_targets)
	if live_targets.is_empty() or not live_targets[0]:
		return text
	var player := live_targets[0].get_tree().get_first_node_in_group("player") as Stat_Manager
	var tracker := _get_turn_tracker(player) if player else null
	# Not played yet, so the preview adds this card itself.
	var count = (tracker.count_tag_played_this_turn(TAG_BLOOD_WEAPON) if tracker else 0) + 1
	return text + "\n(%d Blood Weapon%s this turn)" % [count, "" if count == 1 else "s"]
