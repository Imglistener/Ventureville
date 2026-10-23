extends VoiceAttackCard
## Cheap Psychic hit. If the target is Horrified, gain 1 AP, once per turn.
## Card data needs the tag &"Heckle" (that is how 'once per turn' is counted).

const TAG_FIRST_MOVEMENT_SOLO := &"FirstMovementSolo"


@export var ap_refund: int = 1


func _execute(player: Stat_Manager, targets: Array[Node]) -> void:
	if not targets[0] is EnemyView:
		return
	var entity := _entity_of(targets[0])
	var was_horrified := entity != null and entity.get_status(Horrified) != null
	_deal_damage(targets, _calculate_total(player.Player))
	if was_horrified and _first_heckle_this_turn(player):
		player.Player.AP += ap_refund


# card_played fires before _execute, so this card is already counted.
func _first_heckle_this_turn(player: Stat_Manager) -> bool:
	var tracker := _get_turn_tracker(player)
	return tracker == null or tracker.count_tag_played_this_turn(TAG_FIRST_MOVEMENT_SOLO) <= 1
