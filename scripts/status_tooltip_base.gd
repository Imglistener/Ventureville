class_name StatusEffectTooltip extends Control

@export var displayed_status: StatusEffect

@onready var status_icon: TextureRect = $PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/Status_Icon
@onready var status_name: Label = $PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/Status_Name
@onready var status_description: RichTextLabel = $PanelContainer/MarginContainer/VBoxContainer/StatusDescription


func show_tooltip() -> void:
	if not displayed_status:
		return
	status_icon.texture = displayed_status.status_icon
	status_name.text =  StatusEffect.StatusEffects.find_key(displayed_status.status_name) if not displayed_status.status_name == 2 else "Blood Syphon"
	status_description.text = displayed_status.status_description
