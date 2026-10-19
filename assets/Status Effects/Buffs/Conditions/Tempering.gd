class_name TemperingCondition
extends BattleCondition
## One-shot. While armed, every Blood Weapon in hand (and any drawn later) costs `ap_reduction`
## less AP. The first Blood Weapon played spends it: costs are restored right after that card
## is paid for, and its damage gets +30% through modify_outgoing_damage for a short window.
## If no Blood Weapon is played, it expires at the end of the player's turn.

@export var ap_reduction: int = 1
@export var damage_multiplier: float = 1.3
## Seconds the bonus stays on after the weapon is played, so multi-hit cards
## (Blood Scythe, Blood Chakram) get it on every hit.
@export var bonus_window: float = 0.6

var _owner: CharacterInstance
var _player: Stat_Manager
var _cut: Dictionary = {}      # Card -> AP actually removed (so clamping at 0 restores correctly)
var _spent := false
var _bonus_active := false


func activate(targets: Array[Node]) -> void:
	var player := targets[0].get_tree().get_first_node_in_group('player') as Stat_Manager
	if not player or find_same_effect(player.Player.BattleConditions):
		return
	var instance := self.duplicate() as TemperingCondition
	instance._owner = player.Player
	instance._player = player
	instance._discount_hand()
	Events.card_played.connect(instance._on_card_played)
	Events.card_drawn.connect(instance._on_card_drawn)
	player.Player.BattleConditions.append(instance)
	Events.BattleConditionActivated.emit(instance, player.Player)
	Events.effect_display.emit(self, player.Player.damage_number_anchor, player.Player.damage_number_anchor.global_position)
	Events.effect_applied.emit()   # hand.refresh_playable: cheaper cards may now be playable


func modify_outgoing_damage(amount: int, _defender: BaseBattlerStats) -> int:
	return roundi(amount * damage_multiplier) if _bonus_active else amount


# Passive tick runs at the end of the player's turn: expire if unused.
func on_tick(targets: Array[Node]) -> void:
	on_expired(targets)


func _discount_hand() -> void:
	if not _owner or not _owner.starting_deck:
		return
	for card in _owner.starting_deck.TheHand:
		_discount(card)


func _discount(card: Card) -> void:
	if not card or not card.tags.has(Card.TAG_BLOOD_WEAPON) or _cut.has(card) or card.ap_cost <= 0:
		return
	var cut := mini(ap_reduction, card.ap_cost)
	_cut[card] = cut
	card.ap_cost -= cut
	Events.card_cost_changed.emit(card)


func _restore_costs() -> void:
	for card in _cut:
		card.ap_cost += _cut[card]
		Events.card_cost_changed.emit(card)
	_cut.clear()
	Events.effect_applied.emit()


func _on_card_drawn(card: Card) -> void:
	if not _is_active() or _spent:
		return
	_discount(card)


func _on_card_played(card: Card) -> void:
	if not _is_active():
		_stop_listening()
		return
	if _spent or not card or not card.tags.has(Card.TAG_BLOOD_WEAPON):
		return
	_spent = true
	_bonus_active = true
	# card_played fires BEFORE the cost is deducted, so restore after the card is paid for.
	_restore_costs.call_deferred()
	var tree := Engine.get_main_loop() as SceneTree
	tree.create_timer(bonus_window).timeout.connect(_expire_now)


func _expire_now() -> void:
	if _is_active() and is_instance_valid(_player):
		var targets: Array[Node] = [_player]
		on_expired(targets)


func _is_active() -> bool:
	return _owner != null and _owner.BattleConditions.has(self)


func _stop_listening() -> void:
	if Events.card_played.is_connected(_on_card_played):
		Events.card_played.disconnect(_on_card_played)
	if Events.card_drawn.is_connected(_on_card_drawn):
		Events.card_drawn.disconnect(_on_card_drawn)


func on_expired(targets: Array[Node]) -> void:
	_bonus_active = false
	_stop_listening()
	_restore_costs()
	super(targets)
