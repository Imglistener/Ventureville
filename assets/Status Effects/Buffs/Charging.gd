class_name Charging extends StatusEffect
## Enemy-only. The owner is winding up a big move. The icon shows how much more
## damage is needed to interrupt it; reaching 0 removes Charging and applies Stunned.

@export var stun_threshold: int = 60

var _entity: BaseBattlerStats
var _target: Node
var _remaining: int = 0
# Applied during the enemy's own turn, so its first end-of-turn tick must not count.
var _skip_next_tick := true


func _init() -> void:
	status_name = StatusEffects.Charging
	default_duration = 1
	status_icon = preload("res://assets/GUI/Fire_tik_Icon.png")   # placeholder art
	effect_texture = status_icon
	status_description = "The Affected Entity is charging a powerful attack. Deal the displayed damage to Stun it."


func get_display_text() -> String:
	return str(_remaining)


func on_apply(targets: Array[Node], _duration: int = 1) -> void:
	for target in targets:
		if target is not EnemyView:   # never the player
			continue
		var entity := _get_entity(target)
		if not entity or find_same_effect(entity.ActiveEffects):
			continue
		var instance := self.duplicate() as Charging
		instance.current_duration = 1
		instance._start(entity, target)
		entity.ActiveEffects.append(instance)
		var anchor := _get_anchor(target)
		if anchor:
			Events.effect_display.emit(self, anchor, anchor.global_position)
	Events.effect_applied.emit()


func _start(entity: BaseBattlerStats, target: Node) -> void:
	_entity = entity
	_target = target
	_remaining = stun_threshold
	entity.damage_taken.connect(_on_damage_taken)


func _on_damage_taken(amount: int, _entity_name: String) -> void:
	if amount <= 0:
		return   # fully blocked hits don't count
	_remaining = maxi(_remaining - amount, 0)
	if _remaining > 0:
		Events.effect_applied.emit()   # refresh the icon number
		return
	_interrupt()


func _interrupt() -> void:
	var view := _target
	on_remove(_entity)
	var targets: Array[Node] = [view]
	Stunned.new().on_apply(targets, 1)


func on_tick(target: BaseBattlerStats) -> void:
	if _skip_next_tick:
		_skip_next_tick = false
		return
	current_duration -= 1
	if current_duration <= 0:
		on_remove(target)


func on_remove(target: BaseBattlerStats) -> void:
	if _entity and _entity.damage_taken.is_connected(_on_damage_taken):
		_entity.damage_taken.disconnect(_on_damage_taken)
	super(target)
