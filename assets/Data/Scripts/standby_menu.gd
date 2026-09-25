class_name StandbyMenu extends NinePatchRect

@export var testdamage: DamageType
@onready var talk: Button = $Margin/ButtonContainer/Talk
@onready var escape: Button = $Margin/ButtonContainer/Escape
@onready var items: Button = $Margin/ButtonContainer/Items
@onready var battle: Button = $Margin/ButtonContainer/Battle
@onready var player_stat_manager: Stat_Manager = $"../../../../../Functionality/PlayerStatManager"

func _ready() -> void:
	if not player_stat_manager.is_node_ready():
		await player_stat_manager.ready
