extends BattlerStats
enum DC{BASIC, ELITE, BOSS, OVERLORD}
@export_group("Basic Variables")
@export var name: String
@export var Difficulty: DC
@export var Has_Phase_2: bool
