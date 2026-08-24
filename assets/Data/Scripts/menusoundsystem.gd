extends Node
@onready var player: AudioStreamPlayer = get_tree().get_first_node_in_group("SFXBus")
@export var hoversfx: AudioStream
@export var clickSfx: AudioStream
@onready var parent = get_parent()

var disabled : bool = false

func _ready() -> void:
	for child in parent.get_children():
		if child is Button:
			child.mouse_entered.connect(_on_button_hover)
			child.pressed.connect(_on_button_click)
			child.focus_entered.connect(_on_button_focus)
func _on_button_hover():
	if not disabled:
		player.play_sfx(hoversfx)
		
func _on_button_click():
	if not disabled:
		player.play_sfx(clickSfx)
		
func _on_button_focus():
	if not disabled:
		player.play_sfx(hoversfx)
