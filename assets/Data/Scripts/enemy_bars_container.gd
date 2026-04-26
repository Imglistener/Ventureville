class_name EnemyBarsContainer extends MarginContainer
@onready var enemy_shield: TextureProgressBar = $VBoxContainer2/enemy_shield
@onready var enemy_san_shield: TextureProgressBar = $VBoxContainer2/enemy_san_shield
@onready var enemy_hp: TextureProgressBar = $VBoxContainer/enemy_hp
@onready var enemy_hp_counter: Label = $VBoxContainer/enemy_hp/enemy_hp_counter
@onready var enemy_san: TextureProgressBar = $VBoxContainer/Enemy_san
@onready var enemy_san_counter: Label = $VBoxContainer/Enemy_san/Enemy_san_counter
@onready var statuseffecticon: TextureRect = $Statuseffecticon
@onready var turns_remaining: Label = $Statuseffecticon/turns_remaining
