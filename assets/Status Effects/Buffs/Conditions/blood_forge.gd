class_name BloodForgeCondition
extends BattleCondition
## Passive, event-driven: heals whenever the owner draws a card tagged Card.TAG_BLOOD_WEAPON.
## Heals more while Ascendant Ritual (from the Ascendant State card) is also active.

@export var heal_amount: int = 5
@export var ascendant_heal_amount: int = 10

var _owner: CharacterInstance


func activate(targets: Array[Node]) -> void:
	var player := targets[0].get_tree().get_first_node_in_group('player') as Stat_Manager
	if not player or find_same_effect(player.Player.BattleConditions):
		return
	var instance := self.duplicate() as BloodForgeCondition
	instance._owner = player.Player
	Events.card_drawn.connect(instance._on_card_drawn)
	player.Player.BattleConditions.append(instance)
	Events.BattleConditionActivated.emit(instance, player.Player)
	Events.effect_display.emit(self, player.Player.damage_number_anchor, player.Player.damage_number_anchor.global_position)


func _on_card_drawn(card: Card) -> void:
	# Events is an autoload and outlives the battle: stop listening once we're no longer active.
	if not _owner or not _owner.BattleConditions.has(self):
		_stop_listening()
		return
	if card and card.tags.has(Card.TAG_BLOOD_WEAPON):
		_owner.heal(_current_heal())


func _current_heal() -> int:
	for condition in _owner.BattleConditions:
		if condition is AscendantRitualCondition:
			return ascendant_heal_amount
	return heal_amount


func _stop_listening() -> void:
	if Events.card_drawn.is_connected(_on_card_drawn):
		Events.card_drawn.disconnect(_on_card_drawn)


func on_expired(targets: Array[Node]) -> void:
	_stop_listening()
	super(targets)
