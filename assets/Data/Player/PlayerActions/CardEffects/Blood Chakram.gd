extends AttackCard
## Hits a random living enemy `hits` times. Each hit applies Blood Syphon if the target
## has no Shield. Set target = ALLENEMIES in the .tres (so `targets` holds every enemy),
## plus the &"BloodWeapon" tag.

@export var blood_syphon: BloodSyphon
@export var hits: int = 3
@export var syphon_stacks: int = 2
@export var hit_delay: float = 0.2


func _alive_enemies(targets: Array[Node]) -> Array[Node]:
	var alive: Array[Node] = []
	for t in targets:
		if t is EnemyView and t.Enemy and t.Enemy.Entity and t.Enemy.Entity.current_health > 0:
			alive.append(t)
	return alive


func _execute(player: Stat_Manager, targets: Array[Node]) -> void:
	var tree := player.get_tree()
	for i in hits:
		if i > 0:
			await tree.create_timer(hit_delay).timeout
		# Re-pick every hit so a kill mid-volley redirects the rest.
		var alive := _alive_enemies(targets)
		if alive.is_empty():
			break
		var view: Node = alive.pick_random()
		var single: Array[Node] = [view]
		_deal_damage(single, _calculate_total(player.Player))
		_apply_status(blood_syphon, single, syphon_stacks, true)
