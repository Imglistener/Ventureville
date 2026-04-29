extends Card

@export var BaseShield: int = 8
@export var VFX : PackedScene

func apply_effect(targets : Array[Node]) -> void:
	var block_effect := BlockEffect.new()
	block_effect.amount = BaseShield
	var Visual = VFX.instantiate()
	if targets[0] is Stat_Manager:	
		targets[0].player_view.add_child(Visual)
		Visual.global_position += Vector2(130, 180)
	Visual.animation_player.play("BloodBarrier")
	var ended = func():
		Visual.queue_free()
	Visual.animation_player.animation_finished.connect(
		ended.unbind(1)
	)
	block_effect.activate(targets)
	
