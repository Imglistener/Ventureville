class_name GameSaverLoader
extends Node

@onready var main_game_container: GameMenu = $"../MainGameContainer"
@onready var buttons_manager: MainMenuButtonsManager = $"../ButtonsManager"
@onready var menu: VBoxContainer = $"../MainGameContainer/Separator/Menu"
var buttons_to_tooltips : Dictionary

func _ready() -> void:
	main_game_container.grab_signals(1, [continue_game])
	buttons_to_tooltips = main_game_container.setup_buttons_and_tooltips()
	print(buttons_to_tooltips)
	buttons_to_tooltips.keys()[0].button_down.connect(_no_save_found_continue)
	buttons_to_tooltips.keys()[0].button_up.connect(_no_save_found_continue)

func continue_game() -> void:
	if load_save(0):
		print("Save Found, continuing...")
	else:
		print("No Save Found!")


func load_save(slot: int) -> SaveFile:
	var path = "user://save_%d.tres" % slot
	if not ResourceLoader.exists(path):
		return null
	return ResourceLoader.load(path) as SaveFile

func _no_save_found_continue() -> void:
	if not load_save(0):
		if buttons_to_tooltips[menu.get_child(0)].text !=  "No last save found!":
			buttons_to_tooltips[menu.get_child(0)].text = "No last save found!"
		else:
			buttons_to_tooltips[menu.get_child(0)].text = "Resume from where you left off."
	
