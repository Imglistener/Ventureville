class_name Toolbar extends MarginContainer
@onready var player_name: Label = $toolbar/MarginContainer/HBoxContainer/MarginContainer2/VBoxContainer/PlayerName
@onready var currency: Label = $toolbar/MarginContainer/HBoxContainer/MarginContainer2/VBoxContainer/Currency
@onready var help: ToolbarButton = $toolbar/MarginContainer/NavMenu/MarginContainer/PauseMenuIcons/Help
@onready var show_deck: ToolbarButton = $"toolbar/MarginContainer/NavMenu/MarginContainer/PauseMenuIcons/Show Deck"
@onready var pause: ToolbarButton = $toolbar/MarginContainer/NavMenu/MarginContainer/PauseMenuIcons/Pause
@onready var pause_menu_icons: HBoxContainer = $toolbar/MarginContainer/NavMenu/MarginContainer/PauseMenuIcons

enum Toolbar_Modes{Combat, NonCombat}
var toolbar_mode: Toolbar_Modes = Toolbar_Modes.Combat
func _ready() -> void:
	if toolbar_mode == Toolbar_Modes.NonCombat:
		show_deck.hide()
	for button in pause_menu_icons.get_children():
		if button is ToolbarButton:
			if not button.is_node_ready():
				await button.ready
			button.set_label_text(str(button.name))
