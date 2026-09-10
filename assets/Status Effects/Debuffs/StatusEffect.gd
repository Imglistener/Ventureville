class_name StatusEffect extends Resource

enum StatusEffects{Burning, Frostbite, BloodSyphon, Horrified, Concussed, Stunned, Withering, DamageUp, Regeneration}
var current_duration : int = 0

@export var status_name : StatusEffects
@export var default_duration : int
@export var status_icon : Texture
@export_multiline var status_description: String


func on_apply(_targets: Array[Node], duration : int = 1) -> void:
	pass

func on_activate() -> void:
	pass

func on_tick(_target: BaseBattlerStats) -> void:
	pass

func on_remove(_target: BaseBattlerStats) -> void:
	var existing = find_same_effect(_target.ActiveEffects)
	if existing:
		_target.ActiveEffects.erase(existing)
		Events.StatusWoreOff.emit(self, _target)
		
func is_applicable(targets: Array[Node]) -> bool:
	return false

func find_same_effect(effects: Array) -> StatusEffect:
	for effect in effects:
		if effect.get_script() == self.get_script():
			return effect
	return null
