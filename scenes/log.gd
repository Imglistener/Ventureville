class_name Log extends RichTextLabel
@onready var battle: Battle = $"../../../../../../../../.."

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	text = "Turn: " + str(battle.turn_counter)
	battle.turn_changed.connect(_on_turn_changed)

func _on_turn_changed()-> void:
	text = text + str("\nTurn:  ", battle.turn_counter)
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
