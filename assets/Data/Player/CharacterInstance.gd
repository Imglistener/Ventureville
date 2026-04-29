class_name CharacterInstance extends BaseBattlerStats

@export var starting_deck	: Deck
@export var draw_power		: int
@export var max_mana		: int



var mana: int : set = set_mana
var battle_deck : Deck
var discard		: Deck
var draw_deck	: Deck

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
		DamageNumbers.display_number(final_damage, false, damage_numbers)
		self.current_health -= final_damage
		damage_taken.emit(final_damage, entity_name)
	
	else:
		self.current_health -= damage
		DamageNumbers.display_number(damage, false, damage_numbers)
		damage_taken.emit(damage, entity_name)
	if self.current_health == 0:
			entity_died.emit(entity_name)

func reset_mana() -> void:
	self.mana = max_mana

func heal(amount: int) -> void:
	DamageNumbers.display_healing_number(amount, false, damage_numbers)
	self.current_health += amount
	health_restored.emit(amount, entity_name)

func card_IsPlayable(card: Card) -> bool:
	return self.mana >= card.mp_cost and self.AP >= card.ap_cost

#in case of new game:
func create_instance() -> Resource:
	var instance: CharacterInstance = self.duplicate()
	instance.current_health = Max_HP
	instance.current_sanity = Max_SAN
	instance.current_block = 0
	instance.reset_mana()
	instance.battle_deck = instance.starting_deck.duplicate()
	instance.draw_deck	= Deck.new()
	instance.discard = Deck.new()
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
	instance.draw_deck = Deck.new()
	instance.discard = Deck.new()
	

	return instance
