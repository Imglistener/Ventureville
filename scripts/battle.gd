class_name Battle extends Control

@onready var _battleMenu :  = $MarginMain/VBoxContainer/Interface/NinePatchRect/ActionsMenu/Buttonhandlesystem
@onready var _ActionsMenu = $MarginMain/VBoxContainer/Interface/NinePatchRect/ActionsMenu/Buttonhandlesystem
func _ready() -> void:
	_ActionsMenu.button_focus_manage(0)


		


func _on_actions_menu_visibility_changed() -> void:
	if not is_node_ready():
		return
	_ActionsMenu.button_focus_manage(0)
