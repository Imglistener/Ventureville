class_name KeywordData extends Resource


enum Category {
	STATUS,     ## Blood Syphon, Regeneration, Burning...
	ELEMENT,    ## Blood, Fire, Frost, Entropy...
	RESOURCE,   ## Heal, Shield, SAN Shield, AP, MP...
	ACTION,     ## Attack, Defend, Buff, Debuff...
	CARD_TYPE,  ## Card type names shown in headers
	MECHANIC,   ## Sacrifice, Retain...
}

enum TextEffect { NONE, WAVE, SHAKE }

@export_group("Identity")
## Canonical text, e.g. "Blood Syphon". Also the lookup key (case-insensitive).
@export var display_name: String
## Other spellings the formatter should catch, e.g. "Heals", "Healed", "Block".
@export var aliases: PackedStringArray = []
@export var category: Category = Category.MECHANIC

@export_group("Appearance")
@export var color: Color = Color.WHITE
@export var text_effect: TextEffect = TextEffect.NONE
## If the keyword is directly followed by this word, color both as one phrase.
## e.g. element "Blood" with "Damage" -> "Blood Damage". Empty = disabled.
@export var absorbs_suffix: String = ""

@export_group("Tooltip")
## Whether hovering a card containing this keyword spawns a keyword tooltip.
@export var show_tooltip: bool = false
## Plain text. May mention other keywords; the formatter colors them.
@export_multiline var description: String = ""

@export_group("Status Link")
## Enable to tie this keyword to a StatusEffect so status tooltips can look up
## their name/description here instead of using a hardcoded match.
@export var has_status_link: bool = false
@export var status_link: StatusEffect.StatusEffects = StatusEffect.StatusEffects.Burning


## Every string the formatter should recognize for this keyword.
func get_all_names() -> PackedStringArray:
	var names := PackedStringArray()
	if not display_name.is_empty():
		names.append(display_name)
	names.append_array(aliases)
	return names


func get_color_hex() -> String:
	return color.to_html(false)


## Wraps text in this keyword's color (and text effect, if any) as BBCode.
## `text` defaults to the display name; pass the matched text to preserve the
## original wording/casing, e.g. wrap("Heals").
func wrap(text: String = "") -> String:
	if text.is_empty():
		text = display_name
	var inner := text
	match text_effect:
		TextEffect.WAVE:
			inner = "[wave]%s[/wave]" % text
		TextEffect.SHAKE:
			inner = "[shake]%s[/shake]" % text
	return "[color=#%s]%s[/color]" % [get_color_hex(), inner]
