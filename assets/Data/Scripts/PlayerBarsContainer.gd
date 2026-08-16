class_name PlayerBarsContainer extends MarginContainer

@onready var player_shield: TextureProgressBar = $VBoxContainer2/player_shield
@onready var player_san_shield: TextureProgressBar = $VBoxContainer2/player_san_shield
@onready var player_hp: TextureProgressBar = $VBoxContainer/player_hp
@onready var player_hp_counter: Label = $VBoxContainer/player_hp/player_hp_counter
@onready var player_san: TextureProgressBar = $VBoxContainer/player_san
@onready var player_san_counter: Label = $VBoxContainer/player_san/player_san_counter
@onready var statuseffecticon: TextureRect = $VBoxContainer3/Statuseffecticon
@onready var turns_remaining: Label = $VBoxContainer3/Statuseffecticon/turns_remaining
