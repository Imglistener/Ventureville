class_name QuitConfirmation
extends ConfirmationMenuBase

func _ready() -> void:
	super._ready()
	default_message = "Do you really want to quit the game?"

func _handle_yes() -> void:
	get_tree().quit()
	super._handle_yes()
