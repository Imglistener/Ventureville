class_name MenuComponent extends Node

var index : int = 0

signal button_hover(button: BaseButton)
signal button_focus(button: BaseButton)
signal button_press(button: BaseButton)

@onready var parent_container = get_parent()

func _ready() -> void:
	# Wait for parent to be ready so children exist
	if not parent_container.is_node_ready():
		await parent_container.ready
	
	button_focus_manage(0)

	for button in get_buttons():
		# Using 'as' for cleaner type safety
		var btn = button as BaseButton
		if btn:
			btn.pressed.connect(_on_Button_press.bind(btn))
			btn.focus_entered.connect(_on_Button_focus.bind(btn))
			btn.mouse_entered.connect(_on_Button_hover.bind(btn))
	
	# Connect to parent's visibility to auto-focus
	parent_container.visibility_changed.connect(_on_parent_visibility_changed)

func get_buttons() -> Array:
	# Scans the HBoxContainer's children instead of its own
	return parent_container.get_children()

func button_focus_manage(n: int = index) -> void:
	var buttons = get_buttons()
	if n < buttons.size() and buttons[n] is Control:
		buttons[n].grab_focus()

func _on_Button_focus(button: BaseButton) -> void:
	button_focus.emit(button) # Modern Godot 4 signal syntax

func _on_Button_hover(button: BaseButton) -> void:
	button_hover.emit(button)

func _on_Button_press(button: BaseButton) -> void:
	button_press.emit(button)

func _on_parent_visibility_changed() -> void:
	if parent_container.is_visible_in_tree():
		button_focus_manage(0)
