class_name EnemyBattlerStats extends BaseBattlerStats

enum DC{BASIC, ELITE, BOSS, OVERLORD}
@export_group("Enemy Stats")
@export var Base_HP : int = 100
@export var Base_SAN: int = 80
@export var Resists	: DamageType.DAMAGETYPE
@export var Is_Vul_to: DamageType.DAMAGETYPE

@export_group("Basic Variables")
@export var EnemyName: String
@export var Difficulty: DC
@export var Has_Phase_2: bool
@export var Battler_Art_Normal	: Texture
@export var Battler_Art_Hovered	: Texture
@export var Phase_2 : EnemyBattlerStats
@export var DamageBonus: float


@export_group("Dialogue")
@export var Dialogue: Array[DialogueLine]


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
	self.current_block = clampi(current_block - initial_damage, 0 , current_block)
	if damage_type:
		if damage_type.Damage_Type == Resists:
			damage = damage * 0.50
		elif damage_type.Damage_Type == Is_Vul_to:
			damage = damage * 1.500
	self.current_health -= damage
	DamageNumbers.display_number(damage, true, damage_numbers)

func create_instance() -> Resource:
	var instance: EnemyBattlerStats = self.duplicate()
	instance.current_health = self.Max_HP
	instance.current_sanity = self.Max_SAN
	instance.current_block = 0	
	instance.initialize_damage_bonus()

	return instance
