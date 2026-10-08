class_name StatusEffectTooltip extends Control

@export var displayed_status: StatusEffect

@onready var status_icon: TextureRect = $PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/Status_Icon
@onready var status_name: Label = $PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/Status_Name
@onready var status_description: RichTextLabel = $PanelContainer/MarginContainer/VBoxContainer/StatusDescription


func show_tooltip() -> void:
	if not displayed_status:
		return
	status_icon.texture = displayed_status.status_icon
	status_name.text =  KeywordsScene.name_for_status(displayed_status.status_name)
	status_name.add_theme_color_override('font_color', KeywordsScene.color_of(status_name.text))
	status_description.text = KeywordsScene.description_for_status(displayed_status.status_name)
