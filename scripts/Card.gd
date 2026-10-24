class_name Card extends Resource

enum Type{ATTACK, BUFF, DEBUFF, DEFEND}
enum Target{SELF, ONEENEMY, ALLENEMIES, ALL}
enum Rarities{Common, Rare, Legendary}
enum CardAttribute{Hemomancy, Entromancy, Phonomancy, Somatomancy}
## PREVIOUS_CARD: the card played immediately before this one must be the declared type.
## ANY_EARLIER: any earlier card this turn of the declared type is enough.
enum OrchestrateMode{PREVIOUS_CARD, ANY_EARLIER}

const TAG_BLOOD_WEAPON := &"BloodWeapon"
const TAG_FIRST_RITE := &"FirstRite"
const TAG_SECOND_RITE := &"SecondRite"
const TAG_CADENZA := &"Cadenza"
const TAG_ORCHESTRATE:= &"Orchestrate"

@export_group("Card Details")
@export var name: String
@export var rarity: Rarities
@export var attribute: CardAttribute
@export var target: Target
@export var mp_cost: int
@export var ap_cost: int
@export var is_card_nullable: bool = false
@export var blood_tax: int = 0   # HP sacrificed on play (unblockable). Used via _pay_blood_tax().
## Free-form labels other systems can look for (e.g. Blood Forge heals on drawing TAG_BLOOD_WEAPON cards).
@export var tags: Array[StringName] = []
@export_multiline var Description: String
@export_multiline var LogMessage: String

## 'Orchestrate : CardType'. Write the keyword and the bonus text in Description yourself
## (e.g. "Orchestrate : Attack\nGain 1 AP."), then set the fields below so the code matches.
@export_group("Orchestrate")
@export var orchestrate_enabled: bool = false
@export var orchestrate_type: Type = Type.ATTACK
@export var orchestrate_mode: OrchestrateMode = OrchestrateMode.PREVIOUS_CARD
@export var orchestrate_bonus: OrchestrateBonus

# Not exported: each subclass sets this in _init() so the script and the type can't disagree.
var type: Type = Type.ATTACK
## True for the card currently being resolved when its Orchestrate condition was met.
## Set at the start of every play and left alone afterwards, so multi-hit cards that
## await between hits (Chakram, Scythe) still see it.
var orchestrated: bool = false


# ------------------------------------------------------------------ public API (unchanged)

func is_SingleTarget() -> bool:
	return target == Target.ONEENEMY

func get_description(_character: CharacterInstance) -> String:
	return Description

func get_live_description(_character: CharacterInstance, _live_targets: Array[Node]) -> String:
	return get_description(_character)

func activate_card(targets: Array[Node], characterstats: CharacterInstance) -> void:

	var mp := get_mp_cost()
	var ap := get_ap_cost()
	characterstats.mana -= mp
	characterstats.AP -= ap
	if is_SingleTarget():
		apply_effect(targets)
	else:
		apply_effect(_get_targets(targets))

	Events.card_played.emit(self)
func _get_targets(targets: Array[Node]) -> Array[Node]:
	if not targets:
		return []
	var tree := targets[0].get_tree()
	match target:
		Target.SELF:
			return tree.get_nodes_in_group("player")
		Target.ALLENEMIES:
			return tree.get_first_node_in_group("EnemyManager").get_enemy_views()
		Target.ALL:
			return tree.get_nodes_in_group("player") + tree.get_nodes_in_group("Enemies")
		_:
			return []

## Finds an ACTIVE battle condition on the player by script, e.g. _find_condition(player, AscendantRitualCondition)
func _find_condition(player: Stat_Manager, condition_script: Script) -> BattleCondition:
	for condition in player.Player.BattleConditions:
		if condition and condition.get_script() == condition_script:
			return condition
	return null
# ------------------------------------------------------------------ template method
# Cards that still override apply_effect() directly keep working, so you can migrate one at a time.

func apply_effect(targets: Array[Node]) -> void:
	if targets.is_empty() or not targets[0]:
		return
	var player := _get_player(targets)
	if not player:
		return
	orchestrated = _check_orchestrate(true)
	_execute(player, targets)
	if orchestrated:
		_apply_orchestrate_bonus(player, targets)
		Events.card_orchestrated.emit(self)

## Override this in individual cards.
func _execute(_player: Stat_Manager, _targets: Array[Node]) -> void:
	pass


# ------------------------------------------------------------------ Orchestrate

func _tracker() -> TurnTrackingManager:
	return (Engine.get_main_loop() as SceneTree).get_first_node_in_group("TurnTracker") as TurnTrackingManager

## include_current = true while resolving (this card is already in the list),
## false when previewing from the hand or while aiming.
func _check_orchestrate(include_current: bool) -> bool:
	if not orchestrate_enabled:
		return false
	var tracker := _tracker()
	if not tracker:
		return false
	if orchestrate_mode == OrchestrateMode.PREVIOUS_CARD:
		var previous := tracker.previous_card_this_turn(include_current)
		return previous != null and previous.type == orchestrate_type
	return tracker.played_type_before(orchestrate_type, include_current)

