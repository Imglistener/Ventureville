class_name MethodActingCondition
extends VoiceCondition
## Mimic cards cost 1 less AP (applied in MimicCard.create), and playing one draws 1.

@export var ap_reduction: int = 1
@export var draw_amount: int = 1


func _on_attach() -> void:
	Events.card_played.connect(_on_card_played)


func _on_card_played(card: Card) -> void:
	if not _is_active():
		_stop_listening()
		return
	if card is MimicCard:
		_draw.call_deferred()


func _draw() -> void:
	if not _is_active() or not is_instance_valid(_player):
		return
	var effect := DrawEffect.new()
	effect.amount = draw_amount
	var targets: Array[Node] = [_player]
	effect.activate(targets)


func _stop_listening() -> void:
	if Events.card_played.is_connected(_on_card_played):
		Events.card_played.disconnect(_on_card_played)


func on_expired(targets: Array[Node]) -> void:
	_stop_listening()
	super(targets)
