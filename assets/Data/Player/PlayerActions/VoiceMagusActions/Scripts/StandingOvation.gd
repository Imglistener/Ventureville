extends BuffCard
## Heal HP and SAN. The SAN heal also removes your Horrified.

@export var heal_amount: int = 15
@export var san_heal_amount: int = 15


func _execute(player: Stat_Manager, _targets: Array[Node]) -> void:
	player.Player.heal(heal_amount)
	player.Player.san_heal(san_heal_amount)
