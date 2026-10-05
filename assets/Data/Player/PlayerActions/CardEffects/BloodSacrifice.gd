extends BuffCard

@export var draw_amount: int = 3
@export var ap_gained: int = 2

func _execute(player: Stat_Manager, targets: Array[Node]) -> void:
	if not targets[0] is Stat_Manager:
		return
	player.Player.current_health = player.Player.current_health / 2
	_draw_cards(targets, draw_amount)
	_gain_ap(targets, ap_gained)
