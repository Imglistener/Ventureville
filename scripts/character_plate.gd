class_name CharacterPlate extends PanelContainer

@export_category('class_data')
@export var loadout : Loadout
@onready var name_label: Label = $MarginContainer/VBoxContainer/PanelContainer/MarginContainer/Label
@onready var stat_values: VBoxContainer = $MarginContainer/VBoxContainer/MarginContainer/VBoxContainer/StatsContainer/HBoxContainer/StatValues
@onready var portrait: TextureRect = $MarginContainer/Portrait

func _ready() -> void:
	initialize_plate()

func initialize_plate() -> void:
	var container_array = stat_values.get_children()
	var stat_array = loadout.setup_loadout()
	for i in stat_array.size():
		container_array[i].get_child(0).text = str(stat_array[i].stat_level)
	portrait.texture = loadout.character_portrait
	name_label.text = loadout.loadout_name
