class_name BuffCard extends Card


func _init() -> void:
	type = Type.BUFF


## Attaches a BattleCondition (e.g. Ascendant Ritual) to the player.
func _activate_condition(condition: BattleCondition, targets: Array[Node]) -> void:
	if condition:
		condition.activate(targets)

func _draw_cards(targets: Array[Node], amount: int) -> void:
	var effect := DrawEffect.new()
	effect.amount = amount
	effect.activate(targets)

func _gain_ap(targets: Array[Node], amount: int) -> void:
	var effect := GainAPEffect.new()
	effect.amount = amount
	effect.activate(targets)

func _gain_mp(targets: Array[Node], amount: int) -> void:
	var effect := GainMPEffect.new()
	effect.amount = amount
	effect.activate(targets)
