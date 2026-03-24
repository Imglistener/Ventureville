extends Node
@onready var hover: AudioStreamPlayer2D = %Hover
@onready var click: AudioStreamPlayer2D = %Click



@onready var parent = get_parent()


func _ready() -> void:
	for child in parent.get_children():
		if child is Button:
			child.mouse_entered.connect(_on_button_hover)
			child.pressed.connect(_on_button_click)
			child.focus_entered.connect(_on_button_focus)
func _on_button_hover():
	hover.play()
	
func _on_button_click():
	click.play()
	
func _on_button_focus():
	hover.play()
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
