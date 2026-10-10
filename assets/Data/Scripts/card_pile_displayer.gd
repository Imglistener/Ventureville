class_name CardPileDisplayer
extends Control
## Shows either the draw pile (Battle_Deck) or the Discard_Pile as a grid of cards.
## Call setup(stat_manager.Player) once the player exists, then open()/close()/toggle().

signal cards_displayed_updated
signal opened
signal closed

enum DisplayModes { BattleDeck, DiscardPile }

@export var display_mode: DisplayModes = DisplayModes.BattleDeck
@export var card_scene: PackedScene = preload("res://assets/Data/NewScenes/Cards/card.tscn")
@export var card_size := Vector2(247.0, 406.5)
@export var fade_time := 0.2
## Sorted so the draw pile doesn't reveal the draw order.
@export var sort_alphabetically := true
@export var back_open_position := Vector2(0.0, 419.0)
@export var back_closed_position := Vector2(-107.0, 419.0)

@onready var grid_container: GridContainer =$Background/MarginContainer/ScrollContainer/GridContainer
@onready var back: TextureButton = $Background/Back
@onready var background: Control = $Background
@onready var content_margin: MarginContainer = $Background/MarginContainer

var player_stats: CharacterInstance   # the RUNTIME player (Stat_Manager.Player), not the .tres
var player_deck: Deck
var cards_displayed: Array[Card] = []
var is_open := false

var _card_uis: Array[CardUI] = []
var _tween: Tween
var _refresh_queued := false


func _ready() -> void:
	hide()
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_set_content_alpha(0.0)
	back.pressed.connect(close)
	# Wait a frame so the container layout has run before we override the position.
	await get_tree().process_frame
	back.global_position = back_closed_position


# ------------------------------------------------------------------ setup

func setup(stats: CharacterInstance) -> void:
	_disconnect_deck()
	player_stats = stats
	player_deck = stats.starting_deck if stats else null
	_connect_deck()
	if is_open:
		refresh()


func _connect_deck() -> void:
	if not player_deck:
		return
	if not player_deck.DeckSize_Changed.is_connected(_on_deck_changed):
		player_deck.DeckSize_Changed.connect(_on_deck_changed)
	if not player_deck.DiscardSize_Changed.is_connected(_on_deck_changed):
		player_deck.DiscardSize_Changed.connect(_on_deck_changed)


func _disconnect_deck() -> void:
	if not player_deck:
		return
	if player_deck.DeckSize_Changed.is_connected(_on_deck_changed):
		player_deck.DeckSize_Changed.disconnect(_on_deck_changed)
	if player_deck.DiscardSize_Changed.is_connected(_on_deck_changed):
		player_deck.DiscardSize_Changed.disconnect(_on_deck_changed)


func _on_deck_changed(_value: Variant = null) -> void:
	# Only pay for a rebuild while visible; open() always refreshes anyway.
	# Deferred + flagged so several signals in one frame cause one refresh.
	if not is_open or _refresh_queued:
		return
	_refresh_queued = true
	_flush_refresh.call_deferred()


func _flush_refresh() -> void:
	_refresh_queued = false
	if is_open:
		refresh()


# ------------------------------------------------------------------ open / close

func open() -> void:
	if is_open:
		return
	is_open = true
	refresh()
	show()
	mouse_filter = Control.MOUSE_FILTER_STOP
	_animate(true)
	opened.emit()


func close() -> void:
	if not is_open:
		return
	is_open = false
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_animate(false, func() -> void:
		if not is_open:   # may have been reopened mid-animation
			hide()
	)
	closed.emit()


func toggle() -> void:
	if is_open:
		close()
	else:
		open()


func _set_content_alpha(alpha: float) -> void:
	background.self_modulate.a = alpha   # the panel itself, not its children
	content_margin.modulate.a = alpha    # the card grid


## Fades the panel and grid, while the back button slides instead of fading.
func _animate(to_show: bool, on_done: Callable = Callable()) -> void:
	if _tween and _tween.is_valid():
		_tween.kill()
	_tween = create_tween().set_ease(Tween.EASE_IN_OUT).set_parallel(true)
	var alpha := 1.0 if to_show else 0.0
	_tween.tween_property(background, "self_modulate:a", alpha, fade_time)
	_tween.tween_property(content_margin, "modulate:a", alpha, fade_time)
	_tween.tween_property(back, "global_position",
			back_open_position if to_show else back_closed_position, fade_time)
	if on_done.is_valid():
		_tween.finished.connect(on_done)


# ------------------------------------------------------------------ building

func _get_pile() -> Array[Card]:
	var source: Array[Card] = []
	if not player_deck:
		return source
	match display_mode:
		DisplayModes.BattleDeck:
			source = player_deck.Battle_Deck.duplicate()
		DisplayModes.DiscardPile:
			source = player_deck.Discard_Pile.duplicate()
	if sort_alphabetically:
		source.sort_custom(func(a: Card, b: Card) -> bool: return a.name < b.name)
	return source


## Diffs the grid against the pile: reuses existing CardUIs, adds missing
## copies, frees extras, then puts everything in the right order.
func refresh() -> void:
	if not player_deck or not player_stats or not card_scene:
		return

	cards_displayed = _get_pile()

	# Group existing UIs by card so duplicates are handled correctly.
	var pool: Dictionary = {}   # Card -> Array[CardUI]
	for ui in _card_uis:
		if not is_instance_valid(ui):
			continue
		if not pool.has(ui.card_data):
			pool[ui.card_data] = []
		pool[ui.card_data].append(ui)

	var new_uis: Array[CardUI] = []
	for card in cards_displayed:
		var ui: CardUI = null
		if pool.has(card) and not pool[card].is_empty():
			ui = pool[card].pop_back()
		else:
			ui = _create_card_ui(card)
		new_uis.append(ui)

	# Anything left in the pool is no longer in the pile.
	for card in pool:
		for ui in pool[card]:
			_free_card_ui(ui)

	for i in new_uis.size():
		grid_container.move_child(new_uis[i], i)

	_card_uis = new_uis
	cards_displayed_updated.emit()


func _create_card_ui(card: Card) -> CardUI:
	var ui := card_scene.instantiate() as CardUI
	ui.Mode = CardUI.CardMode.DISPLAYING
	ui.card_data = card
	ui.player_stats = player_stats
	grid_container.add_child(ui)
	ui.set_display_size(card_size)
	ui.is_playable.hide()
	return ui


func _free_card_ui(ui: CardUI) -> void:
	if not is_instance_valid(ui):
		return
	grid_container.remove_child(ui)   # leave the grid now, free at end of frame
	ui.queue_free()
