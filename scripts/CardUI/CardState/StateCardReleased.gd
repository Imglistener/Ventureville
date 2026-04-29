extends CardState
@onready var card: CardUI = $"../.."

var played : bool
var initial_event_handled:= false
func enter() -> void:
	played = false
	initial_event_handled = false
	
	if not card_UI.targets.is_empty():
		played = true
		card_UI.play()
		var hand : CardHand = card.get_parent()
		await card.tree_exited
		hand.arrange_hand()
		hand.define_playable()
func process(_delta: float) -> void:		
	if played:
		return
	card_UI.animate_card(1)
	TransitionRequest.emit(self, CardState.State.IDLING)
