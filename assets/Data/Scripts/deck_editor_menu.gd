class_name DeckEditorMenu
extends Control

@onready var deck_editor_container: MarginContainer = $MainMargin/TopVboxContainer/BackgroundTexture/MarginContainer/DeckEditorContainer
@export var character_data : CharacterInstance
@export var confirmation_menu_scene : PackedScene
func _ready() -> void:
	deck_editor_container.player_stats = character_data

func _show_confirmation_menu() -> void:
	var conmenu = confirmation_menu_scene.instantiate() as ConfirmationMenuBase
	add_child(conmenu)
	if not conmenu.is_node_ready():
		await conmenu.ready
	conmenu.global_position += Vector2(0, 500)
	conmenu.open_confirmation("Clear your entire deck? \nAll cards return to your collection.", func(): Events.clear_deck_request.emit());

func _on_confirm_pressed() -> void:
	Events.save_deck_request.emit()
