class_name stalk extends Buff

var is_Stalking : bool = false

signal Stalking(Duration)

func apply_stalking() -> void:
	if is_Stalking:
		pass
	emit_signal("Stalking", Duration)
