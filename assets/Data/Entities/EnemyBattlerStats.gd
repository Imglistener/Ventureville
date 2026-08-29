class_name EnemyBattlerStats extends BaseBattlerStats

enum DC{BASIC, ELITE, BOSS, OVERLORD}
enum RESISTANCE_STATE {NEUTRAL, RESISTANT, VULNERABLE}

@export_group("Enemy Stats")
@export var Base_HP : int = 100
@export var Base_SAN: int = 80
@export var Resists	: DamageType.DAMAGETYPE
@export var Is_Vul_to: DamageType.DAMAGETYPE

@export_group("Basic Variables")
@export var Difficulty: DC
@export var Has_Phase_2: bool
@export var Battler_Art_Normal	: Texture
@export var Battler_Art_Hovered	: Texture
@export var Phase_2 : EnemyBattlerStats
@export var DamageBonus: float


@export_group("Dialogue")
@export var Dialogue: Array[DialogueLine]


func get_resistance_state(damage_type: DamageType) -> RESISTANCE_STATE:
	if not damage_type:
		return RESISTANCE_STATE.NEUTRAL
	if damage_type.Damage_Type == Resists:
		return RESISTANCE_STATE.RESISTANT
	elif damage_type.Damage_Type == Is_Vul_to:
		return RESISTANCE_STATE.VULNERABLE
	return RESISTANCE_STATE.NEUTRAL

func calculate_type_adjusted_damage(damage: int, damage_type: DamageType = null) -> int:
	match get_resistance_state(damage_type):
		RESISTANCE_STATE.RESISTANT:
			return int(damage * 0.5)
		RESISTANCE_STATE.VULNERABLE:
			return int(damage * 1.5)
		_:
			return damage
func initialize_damage_bonus() -> void:
	match Difficulty:
		DC.BASIC:
			DamageBonus = 1.0
		DC.ELITE:
			DamageBonus = 1.25
		DC.BOSS:
			DamageBonus = 1.5
		DC.OVERLORD:
			DamageBonus = 2.0

func _get_max_hp() -> int:
	match Difficulty:
		DC.BASIC:
			return Base_HP
		DC.ELITE:
			return Base_HP * 1.25
		DC.BOSS:
			return Base_HP * 1.5
		DC.OVERLORD:
			return Base_HP*2
	return Base_HP

func _get_max_san() -> int:
	match Difficulty:
		DC.BASIC:
			return Base_SAN
		DC.ELITE:
			return Base_SAN * 1.25
		DC.BOSS:
			return Base_SAN * 1.5
		DC.OVERLORD:
			return Base_SAN*2
	return Base_SAN

func take_damage(damage: int, damage_type: DamageType = null) -> void:
	var initial_damage = damage
	damage = clampi(damage - current_block, 0, damage)
	self.current_block = clampi(current_block - initial_damage, 0, current_block)
	damage = calculate_type_adjusted_damage(damage, damage_type)
	self.current_health -= damage
	DamageNumbers.display_number(damage, damage_number_anchor, damage_numbers)
	damage_taken.emit(damage, entity_name) 
	if self.current_health == 0:
			entity_died.emit(entity_name)

func heal(amount: int) -> void:
	DamageNumbers.display_healing_number(amount, damage_number_anchor, damage_numbers)
	self.current_health += amount
	health_restored.emit(amount, entity_name)
	
	
func create_instance() -> Resource:
	var instance: EnemyBattlerStats = self.duplicate()
	instance.current_health = self.Max_HP
	instance.current_sanity = self.Max_SAN
	instance.current_block = 0	
	instance.initialize_damage_bonus()

	return instance
