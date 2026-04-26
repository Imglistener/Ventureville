class_name EnemyView extends Area2D


@onready var enemy_view: TextureButton = $Container/EnemyView
@onready var border: NinePatchRect = $Container/Border
@onready var enemy_shield: TextureProgressBar = $EnemyBarsContainer/VBoxContainer2/enemy_shield
@onready var enemy_san_shield: TextureProgressBar = $EnemyBarsContainer/VBoxContainer2/enemy_san_shield
@onready var enemy_hp: TextureProgressBar = $EnemyBarsContainer/VBoxContainer/enemy_hp
@onready var enemy_hp_counter: Label = $EnemyBarsContainer/VBoxContainer/enemy_hp/enemy_hp_counter
@onready var enemy_san: TextureProgressBar = $EnemyBarsContainer/VBoxContainer/Enemy_san
@onready var enemy_san_counter: Label = $EnemyBarsContainer/VBoxContainer/Enemy_san/Enemy_san_counter
@onready var statuseffecticon: TextureRect = $EnemyBarsContainer/Statuseffecticon
@onready var turns_remaining: Label = $EnemyBarsContainer/Statuseffecticon/turns_remaining
@onready var enemy_bars_container: EnemyBarsContainer = $EnemyBarsContainer

var Enemy: Stat_Manager

func _ready() -> void:
	border.pivot_offset = border.size/2
func update_enemy_view(texture_normal: Texture, texture_hovered: Texture) -> void:
	enemy_view.texture_focused = texture_hovered
	enemy_view.texture_normal = texture_normal
	enemy_view.texture_hover = texture_hovered
	enemy_view.texture_pressed = texture_normal	
	
