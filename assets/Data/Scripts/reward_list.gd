class_name CardList extends Control
## Card reward picker: shows a few random cards from a pool side by side,
## lets the player pick one, then animates out.
##
## Usage:
##     card_list.open()             # uses the exported card_pool
##     card_list.open(some_pool)    # or hand it a pool at runtime
##
## Listen to card_chosen / skipped / closed.
## This node should fill the area the cards are allowed to live in
## (e.g. anchors preset "Full Rect"). Cards are centered inside its rect and
## shrunk automatically if they don't fit.

signal card_chosen(card: Card)
signal skipped
signal closed

enum State { CLOSED, SHOWING, SHOWN, HIDING }

@export_group("Cards")
@export var card_scene: PackedScene
@export var card_pool: Array[Card] = []
@export var choice_count: int = 3
## Passed to CardUI.set_display_size() (same size the deck viewer uses).
@export var card_size := Vector2(247.0, 406.5)
@export var card_spacing: float = 60.0
## Empty space kept between the cards and this node's edges.
@export var edge_margin: float = 40.0
## Optional. If set, the chosen card is added to this deck.
@export var player_deck: Deck

@export_group("Enter Animation")
@export var enter_duration := 0.45
@export var enter_stagger := 0.12
@export var enter_offset_y := 220.0
@export var enter_start_scale := 0.6
## Cards start fanned out by this many radians per slot and straighten up.
@export var enter_fan_rotation := 0.12

@export_group("Hover")
@export var hover_scale := 1.12
@export var hover_lift := 30.0
@export var hover_duration := 0.18
## Brightness of the cards that are NOT hovered (1.0 = no dimming).
@export_range(0.0, 1.0) var unhovered_brightness := 0.65

@export_group("Exit Animation")
@export var chosen_pop_scale := 1.2
@export var chosen_rise := 120.0
@export var exit_duration := 0.35
@export var exit_drop := 160.0
@export var exit_stagger := 0.05

## Used by the cards to fill in scaled values ("Deal {scaled} damage").
## Leave empty to look it up from the Stat_Manager in the "player" group.
var player_stats: CharacterInstance

var _state := State.CLOSED
var _cards: Array[CardUI] = []
var _hovered: CardUI = null
var _fit := 1.0                         # extra shrink so the row fits inside our rect
var _rest_pos: Dictionary = {}          # CardUI -> Vector2 (top-left position when idle)
var _natural_scale: Dictionary = {}     # CardUI -> Vector2 (scale right after set_display_size)
var _tweens: Dictionary = {}            # CardUI -> Tween (current hover tween)


func _ready() -> void:
	visible = false
	set_process(false)
	resized.connect(_on_resized)
	get_tree().create_timer(3).timeout.connect(open)


# ------------------------------------------------------------------ public API

## Picks random cards, builds them, and plays the enter animation.
func open(pool: Array[Card] = []) -> void:
	if _state != State.CLOSED:
		return
	var source: Array[Card] = pool if not pool.is_empty() else card_pool
	var picks := _pick_random(source, choice_count)
	if picks.is_empty():
		push_warning("CardList: the card pool is empty.")
		return
	if size == Vector2.ZERO:
		push_warning("CardList has no size. Make it fill its parent so the cards have room.")

	_state = State.SHOWING
	visible = true
	_build_cards(picks)

	# Give CardUI one frame to finish its own setup (size/scale from set_display_size).
	await get_tree().process_frame
	for card in _cards:
		_natural_scale[card] = card.scale
	_layout_cards()
	await animate_in()


## Cards must already be built (open() does that). Named animate_in/out because
## show()/hide() are native Control methods and can't be overridden.
func animate_in() -> void:
	_state = State.SHOWING
	var running: Array[Tween] = []
	var count := _cards.size()

	for i in count:
		var card := _cards[i]
		var rest: Vector2 = _rest_pos[card]
		var base := _base_scale(card)
		var fan := (i - (count - 1) * 0.5) * enter_fan_rotation

		# Starting pose: lower, smaller, tilted, invisible.
		card.position = rest + Vector2(0.0, enter_offset_y)
		card.scale = base * enter_start_scale
		card.rotation = fan
		card.modulate = Color(1.0, 1.0, 1.0, 0.0)

		var t := card.create_tween()
		t.tween_interval(i * enter_stagger)
		t.tween_property(card, "position", rest, enter_duration) \
			.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		t.parallel().tween_property(card, "scale", base, enter_duration) \
			.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		t.parallel().tween_property(card, "rotation", 0.0, enter_duration) \
			.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
		t.parallel().tween_property(card, "modulate:a", 1.0, enter_duration * 0.6)
		running.append(t)

	await _await_all(running)
	_state = State.SHOWN
	set_process(true)


