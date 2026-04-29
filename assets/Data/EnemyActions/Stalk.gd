extends EnemyAction

@export var block_gained : int
var SFXBus : AudioStreamPlayer
var Audio: AudioStreamPlaybackPolyphonic

func _ready() -> void:
	SFXBus = get_tree().get_first_node_in_group("SFXBus")
func use_action() -> void:
	if not Enemy or not target:
		return
	super()
	var block_effect := BlockEffect.new()
	block_effect.amount = block_gained
	SFXBus.stream = SoundEffect
	SFXBus.play()

	get_tree().create_timer(2.8, false).timeout.connect(
		func():
			block_effect.activate([Enemy])
			Events.EnemyActionCompleted.emit(self)
			
	)
