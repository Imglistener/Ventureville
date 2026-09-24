class_name PlayerBarsContainer extends MarginContainer

@onready var shields_vbox: VBoxContainer = $shields_vbox
@onready var hp_san_vbox: VBoxContainer = $hp_san_vbox

@onready var player_shield: TextureProgressBar = $shields_vbox/player_shield
@onready var player_san_shield: TextureProgressBar = $shields_vbox/player_san_shield
@onready var player_hp: TextureProgressBar = $hp_san_vbox/player_hp
@onready var player_hp_counter: Label = $hp_san_vbox/player_hp/player_hp_counter
@onready var player_san: TextureProgressBar = $hp_san_vbox/player_san
@onready var player_san_counter: Label = $hp_san_vbox/player_san/player_san_counter
@onready var statuseffecticon: TextureRect = $VBoxContainer3/Statuseffecticon
@onready var turns_remaining: Label = $VBoxContainer3/Statuseffecticon/turns_remaining
@onready var perma_buff_icon: TextureRect = $VBoxContainer3/perma_buff_icon
@onready var player_shield_label: Label = $shields_vbox/player_shield/player_shield_label
@onready var player_san_shield_label: Label = $shields_vbox/player_san_shield/player_san_shield_label

var separation_tween: Tween

func set_player_health_label(value: int) -> void:
	player_hp_counter.text = str(value)

func set_player_san_label(value: int) -> void:
	player_san_counter.text = str(value)

func set_player_block_label(value : int) -> void:
	player_shield_label.text = str(value)
	_updated_block()
	if int(player_shield_label.text) == 0:
		player_shield_label.hide()
	else:
		player_shield_label.show()
	
func set_player_san_block_label(value : int) -> void:
	player_san_shield_label.text = str(value)
	_updated_block()
	if int(player_shield_label.text) == 0:
		player_san_shield_label.hide()
	else:
		player_san_shield_label.show()
	

func _updated_block() -> void:
	tween_separation(int(player_shield_label.text) != 0, int(player_san_shield_label.text) !=0)

func tween_separation(show_shield: bool, show_san_shield: bool) -> void:
	if separation_tween and separation_tween.is_valid():
		separation_tween.kill()
	separation_tween = create_tween().set_parallel(true).set_ease(Tween.EASE_IN_OUT)
	if show_shield and not show_san_shield:
		separation_tween.tween_property(shields_vbox, 'theme_override_constants/separation', 30, 0.3)
		separation_tween.tween_property(hp_san_vbox, 'theme_override_constants/separation', 0, 0.3)
		await separation_tween.finished
	elif show_shield and show_san_shield:
		separation_tween.tween_property(shields_vbox, 'theme_override_constants/separation', 40, 0.3)
		separation_tween.tween_property(hp_san_vbox, 'theme_override_constants/separation', 8, 0.3)
	elif not show_shield and show_san_shield:
		separation_tween.tween_property(shields_vbox, 'theme_override_constants/separation', 20, 0.3)
		separation_tween.tween_property(hp_san_vbox, 'theme_override_constants/separation', 8, 0.3)
	elif not show_shield and not show_san_shield:
			separation_tween.tween_property(shields_vbox, 'theme_override_constants/separation', 12, 0.3)
			separation_tween.tween_property(hp_san_vbox, 'theme_override_constants/separation', 0, 0.3)
