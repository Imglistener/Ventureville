extends BuffCard

@export var mp_gained: int

func _execute(_player: Stat_Manager, targets: Array[Node]) -> void:
	var gain_mp := GainMPEffect.new()
	gain_mp.amount = mp_gained 
	gain_mp.activate(targets)
