extends BuffCard
## Draw and gain Damage Up. DamageUP.amount is a multiplier: 25% -> 1.25.
## Played before a SAN burst, the SAN half scales with it too.

@export var draw_amount: int = 1


func _execute(player: Stat_Manager, targets: Array[Node]) -> void:
	_draw_cards(targets, draw_amount)
