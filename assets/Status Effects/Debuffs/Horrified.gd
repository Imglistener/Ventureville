class_name Horrified extends StatusEffect
## Stacks live in current_duration and never decay. Only restoring SAN removes them
## (BaseBattlerStats.san_heal). At the end of the holder's turn it rolls once:
##   Stunned   min(5 + 4s, 30)%   (not twice in a row; halved on Boss/Overlord)
##   Concussed min(15 + 5s, 35)%
##   Shaken    35%  (Damage Down 5% x s, capped at 40%)
##   otherwise nothing
## Each effect lasts 1 turn, so it lands on the holder's NEXT turn.

const CONCUSSED_RES := preload("res://assets/Status Effects/Debuffs/Concussed.tres")
const DAMAGE_DOWN_RES := preload("res://assets/Status Effects/Debuffs/DamageDown.tres")

const STUN_BASE := 5.0
const STUN_PER_STACK := 4.0
const STUN_CAP := 30.0
const CONCUSS_BASE := 15.0
const CONCUSS_PER_STACK := 5.0
const CONCUSS_CAP := 35.0
const SHAKEN_CHANCE := 0.35
const SHAKEN_PER_STACK := 0.05
const SHAKEN_CAP := 0.40

var _target: Node               # EnemyView or Stat_Manager, needed by the other statuses' on_apply
var _stunned_last_roll := false


func _init() -> void:
	status_name = StatusEffects.Horrified
	default_duration = 1
	status_icon = preload("res://assets/GUI/horrified.png")   # placeholder art, same as Stunned
	effect_texture = status_icon
	status_description = "Each turn, a chance to be Stunned, Concussed or Shaken. Stacks never decay. Restoring SAN removes them."


func is_applicable(_targets: Array[Node]) -> bool:
	return true


func on_apply(targets: Array[Node], duration: int = 1) -> void:
	for target in targets:
		if not target:
			continue
		var entity := _get_entity(target)
		if not entity:
			continue
		var existing := find_same_effect(entity.ActiveEffects) as Horrified
		if existing:
			existing.current_duration += duration
		else:
			var instance := self.duplicate() as Horrified
			instance.current_duration = duration
			instance._target = target
			entity.ActiveEffects.append(instance)
		var anchor := _get_anchor(target)
		if anchor:
			Events.effect_display.emit(self, anchor, anchor.global_position)
		Events.status_applied.emit(self, entity)   # Fear Itself / Collective Dread listen to this
	Events.effect_applied.emit()


func on_tick(target: BaseBattlerStats) -> void:
	if current_duration <= 0:
		on_remove(target)
		return
	roll_effect(target)


## One roll of the effect table. Also used by Mass Hysteria.
func roll_effect(target: BaseBattlerStats) -> void:
	if not is_instance_valid(_target):
		return

	var s := float(current_duration)
	var stun := 0.0 if _stunned_last_roll else minf(STUN_BASE + STUN_PER_STACK * s, STUN_CAP) / 100.0
	if target is EnemyBattlerStats and target.Difficulty >= EnemyBattlerStats.DC.BOSS:
		stun *= 0.5
	var concuss := minf(CONCUSS_BASE + CONCUSS_PER_STACK * s, CONCUSS_CAP) / 100.0

	var roll := randf()
	_stunned_last_roll = false
	var targets: Array[Node] = [_target]

	if roll < stun:
		_stunned_last_roll = true
		Stunned.new().on_apply(targets, 1)
	elif roll < stun + concuss:
		(CONCUSSED_RES.duplicate() as Concussed).on_apply(targets, 1)
	elif roll < stun + concuss + SHAKEN_CHANCE:
		var shaken := DAMAGE_DOWN_RES.duplicate() as DamageDown
		shaken.amount = minf(SHAKEN_PER_STACK * s, SHAKEN_CAP)
		shaken.on_apply(targets, 1)
	# else: nothing this turn. Stacks stay.
