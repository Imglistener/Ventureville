extends Control
@onready var player_view: PlayerView = $Base_Margin/MarginContainer/PlayerView
@onready var background: StandbyMenu = $Base_Margin/StandbyContainer/Background
@onready var ap_bar: TextureProgressBar = $AP_Background/AP_Bar
@onready var mana_ui: TextureRect = $Mana_UI

@onready var panel = $PanelContainer
@onready var card_pile_displayer: CardPileDisplayer = $"../Pause Layer/DeckDisplayer"
@onready var discard_displayer: CardPileDisplayer = $"../Pause Layer/DiscardDisplayer"



var current_message: String
var triggers: Array[CardUI]
var _just_opened := false

func on_trigger_pressed(card: CardUI) -> void:
	panel.visible = true
	current_message = build_card_display(card.card_data, card.card_data.get_description(get_tree().get_first_node_in_group('player').Player))
	_just_opened = true
	await get_tree().process_frame
	_just_opened = false
	apply_keyword_styling()

func build_card_display(data: Card, description: String) -> String:
	var type_name = Card.Type.keys()[data.type]
	var type_color = KeywordsScene.color_of(Card.Type.keys()[data.type]).to_html()
	var AP_color = KeywordsScene.color_of("AP").to_html()
	var MP_color = KeywordsScene.color_of("MP").to_html()
	var header := "[b][color=%s]%s[/color][/b]" % [type_color, type_name]
	var costs := "[color=%s]AP:[/color] %d   [color=%s]MP:[/color] %d" % [AP_color, data.ap_cost, MP_color,  data.mp_cost]
	var divider := "[color=#444444]────────────────────[/color]"

	return "%s\n%s\n%s\n%s" % [header, costs, divider, description]

func apply_keyword_styling() -> void:
	var textlabel := panel.card_effect as RichTextLabel
	var placeholders: Dictionary = {}
	var i := 0
	
	textlabel.parse_bbcode(KeywordsScene.format(current_message))

func _input(event: InputEvent) -> void:
	if _just_opened:
		return
	if panel.visible and event is InputEventMouseButton:
		if event.pressed:
			if not panel.get_global_rect().has_point(event.global_position):
				panel.hide()

func handle_deck_press() -> void:
	card_pile_displayer.toggle()

func handle_discard_press() -> void:
	discard_displayer.toggle()
