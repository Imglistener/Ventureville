extends BuffCard
## Clears a configurable list of statuses from the player, then adds Blood Debt per status cleared.
## To extend the list later: add another StatusEffect .tres to `purgeable_statuses` in the inspector.
## Description placeholders: {statuses} -> auto-built name list, {debt} -> debt_per_status.

@export var purgeable_statuses: Array[StatusEffect] = []
@export var blood_debt: BloodDebt
@export var debt_per_status: int = 10


func _execute(player: Stat_Manager, _targets: Array[Node]) -> void:
	_pay_blood_tax(player)

	var removed := 0
	for status in purgeable_statuses:
		if not status:
			continue
		var active := _find_status(player.Player.ActiveEffects, status.get_script())
		if active:
			active.on_remove(player.Player)
			removed += 1

	if removed > 0:
		Events.effect_applied.emit()   # refresh status icons
		_apply_to_self(blood_debt, player, removed * debt_per_status)


func get_description(_character: CharacterInstance) -> String:
	return Description.replace("{statuses}", _status_list()).replace("{debt}", str(debt_per_status))


func _status_list() -> String:
	var names := PackedStringArray()
	for status in purgeable_statuses:
		if status:
			names.append(KeywordsScene.name_for_status(status.status_name))
	if names.size() <= 1:
		return "".join(names)
	return ", ".join(names.slice(0, names.size() - 1)) + " and " + names[names.size() - 1]
