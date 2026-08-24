extends AudioStreamPlayer
var playback: AudioStreamPlaybackPolyphonic
var type_sound_id: int = AudioStreamPlaybackPolyphonic.INVALID_ID

func _ready() -> void:
	stream = AudioStreamPolyphonic.new()
	play()
	playback = get_stream_playback()

func play_sfx(stream: AudioStream) -> void:
	playback.play_stream(stream)



func play_loop(sfx_stream: AudioStream) -> void:
	type_sound_id = playback.play_stream(sfx_stream)

func stop_loop() -> void:
	if type_sound_id != AudioStreamPlaybackPolyphonic.INVALID_ID:
		playback.stop_stream(type_sound_id)
		type_sound_id = AudioStreamPlaybackPolyphonic.INVALID_ID
