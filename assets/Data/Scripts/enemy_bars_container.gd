class_name EnemyBarsContainer extends MarginContainer
@onready var enemy_shield: TextureProgressBar = $MarginContainer2/shield_vbox/enemy_shield
@onready var enemy_san_shield: TextureProgressBar = $MarginContainer2/shield_vbox/enemy_san_shield
@onready var enemy_hp: TextureProgressBar = $hp_san_vbox/enemy_hp
@onready var enemy_hp_counter: Label = $hp_san_vbox/enemy_hp/enemy_hp_counter
@onready var enemy_san: TextureProgressBar = $hp_san_vbox/Enemy_san
@onready var enemy_san_counter: Label = $hp_san_vbox/Enemy_san/Enemy_san_counter
@onready var statuseffecticon: TextureRect =$MarginContainer/Statuseffecticon
@onready var turns_remaining: Label = $MarginContainer/Statuseffecticon/turns_remaining
@onready var perma_buff_icon: TextureRect = $MarginContainer/perma_buff_icon
@onready var enemy_shield_label: Label = $MarginContainer2/shield_vbox/enemy_shield/enemy_shield_counter
@onready var enemy_san_shield_label: Label = $MarginContainer2/shield_vbox/enemy_san_shield/enemy_san_shield_counter
@onready var hp_san_vbox: VBoxContainer = $hp_san_vbox
@onready var shields_vbox: VBoxContainer = $MarginContainer2/shield_vbox

var separation_tween : Tween

func set_enemy_health_label(value: int) -> void:
	enemy_hp_counter.text = str(value)

func set_enemy_san_label(value: int) -> void:
	enemy_san_counter.text = str(value)

func set_enemy_block_label(value : int) -> void:
	enemy_shield_label.text = str(value)
	if int(enemy_shield_label.text) == 0:
		enemy_shield_label.hide()
	else:
		enemy_shield_label.show()
	_updated_block()
	
func set_enemy_san_block_label(value : int) -> void:
	enemy_san_shield_label.text = str(value)
	if int(enemy_san_shield_label.text) == 0:
		enemy_san_shield_label.hide()
	else:
		enemy_san_shield_label.show()
	_updated_block()


func _updated_block() -> void:
	tween_separation(int(enemy_shield_label.text) != 0, int(enemy_san_shield_label.text) !=0)

func tween_separation(show_shield: bool, show_san_shield: bool) -> void:
	if separation_tween and separation_tween.is_valid():
		separation_tween.kill()
	separation_tween = create_tween().set_parallel(true).set_ease(Tween.EASE_IN_OUT)
	if show_shield and not show_san_shield:
		separation_tween.tween_property(shields_vbox, 'theme_override_constants/separation', 26, 0.3)
		separation_tween.tween_property(hp_san_vbox, 'theme_override_constants/separation', 0, 0.3)
		await separation_tween.finished
	elif show_shield and show_san_shield:
		separation_tween.tween_property(shields_vbox, 'theme_override_constants/separation', 40, 0.3)
		separation_tween.tween_property(hp_san_vbox, 'theme_override_constants/separation', 12, 0.3)
	elif not show_shield and show_san_shield:
		separation_tween.tween_property(shields_vbox, 'theme_override_constants/separation', 26, 0.3)
		separation_tween.tween_property(hp_san_vbox, 'theme_override_constants/separation', 12, 0.3)
	elif not show_shield and not show_san_shield:
			separation_tween.tween_property(shields_vbox, 'theme_override_constants/separation', 0, 0.3)
			separation_tween.tween_property(hp_san_vbox, 'theme_override_constants/separation', 0, 0.3)