## Appended to the card text by CardUI: tells the player the condition is met right now.
func get_orchestrate_note() -> String:
	if _check_orchestrate(false):
		return "\n(Orchestrate active)"
	return ""

## Attack cards multiply their damage by this.
func _orchestrate_mult() -> float:
	return orchestrate_bonus.damage_multiplier if orchestrated and orchestrate_bonus else 1.0

func _apply_orchestrate_bonus(player: Stat_Manager, targets: Array[Node]) -> void:
	var b := orchestrate_bonus
	if not b:
		return
	var self_target: Array[Node] = [player]
	if b.shield > 0:
		var block := BlockEffect.new()
		block.amount = b.shield
		block.activate(self_target)
	if b.san_shield > 0:
		var san_block := SanBlockEffect.new()
		san_block.amount = b.san_shield
		san_block.activate(self_target)
	if b.heal_hp > 0:
		player.Player.heal(b.heal_hp)
	if b.heal_san > 0:
		player.Player.san_heal(b.heal_san)
	if b.ap > 0:
		player.Player.AP += b.ap
	if b.mp > 0:
		player.Player.mana += b.mp
	if b.status and b.status_stacks > 0:
		if b.status_on_self:
			_apply_status(b.status, self_target, b.status_stacks)
		else:
			_apply_to_enemies(b.status, targets, b.status_stacks)
	if b.draw > 0:
		_draw_cards(targets, b.draw)


# ------------------------------------------------------------------ shared helpers

func _get_player(targets: Array[Node]) -> Stat_Manager:
	if targets.is_empty() or not targets[0]:
		return null
	return targets[0].get_tree().get_first_node_in_group("player") as Stat_Manager

func _pay_blood_tax(player: Stat_Manager) -> void:
	if blood_tax > 0:
		player.Player.true_take_damage(blood_tax)

func _resolve_enemy_entity(node: Node) -> EnemyBattlerStats:
	var current := node
	while current:
		if current is EnemyView:
			return current.Enemy.Entity as EnemyBattlerStats
		current = current.get_parent()
	return null

func _resolve_enemies(live_targets: Array[Node]) -> Array[EnemyBattlerStats]:
	var enemies: Array[EnemyBattlerStats] = []
	for t in live_targets:
		var entity := _resolve_enemy_entity(t)
		if entity:
			enemies.append(entity)
	return enemies

## Finds an active status by its script, e.g. _find_status(entity.ActiveEffects, BloodSyphon)
func _find_status(effects: Array, status_script: Script) -> StatusEffect:
	for effect in effects:
		if effect and effect.get_script() == status_script:
			return effect
	return null

func _apply_status(effect: StatusEffect, targets: Array[Node], duration: int = 1, check_applicable: bool = false) -> void:
	if not effect:
		return
	if check_applicable and not effect.is_applicable(targets):
		return
	effect.on_apply(targets, duration)

func _apply_to_self(effect: StatusEffect, player: Stat_Manager, duration: int = 1) -> void:
	var self_target: Array[Node] = [player]
	_apply_status(effect, self_target, duration)

func _apply_to_enemies(effect: StatusEffect, targets: Array[Node], duration: int = 1, check_applicable: bool = false) -> void:
	var enemies: Array[Node] = []
	for t in targets:
		if t is EnemyView:
			enemies.append(t)
	if enemies.is_empty():
		return
	_apply_status(effect, enemies, duration, check_applicable)


# ------------------------------------------------------------------ entities, Blood Syphon, turn tracking

## The battle entity behind a target node (null if it isn't a battler).
func _entity_of(node: Node) -> BaseBattlerStats:
	if node is EnemyView:
		return node.Enemy.Entity if node.Enemy else null
	if node is Stat_Manager:
		return node.Player
	return null

## Ticks an entity's Blood Syphon once, exactly like the end-of-turn tick:
## damage = 2 x remaining duration (0 if blocking), then duration drops by 1.
func _trigger_blood_syphon(entity: BaseBattlerStats) -> void:
	var syphon := _find_status(entity.ActiveEffects, BloodSyphon) as BloodSyphon
	if not syphon:
		return
	syphon.on_tick(entity)
	if syphon.current_duration <= 0:
		syphon.on_remove(entity)
	Events.effect_applied.emit()   # refreshes status icons / turn counters

func _get_turn_tracker(player: Stat_Manager) -> TurnTrackingManager:
	return player.get_tree().get_first_node_in_group("TurnTracker") as TurnTrackingManager

func _sacrificed_this_turn(player: Stat_Manager) -> bool:
	var tracker := _get_turn_tracker(player)
	return tracker != null and tracker.sacrificed_this_turn(player)

func _draw_cards(targets: Array[Node], amount: int) -> void:
	var effect := DrawEffect.new()
	effect.amount = amount
	effect.activate(targets)
	
func get_ap_cost() -> int:
	return ap_cost
func get_mp_cost() -> int:
	return mp_cost
