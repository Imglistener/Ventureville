extends TextureProgressBar
@onready var battle: Battle = $"../../../../../../../.."
@onready var mana: Label = $Mana


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self.max_value = battle.magic_points
	battle.Enemy_Battlephase_Done.connect(_on_Enemy_battlephase_done)
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	mana.text = str(int(value), "/", int(max_value))

func _on_Enemy_battlephase_done() -> void:
	battle.mana_tick()
	max_value = battle.magic_points
	value = battle.magic_points
