class_name KeywordTooltip
extends Control

@onready var keyword_description: RichTextLabel = $PanelContainer/MarginContainer/VBoxContainer/KeywordDescription
@onready var keyword_name: Label = $PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/KeywordName

const KeywordList : Dictionary = {
	"Sacrifice" : Color(0.961, 0.638, 0.083, 1.0),
	"Regeneration": Color(0.166, 0.965, 0.0, 1.0),
	"Blood Syphon": Color(0.598, 0.0, 0.0, 1.0),
	"Congealed Blood" : Color(1.0, 0.477, 0.477, 1.0),
	"Retain" : Color.GOLD
	}

const KeywordDescriptions : Dictionary = {
	"Sacrifice" : "Lose health equal to the amount Sacrificed. Unblockable.",
	"Regeneration": "Affected Entity Heals twice the remaining Duration each Standby.",
	"Blood Syphon": "Affected Entity Takes Double the remaining Duration as Blood Damage if they are not Blocking.",
	"Congealed Blood" : "Gain Block equal to the Duration at the end of your turn.",
	"Retain" : "You do not discard your hand at the end of the turn."
}


func show_tooltip(keyword: String) -> void:
	if keyword in KeywordList.keys():
		keyword_name.text = keyword
		keyword_name.add_theme_color_override('font_color', KeywordList[keyword])
		keyword_description.text = KeywordDescriptions[keyword]
