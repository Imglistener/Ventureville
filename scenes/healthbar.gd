class_name Healthbar extends TextureProgressBar

@onready var source = %Enemy
@onready var health: Label = $Label
@onready var battle: Battle = $"../../../../../../.."

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if not source.is_node_ready():
		await source.ready
	self.max_value = source.Enemy_basestats["eHealth"]
	self.value = min_value
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	health.text = str(int(self.max_value - self.value))
	

	

func _on_item_pressed() -> void:
	battle.inflict_damage(self ,15, "Fire") # Replace with function body.
