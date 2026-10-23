class_name EnemyAction
extends Node

enum ActionTypes {Conditional, ChanceBased}
enum ActionEffects {Attack, Defend, Buff, Debuff, Transition}
@export var Enemy_Data : EnemyData
@export var ActionType: ActionTypes
@export var ActionEffect: ActionEffects
@export var SoundEffect : AudioStream
@export_range(0.0, 10.0) var ActionChance: float = 0.0
@export_multiline var Description: String

var log: Log

@onready var TotalChance : float = 0.0

var Enemy: EnemyView
var target: Stat_Manager

func is_usable() -> bool:
	return false

func use_action() -> void:
	if self.log:
		self.log._log(Description)

func setup_from_data() -> void:
	if not Enemy_Data:
		return
	ActionType = Enemy_Data.ActionType
	ActionEffect = Enemy_Data.ActionEffect
	SoundEffect = Enemy_Data.SoundEffect
	ActionChance = Enemy_Data.ActionChance
	Description = Enemy_Data.Description


# ------------------------------------------------------------------ Mimicry

# Divisor / hit count that match how this action's use_action() turns Damage into a hit.
# AttackAction, SavageLunge and Supernova use 2 / 1 (the defaults). King, Queen and
# TripleBite override these.
func _mimic_divisor() -> float:
	return 2.0

func _mimic_hits() -> int:
	return 1

## Last chance for an action to add something the generic reader can't see (Queen's Syphon).
func _mimic_extra(_profile: MimicProfile) -> void:
	pass

## Called by MimicRecorder when the action finishes. Returns null for actions that can't be copied:
## phase transitions, Charging, and condition buffs.
## It reads the action's exported fields by name, so most enemy scripts need no changes.
func get_mimic_profile() -> MimicProfile:
	if not Enemy or not Enemy.Enemy or not Enemy.Enemy.Entity:
		return null
	if ActionEffect == ActionEffects.Transition:
		return null
	if "Phases" in self or "Phase_2_Normal" in self or "stun_threshold" in self or "condition" in self:
		return null

	var entity := Enemy.Enemy.Entity
	var p := MimicProfile.new()
	p.source_name = Enemy_Data.ActionName if Enemy_Data and not Enemy_Data.ActionName.is_empty() else String(name)
	p.sound = SoundEffect

	if "Damage" in self:
		var raw := float(get("Damage"))
		if "damagetype" in self:
			p.damage = int(raw * entity.DamageBonus / _mimic_divisor() * entity.get_attack_bonus())
			p.hits = _mimic_hits()
			p.damage_type = get("damagetype")
		else:
			p.san_damage = int(raw)   # San_attack_action: raw Damage, SAN only
	if "block_gained" in self:
		p.block = int(get("block_gained"))
	if "burn" in self and "burn_stacks" in self and get("burn"):
		p.status = get("burn")
		p.status_stacks = int(get("burn_stacks"))
	elif "concussed" in self and get("concussed"):
		p.status = get("concussed")
		p.status_stacks = int(get("concussed_duration")) if "concussed_duration" in self else 1
		p.status_needs_damage = true
	_mimic_extra(p)

	if p.damage <= 0 and p.block <= 0 and p.san_damage <= 0 and p.status_stacks <= 0:
		return null
	return p
