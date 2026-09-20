class_name CardState extends Node

enum State{IDLING, HOVERING, CLICKED, DRAGGING, TARGETING, RELEASED, DISPLAYING, SELECTED}

signal TransitionRequest(From: CardState, to: State)

@export var state: State

var card_UI : CardUI

# ── INPUT ROUTING CONTRACT ───────────────────────────────────────────────────
# Every physical input event is delivered to at most ONE of the two callbacks,
# chosen by uses_global_input():
#
#   false (default) -> "hover" state (IDLING, SELECTED, DISPLAYING)
#       receives on_gui_input() only. This is Control-local: it fires only while
#       the pointer is over this card and nothing covers it. Use it to START an
#       interaction (hover, press).
#
#   true            -> "capture" state (CLICKED, DRAGGING, TARGETING)
#       receives on_input() only (forwarded from CardUI._input). This is global,
#       so it keeps working when the pointer outruns the card. Use it to
#       CONTINUE and FINISH an interaction (move, release, cancel).
#
# CardStateManager enforces this, so a state never sees the same event twice
# and never needs a "am I still the current state?" guard.
func uses_global_input() -> bool:
	return false

func request_transition(to: State) -> void:
	TransitionRequest.emit(self, to)

func process(_delta: float) -> void:
	pass

func enter() -> void:
	pass

func exit() -> void:
	pass

func on_gui_input(_event: InputEvent) -> void:
	pass

func on_input(_event: InputEvent) -> void:
	pass

func mouse_entered() -> void:
	pass

func mouse_exited() -> void:
	pass
