extends DefendCard

func _init() -> void:
	super()
	# These were script defaults before and weren't stored in the .tres.
	BaseShield = 12
	BaseSanShield = 12

func _execute(player: Stat_Manager, targets: Array[Node]) -> void:
	_pay_blood_tax(player)
	_play_vfx(player, decrease_cost)
	_gain_block(targets)

func decrease_cost() -> void:
	if mp_cost > 0:
		mp_cost -= 1
	if ap_cost > 0:
		ap_cost -= 1
	Events.card_cost_changed.emit(self)

func get_description(_character: CharacterInstance) -> String:
	return Description.replace("{Blood_Aias}", str(self.name))
