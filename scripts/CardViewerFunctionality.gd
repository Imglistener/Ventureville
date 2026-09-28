class_name CardViewerEditor
extends Node

@export var card_displayed : Card
@export var player_stats : CharacterInstance

@onready var card_title_label: Label = $"../MainVBox/CardViewerBackground/MarginContainer/VBoxContainer/CardTitleContainer/CardTitleBackground/CardTitleInnerContainer/HBoxContainer/CardTitleLabel"
@onready var card_attribute_label: Label = $"../MainVBox/CardViewerBackground/MarginContainer/VBoxContainer/CardTitleContainer/CardTitleBackground/CardTitleInnerContainer/HBoxContainer/HBoxContainer/CardAttributeLabel"
@onready var attribute_icon: TextureRect = $"../MainVBox/CardViewerBackground/MarginContainer/VBoxContainer/CardTitleContainer/CardTitleBackground/CardTitleInnerContainer/HBoxContainer/HBoxContainer/AttributeIcon"
@onready var card_place_holder: TextureRect = $"../MainVBox/CardViewerBackground/MarginContainer/VBoxContainer/CardViewContainer/CardPlaceHolder"
@onready var ap_cost_label: Label = $"../MainVBox/CardViewerBackground/MarginContainer/VBoxContainer/CardViewContainer/VBoxContainer2/MarginContainer2/TextureRect/APCostLabel"
@onready var mp_cost_label: Label = $"../MainVBox/CardViewerBackground/MarginContainer/VBoxContainer/CardViewContainer/VBoxContainer2/MarginContainer3/TextureRect/MPCostLabel"
@onready var amount_owned_label: Label = $"../MainVBox/CardViewerBackground/MarginContainer/VBoxContainer/CardViewContainer/VBoxContainer/MarginContainer/NinePatchRect/VBoxContainer/AmountOwnedLabel"
@onready var card_type_target_label: Label = $"../MainVBox/CardViewerBackground/MarginContainer/VBoxContainer/CardTypeContainer/CardTypeTargetLabel"
@onready var card_effect_rich_label: RichTextLabel = $"../MainVBox/CardViewerBackground/MarginContainer/VBoxContainer/CardEffectContainer/CardEffectRichLabel"
@onready var remove_button: TextureButton = $"../MainVBox/AddRemoveMargin/NinePatchRect/MarginContainer/HBoxContainer/RemoveButtonMargin/RemoveButton"
@onready var add_button: TextureButton = $"../MainVBox/AddRemoveMargin/NinePatchRect/MarginContainer/HBoxContainer/AddButtonMargin/AddButton"

var player_deck : Deck


func set_card_displayed(card : CardUI) -> void:
	card_displayed = card.card_data
	display_card()

	

func display_card() -> void:
	card_title_label.text = card_displayed.name
	ap_cost_label.text = str(card_displayed.ap_cost)
	mp_cost_label.text = str(card_displayed.mp_cost)
	card_type_target_label.text = setup_card_type_target()
	card_effect_rich_label.text = get_updated_card_description()
	card_attribute_label.text = get_card_attribute()
	amount_owned_label.text = get_card_amount_owned()

func setup_card_type_target() -> String:
	var value: String = " "
	match card_displayed.target:
		Card.Target.SELF:
			value += "SELF|"
		Card.Target.ONEENEMY:
			value += "TARGET|"
		Card.Target.ALLENEMIES:
			value += "ALL ENEMIES|"
		Card.Target.ALL:
			value += "ALL|"
		_:
			value += "None|"
	match card_displayed.type:
		Card.Type.ATTACK:
			value += "ATTACK "
		Card.Type.DEFEND:
			value += "DEFEND "
		Card.Type.BUFF:
			value += "BUFF "
		Card.Type.DEBUFF:
			value += "DEBUFF "
		_:
			"Null "
	return value

func get_updated_card_description() -> String:
	return card_displayed.get_description(player_stats)
	
func get_card_attribute() -> String:
	return str(Card.CardAttribute.find_key(card_displayed.attribute))

func get_card_amount_owned() -> String:
	player_deck = player_stats.starting_deck
	return str(player_deck.Obtained_Cards[card_displayed])
