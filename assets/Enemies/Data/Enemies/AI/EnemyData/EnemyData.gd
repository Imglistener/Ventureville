class_name EnemyData extends Resource

@export_category("Action Data")
@export var ActionName: String
@export var ActionType: EnemyAction.ActionTypes
@export var ActionEffect: EnemyAction.ActionEffects
@export var SoundEffect: AudioStream
@export_range(0.0, 10.0) var ActionChance: float

@export_category("Attack Action")
@export var Damage: int = 0
@export var DamageElement: DamageType = null

@export_category("Block Action")
@export var BlockGained: int = 0

@export_category("SanAttack Action")
@export var SanDamage : int = 0

@export_category("Transition")
@export var PhaseDataArray : Array[PhaseData]

@export_multiline var Description : String
