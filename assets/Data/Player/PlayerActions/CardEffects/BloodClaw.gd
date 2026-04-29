extends Card

@export var BaseDamage: int
@export var VFX : PackedScene

func apply_effect(targets : Array[Node]) -> void:
	var damage_effect := AttackEffect.new()
	damage_effect.amount = BaseDamage
	damage_effect.activate(targets)
	var Visual = VFX.instantiate()
	targets[0].add_child(Visual)
	Visual.animation_player.play('BloodClaw')
	var ended = func():
		Visual.queue_free()
	Visual.animation_player.animation_finished.connect(
		ended.unbind(1)
	)
