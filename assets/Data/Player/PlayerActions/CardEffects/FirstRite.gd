extends BuffCard
## Damage Up. If Ascendant Ritual is active: reset its count and get the stronger, longer version.
## Tag this card's .tres with &"FirstRite" (Third Rite looks for it).

@export var damage_up: DamageUP
@export_range(0.0, 1.0) var damage_up_percent: float = 0.2
@export var base_duration: int = 2
@export_range(0.0, 1.0) var empowered_percent: float = 0.3
@export var empowered_duration: int = 10


func _execute(player: Stat_Manager, _targets: Array[Node]) -> void:
	_pay_blood_tax(player)

	var percent := damage_up_percent
	var turns := base_duration

	var ritual := _find_condition(player, AscendantRitualCondition) as AscendantRitualCondition
	if ritual:
		ritual.reset_count()
		percent = empowered_percent
		turns = empowered_duration
		Events.effect_applied.emit()   # refresh the condition label

	# DamageUP.amount is a multiplier: 20% -> 1.2
	var effect := damage_up.duplicate() as DamageUP
	effect.amount = 1.0 + percent
	_apply_to_self(effect, player, turns)
