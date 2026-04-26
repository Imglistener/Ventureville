class_name Mana_UI extends TextureRect

@onready var MP_Label: Label = $MP_Number
@export var Empty: Texture
@export var Full: Texture
func _process(_delta: float) -> void:
	if int(MP_Label.text) == 0:
		if texture != Empty:
			texture = Empty 
		MP_Label.add_theme_color_override("font_color", Color.DARK_RED)
	else:
		if texture == Empty:
			texture = Full
		MP_Label.add_theme_color_override("font_color", Color.WHITE)	