## Plays the exit animation, then frees the cards. `chosen` gets a "pop" and
## floats up; every other card drops away. Pass null to drop them all.
func animate_out(chosen: CardUI = null) -> void:
	if _state == State.CLOSED:
		return
	_state = State.HIDING
	set_process(false)
	_hovered = null

	var running: Array[Tween] = []
	var order := 0

	for card in _cards:
		_kill_tween(card)
		var base := _base_scale(card)
		var t := card.create_tween()

		if card == chosen:
			card.z_index = 10
			# Step 1: pop + flash.
			t.tween_property(card, "scale", base * chosen_pop_scale, 0.15) \
				.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
			t.parallel().tween_property(card, "modulate", Color(1.4, 1.4, 1.4, 1.0), 0.15)
			t.parallel().tween_property(card, "rotation", 0.0, 0.15)
			# Step 2: float up and fade.
			t.tween_property(card, "position", card.position + Vector2(0.0, -chosen_rise), exit_duration) \
				.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
			t.parallel().tween_property(card, "modulate:a", 0.0, exit_duration)
		else:
			card.z_index = 0
			t.tween_interval(order * exit_stagger)
			t.tween_property(card, "position", card.position + Vector2(0.0, exit_drop), exit_duration) \
				.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
			t.parallel().tween_property(card, "scale", base * 0.85, exit_duration)
			t.parallel().tween_property(card, "modulate:a", 0.0, exit_duration)
			order += 1

		running.append(t)

	await _await_all(running)
	_cleanup()
	closed.emit()


## Closes without picking anything (wire your Skip button to this).
func skip() -> void:
	if _state != State.SHOWN:
		return
	_state = State.HIDING
	set_process(false)
	skipped.emit()
	await animate_out()


# ------------------------------------------------------------------ building

func _pick_random(pool: Array[Card], count: int) -> Array[Card]:
	var shuffled := pool.duplicate()
	shuffled.shuffle()
	var result: Array[Card] = []
	for i in mini(count, shuffled.size()):
		result.append(shuffled[i])
	return result


func _resolve_player_stats() -> CharacterInstance:
	if player_stats:
		return player_stats
	var manager := get_tree().get_first_node_in_group("player") as Stat_Manager
	return manager.Player if manager else null


func _build_cards(picks: Array[Card]) -> void:
	var stats := _resolve_player_stats()
	for data in picks:
		var card_ui := card_scene.instantiate() as CardUI
		# Same setup order CardViewer uses for display-only cards, plus player_stats
		# (CardUI._ready reads it to build the description).
		card_ui.card_data = data
		card_ui.player_stats = stats
		card_ui.Mode = CardUI.CardMode.DISPLAYING
		card_ui.modulate.a = 0.0
		add_child(card_ui)
		card_ui.set_display_size(card_size)
		card_ui.is_displaying = true
		card_ui.is_playable.hide()
		card_ui.CardClicked.connect(_on_card_clicked)
		_cards.append(card_ui)


## Centers the row inside our rect and computes each card's resting position.
func _layout_cards() -> void:
	var count := _cards.size()
	if count == 0:
		return

	var natural := _natural_size(_cards[0])
	var full_width := natural.x * count + card_spacing * (count - 1)

	# Shrink everything uniformly if the row doesn't fit inside our confines.
	var avail := size - Vector2.ONE * edge_margin * 2.0
	_fit = 1.0
	if avail.x > 0.0 and avail.y > 0.0:
		_fit = minf(1.0, minf(avail.x / full_width, avail.y / natural.y))

	var card_w := natural.x * _fit
	var gap := card_spacing * _fit
	var row_w := card_w * count + gap * (count - 1)
	var first_center_x := (size.x - row_w) * 0.5 + card_w * 0.5
	var center_y := size.y * 0.5

	for i in count:
		var card := _cards[i]
		# Scale/rotation happen around the card's center, so the center stays put.
		card.pivot_offset = card.size * 0.5
		var center := Vector2(first_center_x + i * (card_w + gap), center_y)
		_rest_pos[card] = center - card.pivot_offset


