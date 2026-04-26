class_name MagicArc extends Line2D

@export var speed: float
@export var particles: GPUParticles2D
@export var spacing: float = 20.0
@export var emission_chance: float = 0.3
@export var jitter: float = 3.0

var current_color: Color = Color.WHITE
var _targeted: bool = false

func emit_along_arc() -> void:
	if not particles or points.size() < 2:
		return
	for i in range(points.size() - 1):
		var a: Vector2 = to_global(points[i])
		var b: Vector2 = to_global(points[i + 1])
		var steps := int(a.distance_to(b) / spacing)
		if steps == 0:
			continue
		for j in range(steps):
			if randf() > emission_chance:
				continue
			var t := float(j) / steps
			var visibility := pow(t, 2.0)
			if randf() > visibility:
				continue
			var global_pos := a.lerp(b, t) + Vector2(
				randf_range(-jitter, jitter),
				randf_range(-jitter, jitter)
			)
			var pos := particles.to_local(global_pos)
			particles.emit_particle(
				Transform2D(0, pos),
				Vector2.ZERO,
				Color(1, 1, 1, visibility),
				Color(1, 1, 1, 0),
				GPUParticles2D.EMIT_FLAG_POSITION | GPUParticles2D.EMIT_FLAG_COLOR
			)

func set_idle() -> void:
	_targeted = false

func set_targeted() -> void:
	_targeted = true
	current_color = Color(1.0, 0.15, 0.15, 1.0)

func reset() -> void:
	_targeted = false
	current_color = Color.WHITE

func _ready() -> void:
	texture_mode = Line2D.LINE_TEXTURE_TILE

func _process(_delta: float) -> void:
	if not _targeted:
		var t := (sin(Time.get_ticks_msec() * 0.002) + 1.0) * 0.5
		current_color = Color.GRAY.lerp(Color(1.0, 0.563, 0.0, 1.0), t)

	var mat := particles.process_material as ParticleProcessMaterial
	if mat:
		mat.color = current_color
