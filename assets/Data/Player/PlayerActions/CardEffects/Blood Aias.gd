extends Card

@export var BaseShield: int = 12
@export var BaseSanShield : int = 12
@export var VFX : PackedScene
@export var blood_tax: int

func apply_effect(targets : Array[Node]) -> void:
	var block_effect := BlockEffect.new()
	var san_block_effect := SanBlockEffect.new()
	var player := targets[0].get_tree().get_first_node_in_group('player') as Stat_Manager
	player.Player.true_take_damage(blood_tax)
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
	Events.card_cost_changed.emit(self)

func get_description(_character: CharacterInstance) -> String:
	return Description.replace("{Blood_Aias}", str(self.name))
