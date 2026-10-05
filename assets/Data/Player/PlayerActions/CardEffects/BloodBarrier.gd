extends DefendCard

@export var retain_effect: RetainHand

func _init() -> void:
	super()
	BaseShield = 8   # script default before; not stored in the .tres

func _execute(player: Stat_Manager, targets: Array[Node]) -> void:
	_apply_to_self(retain_effect, player, 1)
	_play_vfx(player)
	_gain_block(targets)