func _natural_size(card: CardUI) -> Vector2:
	var nat: Vector2 = _natural_scale.get(card, Vector2.ONE)
	var s := card.size * nat
	return s if s.x > 0.0 and s.y > 0.0 else card_size


func _base_scale(card: CardUI) -> Vector2:
	var nat: Vector2 = _natural_scale.get(card, card.scale)
	return nat * _fit


func _on_resized() -> void:
	if _state != State.SHOWN:
		return
	_layout_cards()
	_refresh_hover()


# ------------------------------------------------------------------ hover

# Hover is hit-tested against each card's RESTING rect instead of using
# mouse_entered/exited. Otherwise lifting/scaling the card moves it out from
# under the cursor near its edges, which makes the hover flicker on and off.
func _process(_delta: float) -> void:
	var mouse := get_local_mouse_position()
	var hit: CardUI = null
	for card in _cards:
		if _rest_rect(card).has_point(mouse):
			hit = card
			break
	if hit != _hovered:
		_hovered = hit
		_refresh_hover()


func _rest_rect(card: CardUI) -> Rect2:
	var rest: Vector2 = _rest_pos[card]
	var vis := _natural_size(card) * _fit
	var center := rest + card.pivot_offset
	return Rect2(center - vis * 0.5, vis)


func _refresh_hover() -> void:
	var dim := unhovered_brightness
	for card in _cards:
		var rest: Vector2 = _rest_pos[card]
		var base := _base_scale(card)
		if _hovered == null:
			card.z_index = 0
			_tween_card(card, rest, base, Color.WHITE)
		elif card == _hovered:
			card.z_index = 10
			_tween_card(card, rest + Vector2(0.0, -hover_lift), base * hover_scale, Color.WHITE)
		else:
			card.z_index = 0
			_tween_card(card, rest, base, Color(dim, dim, dim, 1.0))


func _tween_card(card: CardUI, pos: Vector2, scl: Vector2, tint: Color) -> void:
	_kill_tween(card)
	var t := card.create_tween().set_parallel(true).set_ease(Tween.EASE_OUT)
	t.tween_property(card, "position", pos, hover_duration).set_trans(Tween.TRANS_CUBIC)
	t.tween_property(card, "scale", scl, hover_duration).set_trans(Tween.TRANS_BACK)
	t.tween_property(card, "modulate", tint, hover_duration).set_trans(Tween.TRANS_CUBIC)
	_tweens[card] = t


func _kill_tween(card: CardUI) -> void:
	var t: Tween = _tweens.get(card)
	if t and t.is_valid():
		t.kill()
	_tweens.erase(card)


# ------------------------------------------------------------------ choosing

func _on_card_clicked(card_ui: CardUI) -> void:
	if _state != State.SHOWN:
		return
	_choose(card_ui)


func _choose(card_ui: CardUI) -> void:
	_state = State.HIDING  # blocks any further clicks
	set_process(false)
	var picked := card_ui.card_data
	_save_card(picked)
	card_chosen.emit(picked)
	await animate_out(card_ui)


func _save_card(card: Card) -> void:
	if not player_deck:
		return
	player_deck.Obtained_Cards[card] = int(player_deck.Obtained_Cards.get(card, 0)) + 1
	if not card in player_deck.Cards_in_Deck:
		player_deck.Cards_in_Deck.append(card)


# ------------------------------------------------------------------ helpers

func _await_all(tweens: Array[Tween]) -> void:
	for t in tweens:
		if t.is_running():
			await t.finished


func _cleanup() -> void:
	for card in _cards:
		card.queue_free()
	_cards.clear()
	_rest_pos.clear()
	_natural_scale.clear()
	_tweens.clear()
	_hovered = null
	_fit = 1.0
	_state = State.CLOSED
	visible = false
