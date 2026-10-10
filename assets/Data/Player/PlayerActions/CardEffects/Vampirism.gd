extends BuffCard

@export var healing_amount: int
@export var blood_debt : BloodDebt
func _execute(player: Stat_Manager, targets: Array[Node]) -> void:
	var blood_syphon_count : int = 0
	for target in targets:
		if target is EnemyView:
			for effect in target.Enemy.Entity.ActiveEffects:
				if effect is BloodSyphon:
					healing_amount = mini(effect.current_duration * 5, 50)
					player.Player.heal(healing_amount)
					blood_syphon_count += 1
	
	blood_debt.on_apply([player], blood_syphon_count * 10) 
