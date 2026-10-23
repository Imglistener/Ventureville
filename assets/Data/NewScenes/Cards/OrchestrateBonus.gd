class_name OrchestrateBonus extends Resource
## The extra effect a card gains when its Orchestrate condition is met.
## Leave a field at 0 / null to skip it. Everything here is applied AFTER the card's normal effect,
## except damage_multiplier, which scales the card's own damage.
## Cards with something more specific can read `orchestrated` in their own _execute().

@export_group("Damage")
## Attacks: multiplies the damage of every hit this card deals (1.0 = no change).
@export var damage_multiplier: float = 1.0

@export_group("Resources")
@export var draw: int = 0
@export var ap: int = 0
@export var mp: int = 0

@export_group("Defense and Sustain")
@export var shield: int = 0
@export var san_shield: int = 0
@export var heal_hp: int = 0
@export var heal_san: int = 0

@export_group("Status")
## Applied to the card's enemy targets, or to you if status_on_self is on.
## e.g. Horrified.tres, Concussed.tres, DamageUp.tres
@export var status: StatusEffect
@export var status_stacks: int = 1
@export var status_on_self: bool = false
