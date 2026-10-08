class_name KeywordTooltip
extends Control

@onready var keyword_description: RichTextLabel = $PanelContainer/MarginContainer/VBoxContainer/KeywordDescription
@onready var keyword_name: Label = $PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/KeywordName




func show_tooltip(keyword: KeywordData) -> void:
		keyword_name.text = keyword.display_name
		keyword_name.add_theme_color_override('font_color', keyword.color)
		keyword_description.text = keyword.description 
