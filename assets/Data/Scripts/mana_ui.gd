class_name Mana_UI
extends TextureRect

@onready var MP_Label: Label = $MP_Number
@onready var gem: TextureRect = $Gem

var last_number: int = 3
var max_number: int = 3 

func update_gem(mana_number: int) -> void:
	if last_number != mana_number:
		last_number = mana_number

		if mana_number > max_number:
			max_number = mana_number

		_update_visuals()

func _update_visuals() -> void:
	MP_Label.text = str(last_number)

	var ratio: float = 0.0
	if max_number > 0:
		ratio = float(last_number) / float(max_number)
	ratio = pow(ratio, 0.5)

	var mat := gem.material as ShaderMaterial
	if mat:
		mat.set_shader_parameter("saturation", ratio)
