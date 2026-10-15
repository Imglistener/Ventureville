class_name RitualisticGleeCondition
extends BattleCondition
## Passive, event-driven. Every Nth Buff card the owner plays (default 3), the Glee triggers:
## if that Buff card nulls itself, gain AP and Regeneration.
##
## Events.card_played fires BEFORE the card's cost is deducted, so granting AP right there
## would be eaten by the cost (and clamped at 3). The grant is deferred until the card has finished resolving.
## The label next to the icon shows progress, e.g. "2/3".

@export var regeneration: Regeneration          # Regeneration.tres
@export var ap_gain: int = 1
@export var regen_gain: int = 2
## true  = AP and Regeneration both require the Buff card to null itself.
## false = AP on every triggering Buff card, Regeneration only when it nulls.
@export var ap_requires_null: bool = true
## The condition triggers on every Nth Buff card played.
@export var buffs_required: int = 3
## false = every Buff card counts toward N (the Nth one may not null, wasting the trigger).
## true  = only Buff cards that null themselves count toward N.
@export var count_only_nulling: bool = false

var _owner: CharacterInstance
var _player: Stat_Manager
var _buffs_played: int = 0


func activate(targets: Array[Node]) -> void:
	var player := targets[0].get_tree().get_first_node_in_group('player') as Stat_Manager
	if not player or find_same_effect(player.Player.BattleConditions):
		return
	var instance := self.duplicate() as RitualisticGleeCondition
	instance._owner = player.Player
	instance._player = player
	instance._buffs_played = 0
	instance._sync_text()
	Events.card_played.connect(instance._on_card_played)
	player.Player.BattleConditions.append(instance)
	Events.BattleConditionActivated.emit(instance, player.Player)
	Events.effect_display.emit(instance, player.Player.damage_number_anchor, player.Player.damage_number_anchor.global_position)


## Progress toward the next trigger, e.g. "2/3".
func get_display_text() -> String:
	_sync_text()
	return "%d/%d" % [_buffs_played, buffs_required]


func _on_card_played(card: Card) -> void:
	# Events outlives the battle: stop listening once we are no longer an active condition.
	if not _owner or not _owner.BattleConditions.has(self):
		_stop_listening()
		return
	if not card or card.type != Card.Type.BUFF:
		return
	var nulls := card.is_card_nullable
	if count_only_nulling and not nulls:
		return

	_buffs_played += 1
	Events.effect_applied.emit()   # refresh the progress label
	if _buffs_played < buffs_required:
		return
	_buffs_played = 0

	var grant_ap := nulls or not ap_requires_null
	if not grant_ap and not nulls:
		return
	_grant.call_deferred(grant_ap, nulls)


func _grant(grant_ap: bool, grant_regen: bool) -> void:
	if not _owner or not _owner.BattleConditions.has(self):
		return
	if grant_ap and ap_gain > 0:
		_owner.AP += ap_gain
	if grant_regen and regen_gain > 0 and regeneration:
		var self_target: Array[Node] = [_player]
		regeneration.on_apply(self_target, regen_gain)
	var anchor := _owner.damage_number_anchor
	if anchor:
		Events.effect_display.emit(self, anchor, anchor.global_position)


func _sync_text() -> void:
	var counted := "Buff card" if not count_only_nulling else "Buff card that nulls itself"
	var reward := "gain %d AP and %d Regeneration" % [ap_gain, regen_gain]
	if ap_requires_null:
		condition_description = "Every %d %ss you play: if it nulls itself, %s." % [buffs_required, counted, reward]
	else:
		condition_description = "Every %d %ss you play: gain %d AP, and %d Regeneration if it nulls itself." % [buffs_required, counted, ap_gain, regen_gain]


func _stop_listening() -> void:
	if Events.card_played.is_connected(_on_card_played):
		Events.card_played.disconnect(_on_card_played)


func on_expired(targets: Array[Node]) -> void:
	_stop_listening()
	super(targets)
