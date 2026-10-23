class_name AttackEffect extends CardEffect

const light_damage: AudioStream = preload("res://assets/SFX/77611__joelaudio__sfx_attack_sword_001.wav")
const medium_damage: AudioStream = preload("res://assets/SFX/547038__cogfirestudios__hit-swing-sword.wav")
const heavy_damage: AudioStream = preload("uid://dpv3gx2wsr4h3")

## Fraction of a Psychic hit that also lands on SAN.
const PSYCHIC_SAN_RATIO := 0.5

var amount = 0
var damage_type: DamageType
var source: BaseBattlerStats
## < 0 = use PSYCHIC_SAN_RATIO. Set by cards like Shriek (1.0).
var san_ratio_override := -1.0

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
		value = condition.modify_typed_damage(value, defender, damage_type)
	for effect in defender.ActiveEffects:
		if effect is SanguineShell:
			return effect.reduce_damage(value, source)
	return value

func _hit(defender: BaseBattlerStats) -> void:
	var final_amount := _mitigated(amount, defender)
	var before := defender.current_health
	defender.take_damage(final_amount, damage_type)
	_notify_damage_dealt(before - defender.current_health, defender)
	_apply_psychic_sanity(final_amount, defender)

## Psychic hits also damage SAN. Based on the value handed to take_damage
## (after conditions / Damage Up / Damage Down), BEFORE Shield and BEFORE
## Psychic resistance, so Shield and resistance never stop the mind half.
## SAN Shield does (it is handled inside take_san_damage).
func _apply_psychic_sanity(final_amount: int, defender: BaseBattlerStats) -> void:
	if final_amount <= 0 or defender.current_health <= 0:
		return
	if not damage_type or damage_type.Damage_Type != DamageType.DAMAGETYPE.Psychic:

		return
	var ratio := san_ratio_override if san_ratio_override >= 0.0 else PSYCHIC_SAN_RATIO
	if source:
		for condition in source.BattleConditions:
			ratio = condition.modify_psychic_san_ratio(ratio)
	var san := roundi(final_amount * ratio)
	if san > 0:
		defender.take_san_damage(san)

func _notify_damage_dealt(dealt: int, defender: BaseBattlerStats) -> void:
	if not source or dealt <= 0:
		return
	for condition in source.BattleConditions.duplicate():
		condition.on_damage_dealt(dealt, damage_type, source, defender)
