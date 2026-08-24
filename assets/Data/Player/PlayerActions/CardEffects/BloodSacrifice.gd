extends Card

func apply_effect(targets : Array[Node]) -> void:
	if not targets[0] is Stat_Manager:
		return
	var Player = targets[0].Player as CharacterInstance
	Player.current_health = Player.current_health/2
	var draw = DrawEffect.new()
	draw.amount = 3
	draw.activate(targets)
	var gain = GainAPEffect.new()
	gain.amount = 2
	gain.activate(targets)
	
	
