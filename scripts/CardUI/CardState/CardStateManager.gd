class_name CardStateManager extends Node

@export var starting_state: CardState

var current_state: CardState
var states:= {}

func init(card: CardUI)-> void:
	for Child in get_children():
		if Child is CardState:
			states[Child.state] = Child
			if not Child.TransitionRequest.is_connected(_onTransitionRequest):
				Child.TransitionRequest.connect(_onTransitionRequest)
			Child.card_UI = card
			if not card.gui_input.is_connected(Child.on_gui_input):
				card.gui_input.connect(Child.on_gui_input)
	if starting_state:
		starting_state.enter()
		current_state = starting_state
func process(delta: float) -> void:
	if current_state:
		current_state.process(delta)
func on_input(event: InputEvent) -> void:
	if current_state:
		current_state.on_input(event)
func  on_gui_input(event: InputEvent) -> void:
	if current_state:
		current_state.on_gui_input(event)

		
func _onTransitionRequest(from: CardState, to: CardState.State) -> void:
	if from != current_state:
		return
	var new_state: CardState = states[to]
	if not new_state:
		return
	if current_state:
		current_state.exit()
	new_state.enter()
	current_state = new_state
