class_name DeckEditor 
extends MarginContainer


var selected_card : CardUI

@export var player_stats : CharacterInstance
@onready var deck_editor_manager: DeckEditorManager = $DeckEditorManager

@onready var deck_editor_menu: DeckEditorMenu = $"../../../../.."
@onready var card_viewer_container: CardViewerContainer = $MainEditorContainer/CardViewerContainer
@onready var deck_editor_viewer: DeckEditorContainer = $MainEditorContainer/DeckEditorViewer
@onready var card_inventory_viewer: CardInventoryContainer = $MainEditorContainer/CardInventoryViewer

func _ready() -> void:
	if not deck_editor_menu.is_node_ready():
		await deck_editor_menu.ready
	card_inventory_viewer.functionality.character_stats = player_stats
	deck_editor_viewer.functionality.character_stats = player_stats
	card_viewer_container.functionality.player_stats = player_stats
	card_inventory_viewer.functionality.initialize_cards_view()
	deck_editor_viewer.functionality.initialize_deckview()
	deck_editor_manager.initialize_deck()

func set_selected_card(card: CardUI) -> void:
	selected_card = card
	card_viewer_container.functionality.set_card_displayed(selected_card)

func _on_empty_deck_pressed() -> void:
	Events.clear_deck_request.emit()
