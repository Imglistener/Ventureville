class_name StandbyMenu extends NinePatchRect

@export var testdamage: DamageType
@onready var talk: Button = $Margin/ButtonContainer/Talk
@onready var escape: Button = $Margin/ButtonContainer/Escape
@onready var items: Button = $Margin/ButtonContainer/Items
@onready var battle: Button = $Margin/ButtonContainer/Battle
@onready var player_stat_manager: Stat_Manager = $"../../../../../Functionality/PlayerStatManager"
@onready var button_container: HBoxContainer = $Margin/ButtonContainer


@export_group('Button Descriptions')
@export var buttons_descriptions : Dictionary[StandbyMenuButton, String]

func _ready() -> void:
	if not player_stat_manager.is_node_ready():
		await player_stat_manager.ready
	for button in button_container.get_children():
		if button is StandbyMenuButton:
			if not button.is_node_ready():
				await button.ready
	assign_buttons_descriptions()

func assign_buttons_descriptions() -> void:
	for child in button_container.get_children():
		if child is StandbyMenuButton:
			var button : StandbyMenuButton = child
			var text = buttons_descriptions[button]
			button.set_label_text(text)
