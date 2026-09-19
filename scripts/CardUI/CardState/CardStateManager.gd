class_name CardStateManager extends Node

@export var starting_state: CardState

var current_state: CardState
var states:= {}

# CardStateManager.gd
func init(card: CardUI) -> void:
	for Child in get_children():
		if Child is CardState:
			states[Child.state] = Child
			if not Child.TransitionRequest.is_connected(_onTransitionRequest):
				Child.TransitionRequest.connect(_onTransitionRequest)
			Child.card_UI = card
	if not card.gui_input.is_connected(on_gui_input):
		card.gui_input.connect(on_gui_input)
	var start := starting_state
	if card.Mode == CardUI.CardMode.DISPLAYING:
		start = states.get(CardState.State.DISPLAYING, starting_state)
	if start:
		start.enter()
		current_state = start

func process(delta: float) -> void:
	if current_state:
		current_state.process(delta)
func on_input(event: InputEvent) -> void:
	if current_state:
		current_state.on_input(event)
		if current_state.state == CardState.State.DRAGGING:
			print("There's an input, and we're passing it to the current state's on_input: ", current_state.name)

func  on_gui_input(event: InputEvent) -> void:
	if current_state:
		current_state.on_gui_input(event)
		if current_state.state == CardState.State.CLICKED:
				print("There's an input, and we're passing it to the current state's on_gui_input: ", current_state.name)
		
func _onTransitionRequest(from: CardState, to: CardState.State) -> void:
	if from != current_state:
		print("Attempting to Transition from a state that is not current State! ", from.name, " " , current_state.name)
		return
	var new_state: CardState = states[to]
	if not new_state:
		print("Attempting to Transition to the SAME STATE." , new_state.name)
		return
	if current_state:
		current_state.exit()
		print("Exited: " , current_state.name)
	new_state.enter()
	print("Entered: ", new_state.name)
	current_state = new_state
