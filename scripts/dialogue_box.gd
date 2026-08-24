extends RichTextLabel
@onready var sfx: AudioStreamPlayer = $"../../../../../../../SFX"
@export var typesound: AudioStream
@export var stop_sound : AudioStream
@export var characters_per_second: float = 60.0
signal tween_finished

func type_text(new_text: String):
	# Stop any running tween
	
	
	text = new_text
	visible_characters = 0

	# Wait one frame so RichTextLabel calculates characters
	await get_tree().process_frame
	
	var total_chars := get_total_character_count()
	var duration := total_chars / characters_per_second
	sfx.play_loop(typesound)
	var tween = get_tree().create_tween()
	tween.tween_property(
		self,
		"visible_characters",
		total_chars,
		duration
	).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT)
	await tween.finished
	sfx.stop_loop()
	sfx.play_sfx(stop_sound)
	emit_signal("tween_finished")
