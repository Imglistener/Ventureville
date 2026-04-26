extends ColorRect
func apply_shimmer(rect: ColorRect, speed: float = 2.0, scale_strength: float = 0.0, alpha_strength: float = 0.1) -> void:
	var t := Time.get_ticks_msec() / 1000.0 * speed
	
	# Smooth oscillation using sine
	var wave := sin(t)
	
	# Scale shimmer (small variation)
	var scale_offset := 1.0 + wave * scale_strength
	rect.scale = Vector2(scale_offset, scale_offset)
	
	# Alpha shimmer (slight fade in/out)
	var base_alpha := 1.0
	rect.modulate.a = base_alpha + wave * alpha_strength
	
func _process(_delta: float) -> void:
	apply_shimmer(self)
