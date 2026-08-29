class_name CharacterInstance extends BaseBattlerStats
enum PlayerClasses{BloodMagus, DarkMagus, VoiceMagus, FoulTarnished}

@export var starting_deck	: Deck
@export var draw_power		: int
@export var max_mana		: int
@export var player_class : PlayerClasses
@export var player_portrait: Texture
@export var player_inventory: Inventory

var AP: int : set = set_AP
var mana: int : set = set_mana
var battle_deck : Deck
var character_level: int = 0


func set_AP(value: int) -> void:
	AP = clampi(value, 0, 3)
	Stats_Changed.emit()

func set_mana(value: int) -> void:
	mana = value
	Stats_Changed.emit()

func take_damage(damage : int, damage_type: DamageType) -> void:
	if damage <= 0:
		return
	var initial_damage = damage
	damage = clampi(damage - current_block, 0, damage)
	self.current_block = clampi(current_block - initial_damage, 0 , current_block)
	if damage_type:
		var resistance = damage_type.Associated_Stat.stat_resistance_value
		var final_damage := clampi(damage - resistance, 0, damage)
		DamageNumbers.display_number(final_damage, damage_number_anchor, damage_numbers)
		self.current_health -= final_damage
		damage_taken.emit(final_damage, entity_name)
	
	else:
		self.current_health -= damage
		DamageNumbers.display_number(damage, damage_number_anchor, damage_numbers)
		damage_taken.emit(damage, entity_name)
	if self.current_health == 0:
			entity_died.emit(entity_name)
	
	Stats_Changed.emit()
func set_character_level()-> void:
	for stat in stats:
		character_level += stat.stat_level
		 
func reset_mana() -> void:
	self.mana = max_mana

func reset_AP() -> void:
	self.AP = 3

func take_san_damage(amount: int) -> void:
	if self.current_san_block > 0:
		var origina_amount = amount
		amount = clampi(amount - self.current_san_block, 0, amount)
		self.current_san_block = clampi(self.current_san_block - origina_amount, 0, self.current_san_block)
	super(amount)
	sanity_damage_taken.emit(amount, entity_name)
	Stats_Changed.emit()
	

func heal(amount: int) -> void:
	DamageNumbers.display_healing_number(amount, damage_number_anchor, damage_numbers)
	self.current_health += amount
	health_restored.emit(amount, entity_name)
	Stats_Changed.emit()

func card_IsPlayable(card: Card) -> bool:
	return self.mana >= card.mp_cost and self.AP >= card.ap_cost

#in case of new game:
func create_instance() -> Resource:
	var instance: CharacterInstance = self.duplicate()
	instance.current_health = Max_HP
	instance.current_sanity = Max_SAN
	instance.current_block = 0
	instance.reset_mana()
	instance.reset_AP()
	instance.battle_deck = instance.starting_deck.duplicate()
	instance.set_character_level()
	instance.player_inventory = instance.player_inventory.new_inventory()
	return instance
#Load Character:
func Load_Player() -> Resource:
	var instance: CharacterInstance = self.duplicate(true) # true = deep copy
	instance.load_stats()                  # derive Max_HP, Max_SAN from StatInstances
	instance.current_health = instance.Max_HP
	instance.current_sanity = instance.Max_SAN
	instance.current_block = 0
	instance.current_block = 0
	instance.reset_mana()
	instance.battle_deck = instance.starting_deck.duplicate()
	instance.set_character_level()
	instance.reset_AP()

	return instance
