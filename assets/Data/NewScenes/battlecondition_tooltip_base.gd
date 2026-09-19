class_name BattleConditionTooltip extends Control

@export var displayed_condition: Battle_Condition

@onready var status_icon: TextureRect = $PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/Status_Icon
@onready var status_name: Label = $PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/Status_Name
@onready var status_description: RichTextLabel = $PanelContainer/MarginContainer/VBoxContainer/StatusDescription

func show_tooltip() -> void:
	if not displayed_condition:
		return
	status_icon.texture = displayed_condition.condition_icon
	status_name.text = displayed_condition.condition_name
	status_description.text = displayed_condition.condition_description
