class_name MenuFunctionality extends Node
@export var Menu : Container
@export var Selection: VBoxContainer

var disabled: bool = false

func _ready() -> void:
	_connect_signals()
	_ready_menu_selection()


func _connect_signals() -> void:
	for child in Menu.get_children():
		if child is Button:
			child.mouse_entered.connect(_menu_selection.bind(child, true))
			child.mouse_exited.connect(_menu_selection.bind(child, false))


func _menu_selection(button: Button, activate: bool) -> void:
	if not disabled:
		if button in Menu.get_children():
			var index := Menu.get_children().find(button)
			var selection_list:= Selection.get_children()
			var selector = selection_list[index] as NinePatchRect
			if selector and activate:
				selector.self_modulate = Color(1.0, 1.0, 1.0, 1.0)
			elif selector and not activate:
				selector.self_modulate = Color(0.0, 0.0, 0.0, 0.0)
	else:
		for child in Selection.get_children():
			child.self_modulate = Color(0,0,0,0)

func _ready_menu_selection() -> void:
	for child in Selection.get_children():
		if child is NinePatchRect:
			child.self_modulate = Color(0.0, 0.0, 0.0, 0.0)
