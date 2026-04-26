extends Node2D

@export var line: MagicArc 
@export var particles: GPUParticles2D

@export var spacing: float = 20.0      # distance between sample points
@export var emission_chance: float = 0.3
@export var jitter: float = 3.0       



func _process(delta: float) -> void:
	if not line or not particles:
		return
	
	var points := line.points
	if points.size() < 2:

		return
	
	for i in range(points.size() - 1):
		var a: Vector2 = line.to_global(points[i])
		var b: Vector2 = line.to_global(points[i + 1])
		
		var dist := a.distance_to(b)
		var steps := int(dist / spacing)
		
		for j in range(steps):
			# Random emission to avoid synchronization
			if randf() > emission_chance:
				continue
			
			var t := float(j) / steps
			var pos := a.lerp(b, t)
			
			# Bias toward the end of the line
			var visibility := pow(t, 2.0)
			if randf() > visibility:
				continue
			
			# Add slight randomness so it doesn't look too perfect
			pos += Vector2(
				randf_range(-jitter, jitter),
				randf_range(-jitter, jitter)
			)
			
			particles.emit_particle(
				Transform2D(0, pos),
				Vector2.ZERO,
				Color(1, 1, 1, visibility),
				Color(1, 1, 1, 0),
				0
			)
