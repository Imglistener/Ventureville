extends BuffCard
## Adds a copy of the last Mimic card you played this battle to your hand.

func _execute(player: Stat_Manager, targets: Array[Node]) -> void:
	var recorder := player.get_tree().get_first_node_in_group("MimicRecorder") as MimicRecorder
	if not recorder or not recorder.last_mimic_card:
		return
	MimicCard.put_on_top(recorder.last_mimic_card.clone(), player.Player)
	_draw_cards(targets, 1)


func get_live_description(_character: CharacterInstance, live_targets: Array[Node]) -> String:
	if live_targets.is_empty() or not live_targets[0]:
		return Description
	var recorder := live_targets[0].get_tree().get_first_node_in_group("MimicRecorder") as MimicRecorder
	if recorder and recorder.last_mimic_card:
		return Description + "\n(Copy: %s)" % recorder.last_mimic_card.name
	return Description + "\n(No Mimic card played yet)"
