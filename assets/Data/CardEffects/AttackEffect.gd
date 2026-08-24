class_name AttackEffect extends CardEffect

var light_damage: AudioStream = load("res://assets/SFX/77611__joelaudio__sfx_attack_sword_001.wav")
var medium_damage: AudioStream = load("res://assets/SFX/547038__cogfirestudios__hit-swing-sword.wav")
var heavy_damage: AudioStream = load("uid://dpv3gx2wsr4h3")
 
var amount = 0
var damage_type: DamageType

func activate(targets : Array[Node]) -> void:
	var sfx_player = targets[0].get_tree().get_first_node_in_group('SFXBus') as AudioStreamPlayer
	var player = targets[0].get_tree().get_first_node_in_group('player').Player as CharacterInstance
	if player:
		for target in targets:
			if not target:
				continue
			if target is EnemyView:
				target.Enemy.Entity.take_damage(amount, damage_type)
			elif target is Stat_Manager:
				target.Player.take_damage(amount, damage_type)
		if amount > 0 and amount <= 10:
			sfx_player.play_sfx(light_damage)

		elif amount > 10 and amount <= 25:
			sfx_player.play_sfx(medium_damage)
		else:
			sfx_player.play_sfx(heavy_damage)
			
