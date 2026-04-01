class_name Status_Effect_Manager
extends Node

# UI references
@onready var turns_remaining_label: Label = $"../MarginMain/VBoxContainer/EnemyInfo/NinePatchRect/MarginContainer/HBoxContainer/HBoxContainer/Statuseffecticon/turns_remaining"
@onready var statuseffecticon: TextureRect = $"../MarginMain/VBoxContainer/EnemyInfo/NinePatchRect/MarginContainer/HBoxContainer/HBoxContainer/Statuseffecticon"
@export var damage : Damage_Type
@onready var battle_manager: Battle_Manager = %Battle_Manager
@onready var ENEMY			: Combat_Entity = %Combat_Entity
# Mapping damage types to StatusEffect resources

# References to battle and target

# State
var is_statuseffectactive: bool = false
signal effects_checked
# ------------------------------
# Apply an effect based on damage type
# ------------------------------
func apply_effect_from_damage(damage_type: Damage_Type, target):
	if damage_type is Damage_Type:
		var effect: Status_Effect = damage_type.associated_status
		apply_status_effect(effect, target)

# ------------------------------
# Update the UI for a given effect
# ------------------------------
func update_status_ui(effect_instance: Status_Effect) -> void:
	statuseffecticon.texture = effect_instance.icon
	turns_remaining_label.text = str(effect_instance.duration)
	if len(battle_manager.active_effects) > 0:
		turns_remaining_label.show()
	else:
		turns_remaining_label.hide()

# ------------------------------
# Apply or refresh a status effect on a target
# ------------------------------
func apply_status_effect(effect: Status_Effect, target) -> void:
	var existing_effect: Status_Effect = null
	
	# Check if this effect type is already applied
	for e in battle_manager.active_effects:
		if e.get_script() == effect.get_script():
			existing_effect = e
			break

	if existing_effect:
		# Increment duration of existing effect
		existing_effect.duration += 1
		update_status_ui(existing_effect)
		print("Refreshed:", existing_effect.duration)
	else:
		# Apply new effect
		var new_effect: Status_Effect = effect.duplicate()  # per-target copy
		new_effect.duration += 1
		battle_manager.active_effects.append(new_effect)
		update_status_ui(new_effect)
		print("Applied:", new_effect.duration)
	
		
# ------------------------------
# Tick all effects at the end of a battle phase
# ------------------------------
func effect_tick() -> void:
	for effect_instance in battle_manager.active_effects:
		effect_instance.on_apply(ENEMY, effect_instance.duration)

# ------------------------------
# Ready: connect to battle phase signal
# ------------------------------
func _ready() -> void:
	if not battle_manager.enemy_standby_phase_start.is_connected(effect_tick):
		battle_manager.enemy_standby_phase_start.connect(effect_tick)

# ------------------------------
# Optional: called externally when damage is dealt
# ------------------------------
func _on_battle_just_dealt_damage(damage_type: Variant, target: Variant) -> void:
	apply_effect_from_damage(damage_type, target)


	


func _on_battle_manager_enemy_standby_phase_start() -> void:
	effect_tick()
	emit_signal("effects_checked")
	
