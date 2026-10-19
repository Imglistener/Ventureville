extends AttackCard
## Sacrifice, then deal half the normal scaled damage.
## Set blood_tax = 3, 0 AP / 1 MP, target = ONEENEMY and the &"BloodWeapon" tag in the .tres.
## {scaled} in the description (and live preview) shows the halved number.

@export var damage_fraction: float = 0.5


func _calculate_total(character: CharacterInstance) -> int:
	return int(super(character) * damage_fraction)


func _execute(player: Stat_Manager, targets: Array[Node]) -> void:
	if not targets[0] is EnemyView:
		return
	_pay_blood_tax(player)
	_deal_damage(targets, _calculate_total(player.Player))
