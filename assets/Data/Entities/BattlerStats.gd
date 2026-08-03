class_name BaseBattlerStats extends Resource
signal Stats_Changed

enum BATTLER_TYPES {PLAYER , ENEMY}
signal damage_taken(amount: int, entity_name: String)
signal sanity_damage_taken(amount: int, entity_name: String)
signal health_restored(amount: int, entity_name: String)
signal sanity_restored(amount: int, entity_name: String)
signal block_gained(amount: int, entity_name: String)
signal san_block_gained(amount: int, entity_name: String)
signal entity_died(entity_name: String)

@export_group("Basic Stats")
@export var entity_name : String
@export var Battler_Type: BATTLER_TYPES


@export_group("Player Stats")
@export var stats : Array[StatInstance] = []
var ActiveEffects: Array[StatusEffect] = []
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
var buff_damage_modifier: int

func modify_buff_modifier(amount: int) -> void:
	buff_damage_modifier = amount
	Stats_Changed.emit()

func true_take_damage(amount: int) -> void:
	current_health -= amount
	Stats_Changed.emit()
	damage_taken.emit(amount, entity_name)
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
	current_health = clampi(value, 0, 9999)
	Stats_Changed.emit()
func set_sanity(value: int) -> void:
	current_sanity = clampi(value, 0, 9999)
	Stats_Changed.emit()
func set_san_block(value: int) -> void:
	current_san_block = clampi(value, 0, 99999999)
	Stats_Changed.emit()
func set_block(value: int) -> void:
	current_block = clampi(value, 0, 99999999)
	Stats_Changed.emit()
	
func heal(amount: int) -> void:
	self.current_health += amount
func san_heal(amount: int) -> void:
	self.current_sanity = clampi(self.current_sanity + amount, 0, self.Max_SAN)
	
func take_damage(amount: int, damagetype: DamageType) -> void:
	self.current_health -= amount
func take_san_damage(amount: int) -> void:
	self.current_sanity -= amount
	
func _get_max_hp() -> int:
	return _max_hp  # Now just returns the backing variable
	
func _get_max_san() -> int:
	return _max_san
