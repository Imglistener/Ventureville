class_name StatusEffect extends Resource

enum StatusEffects{Burning, Frostbite, BloodSyphon, Horrified, Concussed, Stunned, Withering}
var current_duration : int = 0

@export var status_name : StatusEffects
@export var default_duration : int
@export var status_icon : Texture
@export_multiline var status_description: String


func on_apply(_targets: Array[Node]) -> void:
	pass

func on_tick(_target: BaseBattlerStats) -> void:
	pass

func on_remove(_target: BaseBattlerStats) -> void:
	pass

func is_applicable() -> bool:
	return false
