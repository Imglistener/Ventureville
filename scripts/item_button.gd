class_name item_button extends Button
@export var item_displayed: Item

signal is_highlighted(item_displayed: Item)


func _ready() -> void:
	text = item_displayed.item_name
	icon = item_displayed.item_icon
	
	if not mouse_entered.is_connected(highlighed):
		mouse_entered.connect(highlighed)

func highlighed() -> void:
	is_highlighted.emit(item_displayed)
