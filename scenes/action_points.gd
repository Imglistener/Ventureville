extends TextureProgressBar

@onready var battle: Battle = $"../../../../../../.."

func _ready() -> void:
	max_value 	= 3
	value		= battle.action_points
