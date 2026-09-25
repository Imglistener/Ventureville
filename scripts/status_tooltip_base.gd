class_name StatusEffectTooltip extends Control

@export var displayed_status: StatusEffect

@onready var status_icon: TextureRect = $PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/Status_Icon
@onready var status_name: Label = $PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/Status_Name
@onready var status_description: RichTextLabel = $PanelContainer/MarginContainer/VBoxContainer/StatusDescription


func show_tooltip() -> void:
	if not displayed_status:
		return
	status_icon.texture = displayed_status.status_icon
	var status_name_text : String 
	match displayed_status.status_name:
		0:
			status_name_text = "Burning"
		1:
			status_name_text = "Frostbite"
		2:
			status_name_text = "Blood Syphon"
		3:
			status_name_text = "Horrified"
		4:
			status_name_text = "Concussed"
		5:
			status_name_text = "Stunned"
		6:
			status_name_text = "Withering"
		7:
			status_name_text = "Damage Up"
		8:
			status_name_text = "Regeneration"
		9:
			status_name_text = "Congealed Blood"
		10:
			status_name_text = "Retain"
		11:
			status_name_text = "Poison"
		_:
			status_name_text = "Unknown"
	status_name.text =  status_name_text
	status_description.text = displayed_status.status_description
