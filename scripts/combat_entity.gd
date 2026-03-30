class_name Combat_Entity extends Node
@onready var enemy_view: Enemy_View = $Enemy_view

@export var enemy_behavior 	: Enemy_Revised
@export var enemy_data 		: Enemy_Data

var enemy_stats 	: Array
var enemy_actions 	: Array
signal enemy_stats_ready
signal attack_just_landed(damage_type, amount)



func _ready()-> void:
	enemy_actions 	= enemy_behavior.initialize_enemy_moves()
	enemy_stats 	= enemy_data.initalize_enemy_stats()
	emit_signal("enemy_stats_ready")
	update_enemy_view(enemy_view, enemy_behavior)

func takedamage(amount: int, damage_type : Damage_Type) -> void:
	enemy_stats[1] -= amount
	emit_signal("attack_just_landed", damage_type, amount)


func update_enemy_view(enemy_view: Enemy_View, enemy_textures : Enemy_Revised) -> void:
	enemy_view.texture_normal 	= enemy_textures.Texture_Normal
	enemy_view.texture_hover	= enemy_textures.Texture_Hover
	enemy_view.texture_focused	= enemy_textures.Texture_Hover
	enemy_view.texture_pressed	= enemy_textures.Texture_Press	
