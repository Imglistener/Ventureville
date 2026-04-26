class_name StandbyMenu extends NinePatchRect

@export var testdamage: DamageType
@onready var talk: Button = $Margin/ButtonContainer/Talk
@onready var escape: Button = $Margin/ButtonContainer/Escape
@onready var items: Button = $Margin/ButtonContainer/Items
@onready var battle: Button = $Margin/ButtonContainer/Battle
@onready var player_stat_manager: Stat_Manager = $"../../../../../Functionality/PlayerStatManager"
@onready var enemy_stat_manager: Stat_Manager = $"../../../../../Functionality/EnemyStatManager"

func _ready() -> void:
	if not player_stat_manager.is_node_ready():
		await player_stat_manager.ready
	if not enemy_stat_manager.is_node_ready():
		await enemy_stat_manager.ready
	if not items.pressed.is_connected(player_stat_manager.Player.take_damage.bind(50, testdamage)):
		items.pressed.connect(player_stat_manager.Player.take_damage.bind(50, testdamage))
	if not items.pressed.is_connected(enemy_stat_manager.Entity.take_damage.bind(50, testdamage)):
		items.pressed.connect(enemy_stat_manager.Entity.take_damage.bind(50, testdamage))
