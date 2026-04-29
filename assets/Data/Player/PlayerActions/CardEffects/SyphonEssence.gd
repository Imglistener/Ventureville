extends Card

@export var BloodSyphonEffect : BloodSyphon

func apply_effect(targets : Array[Node]) -> void:
	BloodSyphonEffect = BloodSyphon.new()
	BloodSyphonEffect.current_duration = 5
	BloodSyphonEffect.on_apply(targets, BloodSyphonEffect.current_duration)
	
