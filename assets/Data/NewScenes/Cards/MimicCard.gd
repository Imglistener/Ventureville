class_name MimicCard extends Card
## A runtime card built from a MimicProfile. Nullable, so it vanishes after use.
## Battle_Deck is rebuilt every battle, so the collection is never touched.

const PSYCHIC_ATTRIBUTE := 2   # Card.CardAttribute.Phonomancy

var profile: MimicProfile
var power_scale := 0.75
var _damage := 0
var _hits := 1
var _block := 0
var _san := 0
var _status: StatusEffect
var _stacks := 0


## fixed_cost = Vector2i(ap, mp) overrides the formula (Rehearsed Line is 1/1).
static func create(p: MimicProfile, scale: float, character: BaseBattlerStats,
		mp_discount: int = 0, ap_discount: int = 0, fixed_cost := Vector2i(-1, -1)) -> MimicCard:
	var c := MimicCard.new()
	c.profile = p
	c.power_scale = scale
	c._damage = _scaled(p.damage, scale)
	c._hits = maxi(p.hits, 1)
	c._block = _scaled(p.block, scale)
	c._san = _scaled(p.san_damage, scale)
	c._status = p.status
	c._stacks = _scaled(p.status_stacks, scale)
	for condition in character.BattleConditions:
		if condition is MethodActingCondition:
			ap_discount += condition.ap_reduction
	c._setup(mp_discount, ap_discount, fixed_cost)
	return c


static func _scaled(value: int, scale: float) -> int:
	if value <= 0:
		return 0
	return maxi(roundi(value * scale), 1)


## Cards are Resources, and Resource.duplicate() only copies exported vars, so copy by hand.
func clone() -> MimicCard:
	var c := MimicCard.new()
	c.profile = profile
	c.power_scale = power_scale
	c._damage = _damage
	c._hits = _hits
	c._block = _block
	c._san = _san
	c._status = _status
	c._stacks = _stacks
	c.name = name
	c.type = type
	c.target = target
	c.rarity = rarity
	c.attribute = attribute
	c.mp_cost = mp_cost
	c.ap_cost = ap_cost
	c.is_card_nullable = true
	c.tags = tags.duplicate()
	c.Description = Description
	c.LogMessage = LogMessage
	return c


func _setup(mp_discount: int, ap_discount: int, fixed_cost: Vector2i) -> void:
	name = profile.source_name if profile.is_fallback else "Mimic: " + profile.source_name
	rarity = Rarities.Rare
	attribute = PSYCHIC_ATTRIBUTE as CardAttribute
	is_card_nullable = true
	tags = [&"Mimic"]
	LogMessage = "\"You echo the enemy's own move back at them!\""

	if _damage > 0:
		type = Type.ATTACK
	elif _block > 0 and _san == 0 and _stacks == 0:
		type = Type.DEFEND
	else:
		type = Type.DEBUFF
	target = Target.SELF if type == Type.DEFEND else Target.ONEENEMY

	# power = damage + block + SAN + 2 x status stacks. MP = clamp(ceil(power / 10), 1, 6).
	var power := _damage * _hits + _block + _san + 2 * _stacks
	var mp := clampi(ceili(power / 10.0), 1, 6)
	var ap := 2 if _hits > 1 else 1
	if fixed_cost.x >= 0:
		ap = fixed_cost.x
		mp = fixed_cost.y
	ap_cost = maxi(ap - ap_discount, 0)
	mp_cost = maxi(mp - mp_discount, 0)
	Description = _build_description()


func _build_description() -> String:
	var lines: PackedStringArray = []
	if _damage > 0:
		var type_name := "Physical"
		if profile.damage_type:
			type_name = str(DamageType.DAMAGETYPE.find_key(profile.damage_type.Damage_Type))
		var hit_text := "" if _hits <= 1 else " %d times" % _hits
		lines.append("Deal %d %s Damage%s." % [_damage, type_name, hit_text])
	if _san > 0:
		lines.append("Deal %d SAN Damage." % _san)
	if _block > 0:
		lines.append("Gain %d Shield." % _block)
	if _status and _stacks > 0:
		var suffix := " if damage gets through" if profile.status_needs_damage else ""
		lines.append("Apply %d %s%s." % [_stacks, KeywordsScene.name_for_status(_status.status_name), suffix])
	lines.append("Null this card.")
	return "\n".join(lines)


func _execute(player: Stat_Manager, targets: Array[Node]) -> void:
	var tree := player.get_tree()
	var sfx := tree.get_first_node_in_group("SFXBus") as AudioStreamPlayer
	if profile.sound and sfx:
		sfx.play_sfx(profile.sound)

	if _block > 0:
		var self_target: Array[Node] = [player]
		var block := BlockEffect.new()
		block.amount = _block
		block.activate(self_target)

	var enemies: Array[Node] = []
	for t in targets:
		if t is EnemyView:
			enemies.append(t)
	if enemies.is_empty():
		return
	var entity := _entity_of(enemies[0])
	var hp_before := entity.current_health if entity else 0

	for i in _hits:
		if i > 0:
			await tree.create_timer(0.15).timeout
		if entity and entity.current_health <= 0:
			break
		var hit := AttackEffect.new()
		hit.damage_type = profile.damage_type
		hit.amount = _damage
		hit.source = player.Player
		hit.activate(enemies)

	if _san > 0:
		var san_hit := SanAttackEffect.new()
		san_hit.amount = _san
		san_hit.activate(enemies)

	if _status and _stacks > 0:
		var got_through := entity != null and entity.current_health < hp_before
		if not profile.status_needs_damage or got_through:
			_status.on_apply(enemies, _stacks)


## Pushes the card on top of the draw pile; the caller then draws it (same trick as Blood Omen).
static func put_on_top(card: MimicCard, character: CharacterInstance) -> void:
	var deck := character.starting_deck
	deck.Battle_Deck.push_front(card)
	deck.DeckSize_Changed.emit(deck.Battle_Deck.size())
