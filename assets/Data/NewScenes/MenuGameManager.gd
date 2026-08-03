class_name GameSaverLoader
extends Node

@onready var main_game_container: GameMenu = $"../MainGameContainer"
@onready var buttons_manager: MainMenuButtonsManager = $"../ButtonsManager"

func _ready() -> void:
	main_game_container.grab_signals(1, [continue_game])


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
