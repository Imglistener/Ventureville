extends VoiceAttackCard
## Hits every enemy for (scaled / 2) x the number of UNIQUE status effects on THAT enemy.
## Free to play while at least `free_status_threshold` different statuses exist across all enemies.
## {scaled} in the description is the damage PER unique status.
## .tres: target = ALLENEMIES (2), orchestrate_enabled = true, orchestrate_type = DEBUFF (2).

@export var damage_fraction: float = 0.5
@export var free_status_threshold: int = 3


func _calculate_total(character: CharacterInstance) -> int:
	return int(super(character) * damage_fraction)


# ------------------------------------------------------------------ status counting

## Distinct status scripts on one entity (two stacks of Burning count once).
func _status_scripts(entity: BaseBattlerStats) -> Array:
	var found: Array = []
	if not entity:
		return found
	for effect in entity.ActiveEffects:
		if effect and not found.has(effect.get_script()):
			found.append(effect.get_script())
	return found


func _living_enemies() -> Array[BaseBattlerStats]:
	var result: Array[BaseBattlerStats] = []
	var tree := Engine.get_main_loop() as SceneTree
	var manager := tree.get_first_node_in_group("EnemyManager") as EnemyManager
	if not manager:
		return result
	for view in manager.get_enemy_views():
		var entity := _entity_of(view)
		if entity and entity.current_health > 0:
			result.append(entity)
	return result


func _is_free() -> bool:
	if not _check_orchestrate(false):
		return false
	var distinct: Array = []
	for entity in _living_enemies():
		for status_script in _status_scripts(entity):
			if not distinct.has(status_script):
				distinct.append(status_script)
	return distinct.size() >= free_status_threshold


# ------------------------------------------------------------------ cost override (needs the Card.gd change below)

func get_ap_cost() -> int:
	return 0 if _is_free() else ap_cost


func get_mp_cost() -> int:
	return 0 if _is_free() else mp_cost


# ------------------------------------------------------------------ play

func _execute(player: Stat_Manager, targets: Array[Node]) -> void:
	var per_status := _calculate_total(player.Player)

	# Count everything BEFORE dealing damage, so a hit can't change another enemy's count mid-loop.
	var hits: Array = []   # [EnemyView, damage]
	for t in targets:
		if t is not EnemyView:
			continue
		var entity := _entity_of(t)
		if not entity or entity.current_health <= 0:
			continue
		var count := _status_scripts(entity).size()
		if count > 0:
			hits.append([t, per_status * count])

	for hit in hits:
		var single: Array[Node] = [hit[0]]
		_deal_damage(single, hit[1])


# ------------------------------------------------------------------ preview

# The live preview shows the damage the FIRST aimed enemy would take, like Crescendo does.
func _preview_value(character: CharacterInstance, enemy: EnemyBattlerStats, apply_resistance: bool) -> int:
	var total := _calculate_total(character) * _status_scripts(enemy).size()
	return enemy.calculate_type_adjusted_damage(total, damage_type) if apply_resistance else total


func get_live_description(character: CharacterInstance, live_targets: Array[Node]) -> String:
	var text := super(character, live_targets)
	if _is_free():
		text += "\n(Free to play)"
	return text
