class_name MimicRecorder extends Node
## Listens for finished enemy actions and keeps the last usable one.
## Add as a child of BattleScene/Functionality. Group: MimicRecorder.

signal profile_recorded(profile: MimicProfile)

var last_profile: MimicProfile
var last_mimic_card: MimicCard
var perfect_pitch_ready := false   # set by Perfect Pitch, consumed by Mimicry


func _ready() -> void:
	add_to_group("MimicRecorder")
	Events.EnemyActionCompleted.connect(_on_action_completed)
	Events.card_played.connect(_on_card_played)


func _on_action_completed(action: EnemyAction) -> void:
	if action == null or not is_instance_valid(action):
		return   # a skipped / stunned turn
	var profile := action.get_mimic_profile()
	if profile:
		last_profile = profile
		profile_recorded.emit(profile)


func _on_card_played(card: Card) -> void:
	if card is MimicCard:
		last_mimic_card = card
