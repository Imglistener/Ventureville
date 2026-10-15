extends AttackCard
## Deals a fraction (default 1/4) of the normal scaled damage, draws cards, and costs Blood Debt.
## {scaled} in the description (and live preview) already shows the reduced number.

@export var damage_fraction: float = 0.25
@export var draw_amount: int = 2
@export var blood_debt: BloodDebt
@export var debt_amount: int = 10


func _calculate_total(character: CharacterInstance) -> int:
	return int(super(character) * damage_fraction)


func _execute(player: Stat_Manager, targets: Array[Node]) -> void:
	if not targets[0] is EnemyView:
		return
	_pay_blood_tax(player)
	_deal_damage(targets, _calculate_total(player.Player))

	var draw := DrawEffect.new()
	draw.amount = draw_amount
	draw.activate(targets)
	if slash_vfx:
		var enemy_view = targets[0].enemy_view as TextureButton
		var OFFSET = enemy_view.size/2 + Vector2(0, +120)
		var vfx = slash_vfx.instantiate() as Slash_VFX
		enemy_view.add_child(vfx)
		vfx.scale *= 5
		vfx.position = enemy_view.position + OFFSET
		vfx.play_vfx(true)

	_apply_to_self(blood_debt, player, debt_amount)
