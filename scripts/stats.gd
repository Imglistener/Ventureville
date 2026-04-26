class_name BattlerStats extends BaseBattlerStats



func take_damage(damage : int, damage_type: DamageType = null) -> void:
	if damage <= 0:
		return
	var initial_damage = damage
	damage = clampi(damage - current_block, 0, damage)
	self.current_block = clampi(current_block - initial_damage, 0 , current_block)
	if damage_type:
		var resistance : int = damage_type.assocated_stat.stat_resistance_value
		var final_damage := clampi(damage - resistance, 0, damage)
		self.current_health -= final_damage
	else:
		self.current_health -= damage
	
