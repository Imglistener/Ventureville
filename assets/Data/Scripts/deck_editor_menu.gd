class_name DeckEditorMenu
extends Control

@onready var deck_editor_container: MarginContainer = $MainMargin/TopVboxContainer/BackgroundTexture/MarginContainer/DeckEditorContainer
@export var character_data : CharacterInstance

func _ready() -> void:
	deck_editor_container.player_stats = character_data
