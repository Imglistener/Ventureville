class_name AutoFitRichTextLabel
extends RichTextLabel
## Shrinks the font until the text fits inside this control's size.

@export var max_font_size: int = 0   ## 0 = use whatever size the theme/override gives at _ready
@export var min_font_size: int = 14

var _fitting := false

func _ready() -> void:
	fit_content = false      # must be off, or the label just grows instead of shrinking the font
	scroll_active = false
	if max_font_size <= 0:
		max_font_size = get_theme_font_size("normal_font_size")
	resized.connect(fit_text)   # re-fit once layout gives us a real size
	fit_text()

## Use this instead of `.text = ...` so the fit re-runs.
func set_fitted_text(new_text: String) -> void:
	text = new_text
	fit_text()

func fit_text() -> void:
	if _fitting or size.y <= 0.0:
		return
	_fitting = true

	var lo := min_font_size
	var hi := max_font_size
	var best := min_font_size
	while lo <= hi:
		var mid := (lo + hi) / 2
		_apply_font_size(mid)
		if get_content_height() <= size.y:
			best = mid
			lo = mid + 1
		else:
			hi = mid - 1

	_apply_font_size(best)
	_fitting = false

func _apply_font_size(s: int) -> void:
	# Cover every variant so bold/italic BBCode shrinks too.
	add_theme_font_size_override("normal_font_size", s)
	add_theme_font_size_override("bold_font_size", s)
	add_theme_font_size_override("italics_font_size", s)
	add_theme_font_size_override("bold_italics_font_size", s)
	add_theme_font_size_override("mono_font_size", s)
