extends Control
@onready var player_view: PlayerView = $Base_Margin/MarginContainer/PlayerView
@onready var background: StandbyMenu = $Base_Margin/StandbyContainer/Background
@onready var ap_bar: TextureProgressBar = $AP_Bar
@onready var mana_ui: TextureRect = $Mana_UI

@onready var panel = $PanelContainer

const KEYWORDS: Dictionary = {
	#CardName:
	"Blood Aias": "[color=gray]{0}[/color]",
	# Status effects
	"Burning":      "[color=#ff4500][wave]{0}[/wave][/color]",
	"Frostbite":    "[color=#00cfff][wave]{0}[/wave][/color]",
	"Blood Syphon":  "[color=#cc0000][wave]{0}[/wave][/color]",
	"Horrified":    "[color=#9b59b6][shake]{0}[/shake][/color]",
	"Concussed":    "[color=#e0a030][shake]{0}[/shake][/color]",
	"Stunned":      "[color=#f0e68c][shake]{0}[/shake][/color]",
	"Withering":    "[color=#7f8c8d][wave]{0}[/wave][/color]",
	# Elements
	"Fire":         "[color=#ff4500]{0}[/color]",
	"Frost":        "[color=#00cfff]{0}[/color]",
	"Blood":        "[color=#cc0000]{0}[/color]",
	"Entropy":      "[color=#9b59b6]{0}[/color]",
	"Psychic":      "[color=#e056fd]{0}[/color]",
	"Physical":     "[color=#e0a030]{0}[/color]",
	# Actions
	"Attack":       "[color=#ff6b6b]{0}[/color]",
	"Defend":       "[color=#6bcaff]{0}[/color]",
	"Buff":         "[color=#2ecc71]{0}[/color]",
	"Debuff":       "[color=#e74c3c]{0}[/color]",
	"Transition":   "[color=#f0e68c]{0}[/color]",
	"Heal": 		"[color=green]{0}[/color]"
}

const TYPE_COLORS: Dictionary = {
	Card.Type.ATTACK:  "#ff6b6b",
	Card.Type.BUFF:    "#2ecc71",
	Card.Type.DEBUFF:  "#e74c3c",
	Card.Type.DEFEND:  "#6bcaff",
}

var current_message: String
var triggers: Array[CardUI]
var _just_opened := false

func on_trigger_pressed(card: CardUI) -> void:
	panel.visible = true
	current_message = build_card_display(card.card_data, card.card_effect.text)
	_just_opened = true
	await get_tree().process_frame
	_just_opened = false
	apply_keyword_styling()

func build_card_display(data: Card, description: String) -> String:
	var type_name = Card.Type.keys()[data.type]
	var type_color = TYPE_COLORS[data.type]

	var header := "[b][color=%s]%s[/color][/b]" % [type_color, type_name]
	var costs := "[color=#9238ff]AP:[/color] %d   [color=#00cfff]MP:[/color] %d" % [data.ap_cost, data.mp_cost]
	var divider := "[color=#444444]────────────────────[/color]"

	return "%s\n%s\n%s\n%s" % [header, costs, divider, description]

func apply_keyword_styling() -> void:
	var textlabel := panel.card_effect as RichTextLabel
	var placeholders: Dictionary = {}
	var i := 0
	
	# Pass 1: replace keywords with placeholders
	for keyword in KEYWORDS:
		var placeholder := "##KW_%d##" % i
		placeholders[placeholder] = KEYWORDS[keyword].format({0: keyword})
		current_message = current_message.replace(keyword, placeholder)
		i += 1
	
	# Pass 2: replace placeholders with actual BBCode
	for placeholder in placeholders:
		current_message = current_message.replace(placeholder, placeholders[placeholder])
	
	textlabel.parse_bbcode(current_message)

func _input(event: InputEvent) -> void:
	if _just_opened:
		return
	if panel.visible and event is InputEventMouseButton:
		if event.pressed:
			if not panel.get_global_rect().has_point(event.global_position):
				panel.hide()
