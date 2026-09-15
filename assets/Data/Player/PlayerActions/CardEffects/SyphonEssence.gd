extends Card

@export var BloodSyphonEffect : BloodSyphon
@export var RegenEffect : Regeneration
@export var blood_tax : int

func apply_effect(targets : Array[Node]) -> void:
	var player = targets[0].get_tree().get_first_node_in_group('player') as Stat_Manager
	player.Player.true_take_damage(blood_tax)
	var BloodSyphonInstance = BloodSyphonEffect.duplicate() as BloodSyphon
	BloodSyphonInstance.current_duration = 5
	BloodSyphonInstance.on_apply(targets, BloodSyphonInstance.current_duration)
	if player:
		var RegenEffectinstance = RegenEffect.duplicate() as Regeneration
		RegenEffectinstance.current_duration = 5
		RegenEffectinstance.on_apply([player], RegenEffectinstance.current_duration)
	
	
