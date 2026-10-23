extends DebuffCard

@export var shaken_effect : DamageDown
@export var stunned_effect : Stunned
@export var concussed_effect : Concussed

func _execute(player: Stat_Manager, targets: Array[Node]) -> void:
	var shaken_instance := shaken_effect.duplicate()
	var stunned_instance := stunned_effect.duplicate()
	var concussed_instance := concussed_effect.duplicate()
	shaken_instance.amount = 0.25
	_apply_to_enemies(shaken_instance, targets, 3)
	await player.get_tree().create_timer(0.1).timeout
	_apply_to_enemies(concussed_instance, targets, 2)
	await player.get_tree().create_timer(0.1).timeout
	_apply_to_enemies(stunned_instance, targets, 1)
	await player.get_tree().create_timer(0.1).timeout
