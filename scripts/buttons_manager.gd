class_name MainMenuButtonsManager extends Node

@onready var settings_menu: SettingsMenu = $"../SeparatorLayer/SettingsMenu"
@onready var menu_buttons: VBoxContainer = $"../MainContainer/MenuMargin/MenuButtons"
@onready var confirmation_menu: PanelContainer = $"../SeparatorLayer/ConfirmationMenu"
@onready var separator: ColorRect = $"../SeparatorLayer/Pause Blur"
@onready var menu_functionality: MenuFunctionality = $"../MainContainer/MenuMargin/MenuButtons/MenuFunctionality"
@onready var menu_backgrounds: VBoxContainer = $"../MainContainer/MenuMargin/MenuBackgrounds"
@onready var main_game_container: GameMenu = $"../MainGameContainer"


func _ready() -> void:
	_connect_signals()

func _connect_signals() -> void:
	var btn_list := menu_buttons.get_children()
	for btn in btn_list:
		if btn is Button:
			match btn.name:
				"StartGame":
					btn.pressed.connect(_advance_menu_tree)
				"Options":
					btn.pressed.connect(_show_options_menu)
				"ExitGame":
					btn.pressed.connect(_show_confirmation_menu)

	settings_menu.animated_out.connect(toggle_separator)
	var messgae_box = confirmation_menu.get_child(1) as Messagebox
	messgae_box.animated_out.connect(toggle_separator)
	var back_btn : Button = main_game_container.menu.get_child(3)
	back_btn.pressed.connect(_retract_menu_tree)

func _advance_menu_tree() -> void:
	menu_buttons.slide_out()
	await menu_buttons.btns_exited
	menu_buttons.hide()
	menu_backgrounds.hide()
	main_game_container.show()
	main_game_container.menu.slide_in()
	for btn in main_game_container.menu.get_children():
		if btn is Button:
			btn.disabled = false

func _retract_menu_tree() -> void:
	main_game_container.menu.slide_out()
	await main_game_container.menu.btns_exited
	main_game_container.hide()
	menu_buttons.show()
	menu_backgrounds.show()
	menu_buttons.slide_in()
	for btn in menu_buttons.get_children():
		if btn is Button:
			btn.disabled = false

func _show_options_menu() -> void:
	toggle_separator()
	settings_menu.animate_in()

func _show_confirmation_menu() -> void:
	toggle_separator()
	confirmation_menu.visible = true
	var message_box = confirmation_menu.get_child(1) as Messagebox
	message_box.animate_in()

func toggle_separator() -> void:
	handle_blur(false if separator.mouse_filter == Control.MouseFilter.MOUSE_FILTER_IGNORE else true)

func handle_blur(paused: bool) -> void:
	separator.modulate = Color(1.0, 1.0, 1.0, 0.0) if paused else Color(1.0, 1.0, 1.0, 1.0)
	var t = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
	t.tween_property(separator.material, "shader_parameter/blur_amount", 0.0 if paused else 2.0, 0.2)
	separator.mouse_filter = Control.MOUSE_FILTER_IGNORE if paused else Control.MOUSE_FILTER_STOP
	await t.finished
