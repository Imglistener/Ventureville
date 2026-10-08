extends Node


@export var keywords: Array[KeywordData] = []

var _by_name: Dictionary = {}    # normalized name/alias   -> KeywordData
var _by_phrase: Dictionary = {}  # normalized formatter phrase -> KeywordData
var _by_status: Dictionary = {}  # StatusEffect.StatusEffects -> KeywordData

var _phrase_regex: RegEx
var _tag_regex: RegEx
var _space_regex: RegEx
var _built := false


func _ready() -> void:
	_build()


# ------------------------------------------------------------------ lookup

func get_keyword(keyword_name: String) -> KeywordData:
	_ensure_built()
	return _by_name.get(_normalize(keyword_name))


## Color for a keyword name or alias. Used by floating labels, the log, etc.
func color_of(keyword_name: String, fallback: Color = Color.WHITE) -> Color:
	var kw := get_keyword(keyword_name)
	return kw.color if kw else fallback


## Wraps a keyword in its color tag. Pass `text` to keep different wording,
## e.g. colorize("Heal", "Healed"). Unknown keywords come back unchanged.
func colorize(keyword_name: String, text: String = "") -> String:
	var kw := get_keyword(keyword_name)
	if text.is_empty():
		text = keyword_name
	return kw.wrap(text) if kw else text


# ------------------------------------------------------------------ formatting

## Turns plain text into BBCode with every known keyword colored.
## - Text already inside a [color] tag is left alone, so pre-colored values
##   (e.g. damage numbers) never get double-wrapped.
## - Longest phrases win: "Blood Syphon" beats "Blood".
func format(text: String) -> String:
	_ensure_built()
	if text.is_empty() or _phrase_regex == null:
		return text

	var out := ""
	var cursor := 0
	var color_depth := 0
	for tag in _tag_regex.search_all(text):
		out += _format_plain(text.substr(cursor, tag.get_start() - cursor), color_depth)
		var tag_text := tag.get_string()
		var lowered := tag_text.to_lower()
		if lowered.begins_with("[color"):
			color_depth += 1
		elif lowered == "[/color]":
			color_depth = maxi(color_depth - 1, 0)
		out += tag_text
		cursor = tag.get_end()
	out += _format_plain(text.substr(cursor), color_depth)
	return out


## Keywords present in the text, unique, in order of appearance.
## Pass tooltip_only = true to keep only those that spawn a keyword tooltip.
func find_in(text: String, tooltip_only: bool = false) -> Array[KeywordData]:
	_ensure_built()
	var found: Array[KeywordData] = []
	if text.is_empty() or _phrase_regex == null:
		return found
	for m in _phrase_regex.search_all(text):
		var kw: KeywordData = _by_phrase.get(_normalize(m.get_string()))
		if kw == null or found.has(kw):
			continue
		if tooltip_only and not kw.show_tooltip:
			continue
		found.append(kw)
	return found


## A keyword's description with other keywords colored. Ready for a
## RichTextLabel with bbcode_enabled.
func get_description(kw: KeywordData) -> String:
	return format(kw.description) if kw else ""


# ------------------------------------------------------------------ statuses

func get_status_keyword(status: StatusEffect.StatusEffects) -> KeywordData:
	_ensure_built()
	return _by_status.get(status)


func name_for_status(status: StatusEffect.StatusEffects) -> String:
	var kw := get_status_keyword(status)
	return kw.display_name if kw else "Unknown"


func description_for_status(status: StatusEffect.StatusEffects) -> String:
	return get_description(get_status_keyword(status))


# ------------------------------------------------------------------ internals

func _ensure_built() -> void:
	if not _built:
		_build()


func _build() -> void:
	_by_name.clear()
	_by_phrase.clear()
	_by_status.clear()

	_space_regex = RegEx.new()
	_space_regex.compile("\\s+")
	_tag_regex = RegEx.new()
	_tag_regex.compile("\\[/?[^\\[\\]]*\\]")

	var phrases: Array[String] = []
	for kw in keywords:
		if kw == null or kw.display_name.is_empty():
			continue
		for n in kw.get_all_names():
			var key := _normalize(n)
			if _by_name.has(key) and _by_name[key] != kw:
				push_warning("Keywords: '%s' is claimed by more than one keyword." % n)
			_by_name[key] = kw

			# Elements with a suffix only match as a phrase ("Blood Damage"),
			# so a bare "Blood" inside a card name is not colored.
			var phrase := n
			if not kw.absorbs_suffix.is_empty():
				phrase = "%s %s" % [n, kw.absorbs_suffix]
			_by_phrase[_normalize(phrase)] = kw
			phrases.append(phrase)

		if kw.has_status_link:
			_by_status[kw.status_link] = kw

	# Longest first so the regex prefers "Blood Syphon" over "Blood".
	phrases.sort_custom(func(a: String, b: String) -> bool: return a.length() > b.length())

	var parts := PackedStringArray()
	for p in phrases:
		parts.append(_to_pattern(p))

	_phrase_regex = null
	if not parts.is_empty():
		var regex := RegEx.new()
		var err := regex.compile("(?i)\\b(?:%s)\\b" % "|".join(parts))
		if err == OK:
			_phrase_regex = regex
		else:
			push_error("Keywords: failed to compile keyword regex.")

	_built = true


func _format_plain(segment: String, color_depth: int) -> String:
	# Inside an existing [color] tag, or nothing to scan.
	if segment.is_empty() or color_depth > 0:
		return segment
	var out := ""
	var cursor := 0
	for m in _phrase_regex.search_all(segment):
		out += segment.substr(cursor, m.get_start() - cursor)
		var matched := m.get_string()
		var kw: KeywordData = _by_phrase.get(_normalize(matched))
		out += kw.wrap(matched) if kw else matched
		cursor = m.get_end()
	out += segment.substr(cursor)
	return out


## Lowercase, trimmed, whitespace collapsed to single spaces.
func _normalize(s: String) -> String:
	return _space_regex.sub(s.strip_edges().to_lower(), " ", true)


## Escapes regex characters, and lets any gap between words match any
## whitespace (so a line break inside "Blood\nSyphon" still matches).
func _to_pattern(phrase: String) -> String:
	var words := PackedStringArray()
	for word in phrase.strip_edges().split(" ", false):
		var escaped := ""
		for ch in word:
			if ".^$*+?()[]{}|\\".contains(ch):
				escaped += "\\"
			escaped += ch
		words.append(escaped)
	return "\\s+".join(words)
