extends Node
@onready var player: AudioStreamPlayer = $"../../../MenuSFXPlayer"
@export var hoversfx: AudioStream
@export var clickSfx: AudioStream


@onready var parent = get_parent()


func _ready() -> void:
	for child in parent.get_children():
		if child is Button:
			child.mouse_entered.connect(_on_button_hover)
			child.pressed.connect(_on_button_click)
			child.focus_entered.connect(_on_button_focus)
func _on_button_hover():
	player.stream = hoversfx
	player.play()
	
func _on_button_click():
	player.stream = clickSfx
	player.play()
	
func _on_button_focus():
	player.stream = hoversfx
	player.play()
	
