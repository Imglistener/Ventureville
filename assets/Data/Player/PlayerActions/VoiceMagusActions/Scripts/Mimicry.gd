extends BuffCard
## Signature card. Turns the last enemy action into a playable card and draws it.
## With no recorded action (turn 1) it creates Rehearsed Line: a 1 AP / 1 MP Psychic hit, base 4.
## Not nullable, so Mimicry itself cycles.

const PSYCHIC_RES := preload("res://assets/Enemies/Data/Damage Types/Psychic.tres")

@export_range(0.1, 1.0) var base_strength: float = 0.75
@export_range(0.1, 1.0) var perfect_strength: float = 1.0
@export var fallback_base_damage: int = 4


func _execute(player: Stat_Manager, targets: Array[Node]) -> void:
	var recorder := player.get_tree().get_first_node_in_group("MimicRecorder") as MimicRecorder
	if not recorder:
		return
	var perfect := recorder.perfect_pitch_ready
	recorder.perfect_pitch_ready = false

	var card: MimicCard
	if recorder.last_profile:
		var strength := perfect_strength if perfect else base_strength
		card = MimicCard.create(recorder.last_profile, strength, player.Player, 1 if perfect else 0)
	else:
		card = MimicCard.create(_rehearsed_line(player.Player), 1.0, player.Player, 0, 0, Vector2i(1, 1))

	MimicCard.put_on_top(card, player.Player)
	_draw_cards(targets, 1)


func _rehearsed_line(character: CharacterInstance) -> MimicProfile:
	var bonus := 0
	for s in character.stats:
		if s.stat_name == StatInstance.STATS.INFLUENCE:
			bonus = s.stat_scaling_value
	var p := MimicProfile.new()
	p.source_name = "Rehearsed Line"
	p.is_fallback = true
	p.damage = int((fallback_base_damage + bonus) * character.get_attack_bonus())
	p.damage_type = PSYCHIC_RES
	return p


func get_live_description(_character: CharacterInstance, live_targets: Array[Node]) -> String:
	if live_targets.is_empty() or not live_targets[0]:
		return Description
	var recorder := live_targets[0].get_tree().get_first_node_in_group("MimicRecorder") as MimicRecorder
	if recorder and recorder.last_profile:
		return Description + "\n(Copy: %s)" % recorder.last_profile.source_name
	return Description + "\n(Nothing to copy yet: Rehearsed Line)"
