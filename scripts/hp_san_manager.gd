class_name HP_SAN_Manager extends Node
@onready var stat_manager: Stat_Manager = %"Stat Manager"
@onready var enemy_stat_manager: Stat_Manager = %"Enemy Stat Manager"



func _ready() -> void:
	if not stat_manager.is_node_ready():
		await stat_manager.ready
	if not enemy_stat_manager.is_node_ready():
		await enemy_stat_manager.ready
