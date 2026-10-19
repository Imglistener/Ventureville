extends BuffCard
## Reduces the AP and MP cost of every Blood Weapon in your hand until the end of your turn.
## Same approach as Blood Aias (edits the shared Card resource, then emits card_cost_changed),
## but the reduction is recorded so it can be undone at PlayerBattleEnd.
## target = SELF, is_card_nullable = true.

@export var reduction: int = 3

# Card -> Vector2i(ap_reduced, mp_reduced). Actual amounts, so clamping at 0 restores correctly.
var _reductions: Dictionary = {}


func _hand_weapons(character: CharacterInstance) -> Array[Card]:
	var found: Array[Card] = []
	if not character or not character.starting_deck:
		return found
	for card in character.starting_deck.TheHand:
		# TheHand holds shared resources, so duplicates count once.
		if card and card.tags.has(TAG_BLOOD_WEAPON) and not found.has(card):
			found.append(card)
	return found


func _execute(player: Stat_Manager, _targets: Array[Node]) -> void:
	for card in _hand_weapons(player.Player):
		var ap_cut := mini(reduction, card.ap_cost)
		var mp_cut := mini(reduction, card.mp_cost)
		if ap_cut == 0 and mp_cut == 0:
			continue
		card.ap_cost -= ap_cut
		card.mp_cost -= mp_cut
		var prev: Vector2i = _reductions.get(card, Vector2i.ZERO)
		_reductions[card] = prev + Vector2i(ap_cut, mp_cut)
		Events.card_cost_changed.emit(card)

	if not _reductions.is_empty() and not Events.PlayerBattleEnd.is_connected(_restore_costs):
		Events.PlayerBattleEnd.connect(_restore_costs, CONNECT_ONE_SHOT)
	Events.effect_applied.emit()   # hand.refresh_playable: cheaper cards may now be playable


func _restore_costs(_phase: Variant = null) -> void:
	for card in _reductions:
		var cut: Vector2i = _reductions[card]
		card.ap_cost += cut.x
		card.mp_cost += cut.y
		Events.card_cost_changed.emit(card)
	_reductions.clear()


func get_live_description(character: CharacterInstance, _live_targets: Array[Node]) -> String:
	var count := _hand_weapons(character).size()
	return Description + "\n(Affects %d Blood Weapon%s in hand)" % [count, "" if count == 1 else "s"]
