class_name data_display extends Label
@onready var enemy: Enemy = %Enemy
@onready var e_healthbar: Healthbar = %E_Heathbar




# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if not enemy.is_node_ready():
		await enemy.ready
	self.text = enemy.Enemy_name_phase1
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if not e_healthbar.is_node_ready():
		await e_healthbar.ready
	if e_healthbar.value_changed:
		if e_healthbar.value >= e_healthbar.max_value/2:
			self.text = enemy.Enemy_name_phase2
