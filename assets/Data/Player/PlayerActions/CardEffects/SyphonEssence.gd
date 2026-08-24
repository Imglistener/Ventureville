extends Card

@export var BloodSyphonEffect : BloodSyphon
@export var RegenEffect : Regeneration

func apply_effect(targets : Array[Node]) -> void:
	BloodSyphonEffect = BloodSyphon.new()
	BloodSyphonEffect.current_duration = 5
	BloodSyphonEffect.on_apply(targets, BloodSyphonEffect.current_duration)
	if targets[0]:
		var player = targets[0].get_tree().get_first_node_in_group('player')
		if player:
			RegenEffect = Regeneration.new()
			RegenEffect.current_duration = 5
			RegenEffect.on_apply([player], RegenEffect.current_duration)
	
	
