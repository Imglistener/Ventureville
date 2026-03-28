class_name Status_Effect extends Resource

@export var name: String
@export var icon: Texture2D
@export var duration: int = 0
# Optional: type/category
@export var is_stackable: bool = false

#Signal Time

signal applied_effect(name)

#AverageFunctionBeLike:

func releaseDOT(target: TextureProgressBar, amount: int):
	target.value = target.value + amount	

# Called when applied
func on_apply(source, target, amount):
	pass

# Called each turn
func on_standby_phase(source, target):
	pass

# Called when removed
func on_remove(source, target):
	pass
