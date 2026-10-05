extends DebuffCard

@export var blood_syphon: BloodSyphon

func _execute(player: Stat_Manager, targets: Array[Node]) -> void:
	var regen := _find_status(player.Player.ActiveEffects, Regeneration)
	var amount := 0
	if regen:
		amount = regen.current_duration
		regen.on_remove(player.Player)

	# The description says this always happens. Move it inside the `if regen` block above
	# if you want the old behavior (only when you had Regeneration).
	player.Player.current_health = player.Player.Max_HP / 2

	if amount > 0:
		_apply_to_enemies(blood_syphon, targets, amount)
