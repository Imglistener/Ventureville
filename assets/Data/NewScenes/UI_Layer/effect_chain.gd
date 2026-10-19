class_name EffectChain
extends VBoxContainer
## Vertical list of every status effect OR battle condition on one entity.
## Items are Resources exposing get_display_text(): StatusEffect or BattleCondition.

signal closed

enum GrowDirection { UP, DOWN }
enum TooltipSide { RIGHT, LEFT }

@export var grow_direction: GrowDirection
@export var tooltip_side: TooltipSide = TooltipSide.RIGHT
@export var row_size := Vector2(55, 55)
@export var stagger := 0.05
@export var icon_gap := 6.0     # space between the anchor icon and the first row
@export var tooltip_gap := 8.0  # space between a row and its tooltip

var anchor_icon: Control
var tooltip_scene: PackedScene
var condition_tooltip_scene: PackedScene

var _rows: Dictionary = {}   # Resource -> row Control
var _is_open := false
var _tooltip                 # untyped on purpose: two different tooltip classes


func _init() -> void:
	top_level = true
	z_index = 50
	add_theme_constant_override("separation", 2)
	mouse_filter = Control.MOUSE_FILTER_IGNORE


func open(items: Array) -> void:
	set_items(items)
	_is_open = true
	await _reposition()
	_animate_in()


func close() -> void:
	if not _is_open:
		return
	_is_open = false
	_hide_tooltip()
	closed.emit()   # emitted immediately so the manager can forget us right away
	var t := create_tween()
	t.tween_property(self, "modulate:a", 0.0, 0.12)
	await t.finished
	queue_free()


## Diffs against existing rows: removes stale ones, adds new ones, refreshes counts/order.
func set_items(items: Array) -> void:
	items = items.filter(func(i): return i != null)

	for res in _rows.keys():
		if not items.has(res):
			var dead: Control = _rows[res]
			_rows.erase(res)
			remove_child(dead)   # leave the layout now, free at end of frame
			dead.queue_free()

	for i in items.size():
		var item: Resource = items[i]
		var row: Control
		if _rows.has(item):
			row = _rows[item]
		else:
			row = _make_row(item)
			_rows[item] = row
			add_child(row)
		# Growing up: the first effect sits closest to the icon (bottom of the VBox).
		move_child(row, items.size() - 1 - i if _grows_up() else i)
		row.get_node("Icon").texture = _icon_of(item)
		row.get_node("Count").text = item.get_display_text()

	if items.is_empty():
		close()
	elif _is_open:
		_reposition()

func _grows_up() -> bool:
	return grow_direction == GrowDirection.UP
	
func _icon_of(item: Resource) -> Texture:
	return item.status_icon if item is StatusEffect else item.condition_icon


func _make_row(item: Resource) -> Control:
	var row := Control.new()
	row.custom_minimum_size = row_size
	row.mouse_filter = Control.MOUSE_FILTER_STOP

	var icon := TextureRect.new()
	icon.name = "Icon"
	icon.set_anchors_preset(Control.PRESET_FULL_RECT)
	icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.add_child(icon)

	var count := Label.new()
	count.name = "Count"
	count.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_RIGHT, Control.PRESET_MODE_MINSIZE)
	count.grow_horizontal = Control.GROW_DIRECTION_BEGIN
	count.grow_vertical = Control.GROW_DIRECTION_BEGIN
	count.add_theme_font_size_override("font_size", 16)
	count.add_theme_constant_override("outline_size", 4)
	count.add_theme_color_override("font_outline_color", Color.BLACK)
	count.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.add_child(count)

	row.mouse_entered.connect(_show_tooltip.bind(item, row))
	row.mouse_exited.connect(_hide_tooltip)
	return row


# ------------------------------------------------------------------ layout / animation

func _reposition() -> void:
	await get_tree().process_frame   # let the VBox compute its size
	if not is_instance_valid(anchor_icon):
		return
	reset_size()
	var gap := 6.0
	if _grows_up():
		global_position = anchor_icon.global_position + Vector2(0.0, -size.y - gap)
	else:
		global_position = anchor_icon.global_position + Vector2(0.0, anchor_icon.size.y + gap)


func _animate_in() -> void:
	var count := get_child_count()
	for i in count:
		var row := get_child(i) as Control
		row.pivot_offset = Vector2(row.size.x * 0.5, row_size.y if _grows_up() else 0.0)
		row.modulate.a = 0.0
		row.scale = Vector2(0.5, 0.5)
		var order := count - 1 - i if _grows_up() else i   # rows nearest the icon pop first
		var t := create_tween().set_parallel(true).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		t.tween_property(row, "modulate:a", 1.0, 0.15).set_delay(order * stagger)
		t.tween_property(row, "scale", Vector2.ONE, 0.25).set_delay(order * stagger)


# ------------------------------------------------------------------ tooltips

func _show_tooltip(item: Resource, row: Control) -> void:
	_hide_tooltip()
	if item is StatusEffect and tooltip_scene:
		var t := tooltip_scene.instantiate() as StatusEffectTooltip
		t.displayed_status = item
		_tooltip = t
	elif item is BattleCondition and condition_tooltip_scene:
		var t := condition_tooltip_scene.instantiate() as BattleConditionTooltip
		t.displayed_condition = item
		_tooltip = t
	else:
		return

	var tip = _tooltip   # keep a local ref in case the hover ends during the await
	row.add_child(tip)
	tip.top_level = true
	tip.z_index = 60
	tip.modulate.a = 0.0   # hidden until positioned, so it never flashes in the wrong spot
	tip.show_tooltip()

	await get_tree().process_frame
	if not is_instance_valid(tip) or tip != _tooltip:
		return
	tip.global_position = _tooltip_position(row, tip)
	tip.modulate.a = 1.0

func _tooltip_position(row: Control, tip: Control) -> Vector2:
	var panel := tip.get_node_or_null("PanelContainer") as Control
	var tip_width := panel.size.x if panel else tip.size.x
	var x := row.global_position.x
	match tooltip_side:
		TooltipSide.RIGHT:
			x += row.size.x + tooltip_gap
		TooltipSide.LEFT:
			x -= tip_width + tooltip_gap
	return Vector2(x, row.global_position.y)

func _hide_tooltip() -> void:
	if is_instance_valid(_tooltip):
		_tooltip.queue_free()
	_tooltip = null


# ------------------------------------------------------------------ click-outside

func _input(event: InputEvent) -> void:
	if not _is_open:
		return
	if event is InputEventMouseButton and event.pressed:
		var p := get_global_mouse_position()
		if not get_global_rect().has_point(p) and not anchor_icon.get_global_rect().has_point(p):
			close()   # deliberately NOT set_input_as_handled: the click still reaches cards/enemies
