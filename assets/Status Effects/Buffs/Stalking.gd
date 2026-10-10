class_name StalkingEffect extends StatusEffect
## Applied to an enemy by its Stalk action.
## While active, every time the owner takes damage it banks a damage buff
## for its next attack. When that attack completes, the buff and the
## status are removed.

@export var buff_amount: float = 0.2
## false = the buff is granted once, no matter how many hits land.
## true  = each hit adds another buff_amount (BaseBattlerStats clamps the total at +50%).
@export var stacking: bool = false

var _entity: BaseBattlerStats
var _bonus_added: float = 0.0


func _init() -> void:
	status_name = StatusEffects.Stalking
	default_duration = 1
	status_icon = preload("res://assets/GUI/Attack_UP_icon.png")
	effect_texture = preload("res://assets/GUI/Attack_UP_icon.png")
	status_description = "Whenever the Affected Entity takes damage, its next Attack deals 20% more damage."


func on_apply(targets: Array[Node], duration: int = 1) -> void:
	for target in targets:
		if not target:
			continue
		var entity := _get_entity(target)
		if not entity:
			continue
		var existing := find_same_effect(entity.ActiveEffects) as StalkingEffect
		if existing:
			continue   # already stalking
		var instance := self.duplicate() as StalkingEffect
		instance.current_duration = maxi(duration, 1)
		instance._start(entity)
		entity.ActiveEffects.append(instance)
		var anchor := _get_anchor(target)
		if anchor:
			Events.effect_display.emit(self, anchor, anchor.global_position)
	Events.effect_applied.emit()


func _start(entity: BaseBattlerStats) -> void:
	_entity = entity
	entity.damage_taken.connect(_on_damage_taken)
	Events.EnemyActionCompleted.connect(_on_enemy_action_completed)


func _stop() -> void:
	if _entity and _entity.damage_taken.is_connected(_on_damage_taken):
		_entity.damage_taken.disconnect(_on_damage_taken)
	if Events.EnemyActionCompleted.is_connected(_on_enemy_action_completed):
		Events.EnemyActionCompleted.disconnect(_on_enemy_action_completed)


func _on_damage_taken(amount: int, _entity_name: String) -> void:
	if amount <= 0:
		return   # fully blocked hits don't count
	if _bonus_added > 0.0 and not stacking:
		return
	_bonus_added += buff_amount
	_entity.modify_buff_modifier(_entity.buff_damage_modifier + buff_amount)


func _on_enemy_action_completed(action: EnemyAction) -> void:
	if not _entity or not action or action.ActionEffect != EnemyAction.ActionEffects.Attack:
		return
	if not action.Enemy or action.Enemy.Enemy.Entity != _entity:
		return
	# The attack has already read get_attack_bonus() in use_action(), so it's safe to clear now.
	on_remove(_entity)


# Stalking ends on the next attack, not on a turn timer.
func on_tick(_target: BaseBattlerStats) -> void:
	pass


func on_remove(target: BaseBattlerStats) -> void:
	_stop()
	if _bonus_added > 0.0:
		target.modify_buff_modifier(target.buff_damage_modifier - _bonus_added)
		_bonus_added = 0.0
	super(target)
