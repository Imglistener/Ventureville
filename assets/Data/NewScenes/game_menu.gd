class_name GameMenu extends MarginContainer
@onready var menu: VBoxContainer = $Separator/Menu
@onready var tooltip: VBoxContainer = $Separator/Tooltip

func grab_signals(number: int, callables: Array[Callable]) -> void:
	var menu_buttons = menu.get_children()
	if number <= 0: return
	if callables.size() < number: return
	for i in range(number):
		if not menu_buttons[i] is Button:
			continue
		var button = menu_buttons[i] as Button
		if not button.pressed.is_connected(callables[i]):
			button.pressed.connect(callables[i])

func setup_buttons_and_tooltips() -> Dictionary:
	var buttons_to_tooltips := {}
	for i in menu.get_children().size():
		if menu.get_children()[i] is Button:
			buttons_to_tooltips[menu.get_children()[i]] = tooltip.get_children()[i]
	return buttons_to_tooltips
