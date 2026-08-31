extends Card

@export var BaseShield: int = 12
@export var BaseSanShield : int = 12
@export var VFX : PackedScene

func apply_effect(targets : Array[Node]) -> void:
	var block_effect := BlockEffect.new()
	var san_block_effect := SanBlockEffect.new()
	block_effect.amount = BaseShield
	san_block_effect.amount = BaseSanShield
	var Visual = VFX.instantiate()
	if targets[0] is Stat_Manager:	
		targets[0].player_view.effect_guide.add_child(Visual)
		Visual.global_position = targets[0].player_view.effect_guide.global_position
	Visual.animation_player.play("BloodBarrier")
	var ended = func():
		Visual.queue_free()
		decrease_cost()
	Visual.animation_player.animation_finished.connect(
		ended.unbind(1)
	)
	block_effect.activate(targets)
	san_block_effect.activate(targets)
	

func decrease_cost() -> void:
	if mp_cost > 0:
		mp_cost -= 1
	if ap_cost > 0: 
		ap_cost -= 1
func get_description(_character: CharacterInstance) -> String:
	return Description.replace("{Blood_Aias}", str(self.name))
