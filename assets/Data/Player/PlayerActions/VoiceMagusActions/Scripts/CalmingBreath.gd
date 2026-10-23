extends BuffCard
## Heal SAN and draw. Any SAN heal also strips the player's Horrified (BaseBattlerStats.san_heal).

@export var san_heal_amount: int = 20
@export var draw_amount: int = 1


func _execute(player: Stat_Manager, targets: Array[Node]) -> void:
	player.Player.san_heal(san_heal_amount)
