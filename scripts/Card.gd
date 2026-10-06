class_name Card extends Resource

enum Type{ATTACK, BUFF, DEBUFF, DEFEND}
enum Target{SELF, ONEENEMY, ALLENEMIES, ALL}
enum Rarities{Common, Rare, Legendary}
enum CardAttribute{Hemomancy, Entromancy, Phonomancy, Somatomancy}

const TAG_BLOOD_WEAPON := &"BloodWeapon"

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

# Not exported: each subclass sets this in _init() so the script and the type can't disagree.
var type: Type = Type.ATTACK


# ------------------------------------------------------------------ public API (unchanged)

func is_SingleTarget() -> bool:
	return target == Target.ONEENEMY

func get_description(_character: CharacterInstance) -> String:
	return Description

func get_live_description(_character: CharacterInstance, _live_targets: Array[Node]) -> String:
	return get_description(_character)

func activate_card(targets: Array[Node], characterstats: CharacterInstance) -> void:
	Events.card_played.emit(self)
	characterstats.mana -= mp_cost
	characterstats.AP -= ap_cost
	if is_SingleTarget():
		apply_effect(targets)
	else:
		apply_effect(_get_targets(targets))

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


# ------------------------------------------------------------------ template method
# Cards that still override apply_effect() directly keep working, so you can migrate one at a time.

func apply_effect(targets: Array[Node]) -> void:
	if targets.is_empty() or not targets[0]:
		return
	var player := _get_player(targets)
	if not player:
		return
	_execute(player, targets)

## Override this in individual cards.
func _execute(_player: Stat_Manager, _targets: Array[Node]) -> void:
	pass


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
