class_name EssenceVampirismCondition
extends BattleCondition
## Passive, event-driven: the FIRST time a Blood Syphon is applied each turn, the owner gains Regeneration.
## "Turn" resets at the start of the owner's turn (Events.PlayerStandbyStart), so it covers the owner's turn
## and the enemy turn that follows.
## The tier is re-checked on every trigger, so it upgrades/downgrades live:
##   Ascendant Form active   -> Essence Voracity  (form_amount)
##   else Ascendant Ritual   -> Essence Gluttony  (ritual_amount)
##   else                    -> Essence Vampirism (base_amount)
## The label next to the icon shows the Regeneration available this turn, or 0 once it has been used.
## Needs Events.status_applied.

enum Tier { BASE, RITUAL, FORM }

@export var regeneration: Regeneration          # Regeneration.tres
## false = any Blood Syphon applied to anyone counts. true = only Syphon applied to non-owners.
@export var enemies_only: bool = false

@export_group("Tiers")
@export var base_amount: int = 1
@export var ritual_amount: int = 2
@export var form_amount: int = 5
@export var base_name: String = "Essence Vampirism"
@export var ritual_name: String = "Essence Gluttony"
@export var form_name: String = "Essence Voracity"
@export var base_icon: Texture2D
@export var ritual_icon: Texture2D
@export var form_icon: Texture2D

var _owner: CharacterInstance
var _player: Stat_Manager
var _used_this_turn: bool = false


func activate(targets: Array[Node]) -> void:
	var player := targets[0].get_tree().get_first_node_in_group('player') as Stat_Manager
	if not player or find_same_effect(player.Player.BattleConditions):
		return
	var instance := self.duplicate() as EssenceVampirismCondition
	instance._owner = player.Player
	instance._player = player
	instance._used_this_turn = false
	Events.status_applied.connect(instance._on_status_applied)
	Events.PlayerStandbyStart.connect(instance._on_player_standby_start)
	player.Player.BattleConditions.append(instance)
	instance._sync_tier()
	Events.BattleConditionActivated.emit(instance, player.Player)
	Events.effect_display.emit(instance, player.Player.damage_number_anchor, player.Player.damage_number_anchor.global_position)


## Label = Regeneration you will gain from the next Syphon this turn (0 once spent).
## Also refreshes name/description/icon, because ActiveEffectManager calls this regularly
## and the tooltip reads those fields directly.
func get_display_text() -> String:
	_sync_tier()
	return "0" if _used_this_turn else str(_current_amount())


func _on_player_standby_start(_phase: Variant = null) -> void:
	if not _owner or not _owner.BattleConditions.has(self):
		_stop_listening()
		return
	if _used_this_turn:
		_used_this_turn = false
		Events.effect_applied.emit()   # refresh the label


func _on_status_applied(status: StatusEffect, entity: BaseBattlerStats) -> void:
	# Events outlives the battle: stop listening once we are no longer an active condition.
	if not _owner or not _owner.BattleConditions.has(self):
		_stop_listening()
		return
	if status is not BloodSyphon:
		return
	if enemies_only and entity == _owner:
		return
	if _used_this_turn:
		return
	var gain := _current_amount()
	if gain <= 0 or not regeneration:
		return
	# Flag first: Regeneration.on_apply refreshes the UI, and it should already show the spent state.
	_used_this_turn = true
	var self_target: Array[Node] = [_player]
	regeneration.on_apply(self_target, gain)


func _tier() -> Tier:
	if _owner:
		var has_ritual := false
		for condition in _owner.BattleConditions:
			if condition is AscendantFormCondition:
				return Tier.FORM
			if condition is AscendantRitualCondition:
				has_ritual = true
		if has_ritual:
			return Tier.RITUAL
	return Tier.BASE


func _current_amount() -> int:
	match _tier():
		Tier.FORM:
			return form_amount
		Tier.RITUAL:
			return ritual_amount
		_:
			return base_amount


func _sync_tier() -> void:
	var amount := _current_amount()
	var new_name := base_name
	var new_icon := base_icon
	match _tier():
		Tier.FORM:
			new_name = form_name
			new_icon = form_icon if form_icon else base_icon
		Tier.RITUAL:
			new_name = ritual_name
			new_icon = ritual_icon if ritual_icon else base_icon
	condition_name = new_name
	if new_icon:
		condition_icon = new_icon
	condition_description = "Once per turn, when Blood Syphon is applied, gain %d Regeneration." % amount


func _stop_listening() -> void:
	if Events.status_applied.is_connected(_on_status_applied):
		Events.status_applied.disconnect(_on_status_applied)
	if Events.PlayerStandbyStart.is_connected(_on_player_standby_start):
		Events.PlayerStandbyStart.disconnect(_on_player_standby_start)


func on_expired(targets: Array[Node]) -> void:
	_stop_listening()
	super(targets)
