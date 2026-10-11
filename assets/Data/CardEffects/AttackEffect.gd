class_name AttackEffect extends CardEffect

var light_damage: AudioStream = load("res://assets/SFX/77611__joelaudio__sfx_attack_sword_001.wav")
var medium_damage: AudioStream = load("res://assets/SFX/547038__cogfirestudios__hit-swing-sword.wav")
var heavy_damage: AudioStream = load("uid://dpv3gx2wsr4h3")
 
var amount = 0
var damage_type: DamageType
var source: BaseBattlerStats

func activate(targets : Array[Node]) -> void:
	var sfx_player = targets[0].get_tree().get_first_node_in_group('SFXBus') as AudioStreamPlayer
	var player = targets[0].get_tree().get_first_node_in_group('player').Player as CharacterInstance
	if player:
		for target in targets:
			if not target:
				continue
			if target is EnemyView:
				_hit(target.Enemy.Entity)
			elif target is Stat_Manager:
				_hit(target.Player)

		if amount > 0 and amount <= 10:
			sfx_player.play_sfx(light_damage)

		elif amount > 10 and amount <= 25:
			sfx_player.play_sfx(medium_damage)
		else:
			sfx_player.play_sfx(heavy_damage)
			
func _mitigated(base: int, defender: BaseBattlerStats) -> int:
	if not source or not defender:
		return base
	var value := base
	for condition in source.BattleConditions:
		value = condition.modify_outgoing_damage(value, defender)
	for effect in defender.ActiveEffects:
		if effect is SanguineShell:
			return effect.reduce_damage(value, source)
	return value

func _hit(defender: BaseBattlerStats) -> void:
	var before := defender.current_health
	defender.take_damage(_mitigated(amount, defender), damage_type)
	_notify_damage_dealt(before - defender.current_health, defender)

func _notify_damage_dealt(dealt: int, defender: BaseBattlerStats) -> void:
	if not source or dealt <= 0:
		return
	for condition in source.BattleConditions.duplicate():
		condition.on_damage_dealt(dealt, damage_type, source, defender)
