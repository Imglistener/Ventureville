class_name PauseMenu extends PanelContainer
@onready var resume: Button = $"Pause Buttons/Resume"
@onready var load: Button = $"Pause Buttons/Load"
@onready var settings: Button = $"Pause Buttons/Settings"
@onready var save_and_quit: Button = $"Pause Buttons/Save and Quit"
@onready var control_layer: CanvasLayer = $".."


@onready var settings_menu: SettingsMenu = $"../SettingsMenu"



func _ready() -> void:
	settings.pressed.connect(_show_settings_menu)

func _show_settings_menu() -> void:
		settings_menu.animate_in()
		
