class_name EnemyView extends Area2D


@onready var enemy_view: TextureButton = $VBoxContainer/Container/EnemyView
@onready var border: NinePatchRect = $VBoxContainer/Container/Border
@onready var enemy_shield: TextureProgressBar = $VBoxContainer/EnemyBarsContainer/MarginContainer2/shield_vbox/enemy_shield
@onready var enemy_san_shield: TextureProgressBar = $VBoxContainer/EnemyBarsContainer/MarginContainer2/shield_vbox/enemy_san_shield
@onready var enemy_hp: TextureProgressBar = $VBoxContainer/EnemyBarsContainer/hp_san_vbox/enemy_hp
@onready var enemy_hp_counter: Label = $VBoxContainer/EnemyBarsContainer/hp_san_vbox/enemy_hp/enemy_hp_counter
@onready var enemy_san: TextureProgressBar = $VBoxContainer/EnemyBarsContainer/hp_san_vbox/Enemy_san
@onready var enemy_san_counter: Label = $VBoxContainer/EnemyBarsContainer/hp_san_vbox/Enemy_san/Enemy_san_counter
@onready var statuseffecticon: TextureRect = $VBoxContainer/EnemyBarsContainer/MarginContainer/Statuseffecticon
@onready var turns_remaining: Label = $VBoxContainer/EnemyBarsContainer/MarginContainer/Statuseffecticon/turns_remaining
@onready var enemy_bars_container: EnemyBarsContainer = $VBoxContainer/EnemyBarsContainer
@onready var idle: Node = $VBoxContainer/Container/EnemyView/Idle
@onready var dmg_numbers: Marker2D = $DmgNumbers
@onready var death_animation: AnimationPlayer = $Death
@export var resistant_icon: Texture
@export var vulnerable_icon: Texture
@onready var resist_display: TextureRect = $VBoxContainer/EnemyBarsContainer/MarginContainer/DamageRes/Resists
@onready var status_tooltip_marker: Marker2D = $StatusTooltipMarker
@onready var collision: CollisionShape2D = $Collision
@onready var effect_vfx_marker: Marker2D = $EffectVFXMarker


var Enemy: Stat_Manager

func _ready() -> void:
	border.pivot_offset = border.size/2
	idle.start(enemy_view)
	Events.reveal_enemy_resistances.connect(_on_reveal)
	Events.hide_enemy_resistances.connect(_on_hide)
func update_enemy_view(texture_normal: Texture, texture_hovered: Texture) -> void:
	enemy_view.texture_focused = texture_hovered
	enemy_view.texture_normal = texture_normal
	enemy_view.texture_hover = texture_hovered
	enemy_view.texture_pressed = texture_normal	
	
func play_death_animation() -> void:
	if self.has_node("Death"):
		var anim = self.get_node("Death")
		anim.play("death")
		await anim.animation_finished
	else:
		await get_tree().create_timer(0.1).timeout
	monitoring = false
	collision.disabled = true
	
func _on_reveal(damage_type: DamageType, enemies: Array) -> void:
	if Enemy.Entity not in enemies:
		resist_display.visible = false
		return
	match Enemy.Entity.get_resistance_state(damage_type):
		EnemyBattlerStats.RESISTANCE_STATE.RESISTANT:
			resist_display.texture = resistant_icon
			resist_display.visible = true
		EnemyBattlerStats.RESISTANCE_STATE.VULNERABLE:
			resist_display.texture = vulnerable_icon
			resist_display.visible = true
		_:
			resist_display.visible = false

func _on_hide() -> void:
	resist_display.visible = false
