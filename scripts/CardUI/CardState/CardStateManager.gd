class_name CardStateManager extends Node
## Owns a card's states and routes input to the active one.
##
## Routing (see CardState.gd for the full contract):
##   hover states   (uses_global_input() == false) <- on_gui_input only
##   capture states (uses_global_input() == true)  <- on_input only
##
## While one card is in a capture state it "owns" the pointer: every other card
## drops its GUI input, so a card being carried can't cause hover/select
## reactions on the cards it passes over.

@export var starting_state: CardState
@export var debug_log := false

# Instance id of the card that currently owns the pointer (0 = nobody).
# Stored as an id rather than a reference so a freed card can't leave a
# dangling typed reference behind.
static var _capture_id: int = 0

var current_state: CardState
var states := {}
var _card: CardUI


func init(card: CardUI) -> void:
	_card = card
	for child in get_children():
		var s := child as CardState
		if not s:
			continue
		if states.has(s.state):
			push_warning("CardStateManager: duplicate state %s on node '%s'" % [CardState.State.find_key(s.state), s.name])
		states[s.state] = s
		if not s.TransitionRequest.is_connected(_on_transition_request):
			s.TransitionRequest.connect(_on_transition_request)
		s.card_UI = card

	# NOTE: deliberately NOT connected to card.gui_input. CardUI._gui_input
	# forwards to on_gui_input() (after its own guards); connecting the signal
	# too would deliver every GUI event twice and bypass those guards.
	if not card.tree_exiting.is_connected(_release_capture):
		card.tree_exiting.connect(_release_capture)

	var start := starting_state
	if card.Mode == CardUI.CardMode.DISPLAYING:
		if states.has(CardState.State.DISPLAYING):
			start = states[CardState.State.DISPLAYING]
		else:
			push_warning("CardStateManager: card is in DISPLAYING mode but has no DISPLAYING state node.")
	if start:
		_change_state(start)


func process(delta: float) -> void:
	if current_state:
		current_state.process(delta)


# Global path (CardUI._input forwards here). Capture states only.
func on_input(event: InputEvent) -> void:
	if current_state and current_state.uses_global_input():
		current_state.on_input(event)


# Control-local path (CardUI._gui_input forwards here). Hover states only.
func on_gui_input(event: InputEvent) -> void:
	if not current_state or current_state.uses_global_input():
		return
	if _locked_by_other_card():
		return
	current_state.on_gui_input(event)


func _on_transition_request(from: CardState, to: CardState.State) -> void:
	if from != current_state:
		_log("Ignored request from non-current state %s (current: %s)" % [from.name, current_state.name if current_state else "none"])
		return
	var new_state: CardState = states.get(to)
	if new_state == null:
		push_warning("CardStateManager: no state node registered for %s." % CardState.State.find_key(to))
		return
	if new_state == current_state:
		return
	_log("%s -> %s" % [current_state.name, new_state.name])
	_change_state(new_state)


func _change_state(new_state: CardState) -> void:
	if current_state:
		current_state.exit()
	# Assign BEFORE enter() so a transition requested from inside enter() is valid.
	current_state = new_state
	_sync_capture()
	new_state.enter()


func _sync_capture() -> void:
	var my_id := _card.get_instance_id()
	if current_state and current_state.uses_global_input():
		_capture_id = my_id
	elif _capture_id == my_id:
		_capture_id = 0


func _release_capture() -> void:
	if _card and _capture_id == _card.get_instance_id():
		_capture_id = 0


func _locked_by_other_card() -> bool:
	return _capture_id != 0 \
		and _capture_id != _card.get_instance_id() \
		and is_instance_id_valid(_capture_id)


func _log(message: String) -> void:
	if debug_log:
		print("[CardState] ", message)
