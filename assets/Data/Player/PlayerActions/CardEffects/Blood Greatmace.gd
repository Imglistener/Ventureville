extends AttackCard
## Damage = HP you are missing (Max HP - current HP), measured AFTER the sacrifice is paid.
## {scaled} in the description (and the live preview) shows that number.


func _missing_hp(character: CharacterInstance, hp_lost_first: int = 0) -> int:
	var hp := maxi(character.current_health - hp_lost_first, 0)
	return absi(character.Max_HP - hp) 


## Used by get_description() and the live preview (via _preview_value).
## The sacrifice hasn't been paid yet at that point, so it is projected in.
func _calculate_total(character: CharacterInstance) -> int:
	if not character:
		return 0
	return int(_missing_hp(character, blood_tax) * character.get_attack_bonus())


func _execute(player: Stat_Manager, targets: Array[Node]) -> void:
	if not targets[0] is EnemyView:
		return
	_pay_blood_tax(player)
	var character := player.Player
	_deal_damage(targets, int(_missing_hp(character) * character.get_attack_bonus()))
