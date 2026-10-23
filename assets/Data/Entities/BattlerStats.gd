class_name BaseBattlerStats extends Resource
signal Stats_Changed

enum BATTLER_TYPES {PLAYER , ENEMY}
signal damage_taken(amount: int, entity_name: String)
signal hp_sacrificed(amount: int)   # NEW: only fired by true_take_damage (blood tax), not by enemy hits
signal sanity_damage_taken(amount: int, entity_name: String)
signal health_restored(amount: int, entity_name: String)
signal sanity_restored(amount: int, entity_name: String)
signal block_gained(amount: int, entity_name: String)
signal san_block_gained(amount: int, entity_name: String)
signal entity_died(entity_name: String)

@export_group("Basic Stats")
@export var entity_name : String
@export var Battler_Type: BATTLER_TYPES


@export var stats : Array[StatInstance] = []
var ActiveEffects: Array[StatusEffect] = []
var BattleConditions: Array[BattleCondition] = []
var _max_hp: int = 1  # Backing variable
var _max_san: int = 1
var Max_HP : int:
	get: return _get_max_hp()
var Max_SAN : int:
	get: return _get_max_san()


var current_health	: int : set = set_health
var current_sanity	: int : set = set_sanity
var current_block	: int : set = set_block
var current_san_block: int: set = set_san_block
var damage_numbers: Vector2
var damage_number_anchor: Node2D  # NEW: the Node2D floating labels should be parented under for this entity
var buff_damage_modifier: float = 1.0

func modify_buff_modifier(amount: float) -> void:
	buff_damage_modifier = clampf(amount, 1.0, 1.5)
	print("Buff Damage Modifer Changed : " , amount)
	Stats_Changed.emit()

func get_attack_bonus() -> float:
	var reduction := 0.0
	for effect in ActiveEffects:
		if effect is DamageDown:
			reduction += effect.amount
	# Reduction is capped at 75% total.
	return buff_damage_modifier * clampf(1.0 - reduction, 0.25, 1.0)

## Unblockable HP loss from sacrificing (Card._pay_blood_tax is the only caller).
func true_take_damage(amount: int) -> void:
	current_health -= amount
	Stats_Changed.emit()
	damage_taken.emit(amount, entity_name)
	hp_sacrificed.emit(amount)
	if current_health == 0:
		entity_died.emit(entity_name)

func load_stats() -> void:
	for stat_instance in stats:
		match stat_instance.stat_name:
			StatInstance.STATS.HEALTH:
				_max_hp = stat_instance.stat_total_value
			StatInstance.STATS.SANITY:
				_max_san = stat_instance.stat_total_value
	Stats_Changed.emit()



func reset_block() -> void:
	current_block = 0
	current_san_block = 0

func set_health(value: int) -> void:
	if value <= 0 and current_health > 0:
		for condition in BattleConditions.duplicate():
			if condition.prevent_death(self):
				value = 1
				break
	current_health = clampi(value, 0, 9999)
	Stats_Changed.emit()
func set_sanity(value: int) -> void:
	current_sanity = clampi(value, 0, 9999)
	Stats_Changed.emit()
func set_san_block(value: int) -> void:
	current_san_block = clampi(value, 0, 9999)
	Stats_Changed.emit()
func set_block(value: int) -> void:
	current_block = clampi(value, 0, 9999)
	Stats_Changed.emit()

func heal(amount: int) -> void:
	self.current_health += amount
	if amount > 0:
		for effect in ActiveEffects:
			if effect is BloodDebt:
				effect.on_heal(self)
				break

## Any SAN restore also strips every stack of Horrified from the healer.
## This is the only way to remove it, and it is the enemies' counterplay.
func san_heal(amount: int) -> void:
	self.current_sanity = clampi(self.current_sanity + amount, 0, self.Max_SAN)
	if amount <= 0:
		return
	sanity_restored.emit(amount, entity_name)
	if damage_number_anchor:
		DamageNumbers.display_san_number(amount, damage_number_anchor, damage_numbers, true)
	var horrified := get_status(Horrified)
	if horrified:
		horrified.on_remove(self)
		Events.effect_applied.emit()

func take_damage(amount: int, damagetype: DamageType) -> void:
	self.current_health -= amount

## Shared by player and enemies (CharacterInstance no longer overrides this).
## SAN Shield absorbs first; sanity_damage_taken carries the amount that got through,
## which is what Horrified's Breaking Point reads.
func take_san_damage(amount: int) -> void:
	if amount <= 0:
		return
	if current_san_block > 0:
		var original := amount
		amount = clampi(amount - current_san_block, 0, amount)
		current_san_block = clampi(current_san_block - original, 0, current_san_block)
	if amount <= 0:
		return
	self.current_sanity -= amount
	sanity_damage_taken.emit(amount, entity_name)
	if damage_number_anchor:
		DamageNumbers.display_san_number(amount, damage_number_anchor, damage_numbers)

func _get_max_hp() -> int:
	return _max_hp  # Now just returns the backing variable

func _get_max_san() -> int:
	return _max_san

func get_status(status_script: Script) -> StatusEffect:
	for effect in ActiveEffects:
		if effect and effect.get_script() == status_script:
			return effect
	return null

func is_stunned() -> bool:
	return get_status(Stunned) != null

func is_concussed() -> bool:
	for effect in ActiveEffects:
		if effect is Concussed:
			return true
	return false
func cleanse_status(statuses: Array[StatusEffect]) -> void:
	for debuff in ActiveEffects:
		var found = debuff.find_same_effect(ActiveEffects)
		if found:
			found.on_remove(self)
