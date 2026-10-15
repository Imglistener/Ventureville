extends AttackCard

@export var AppliedEffect: StatusEffect   # BloodSyphon.tres
@export var RegenEffect: StatusEffect     # Regeneration.tres

func _execute(player: Stat_Manager, targets: Array[Node]) -> void:
	if not targets[0] is EnemyView:
		return
	var total := _calculate_total(player.Player)
	_pay_blood_tax(player)
	if slash_vfx:
		var enemy_view = targets[0].enemy_view as TextureButton
		var OFFSET = enemy_view.size/2 + Vector2(0, +120)
		var vfx = slash_vfx.instantiate() as Slash_VFX
		enemy_view.add_child(vfx)
		vfx.scale *= 5
		vfx.position = enemy_view.position + OFFSET
		vfx.play_vfx(true)
	_deal_damage(targets, total)

	var apply_count := randi_range(1, 3)
	for i in apply_count:
		_apply_status(AppliedEffect, targets, 1, true)   # skipped while the target has block
	_apply_to_self(RegenEffect, player, apply_count)
