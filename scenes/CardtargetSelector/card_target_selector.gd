extends Node2D

const MAGIC_ARC : int = 8

@onready var area_2d: Area2D = $Area2D
@onready var Ark: MagicArc = $ARK/Line2D
var current_target_enemy: EnemyView = null
var current_card : CardUI
var targeting := false
var border_tweens: Dictionary = {}

func _pulse_border(border: NinePatchRect) -> void:
	if border_tweens.has(border):
		border_tweens[border].kill()
	await border.get_tree().process_frame
	border.pivot_offset = border.size * 0.5
	var tween := create_tween().set_loops()
	tween.set_parallel(true)
	tween.tween_property(border, "scale", Vector2(1.06, 1.06), 0.4)\
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(border, "self_modulate", Color(1.4, 1.249, 0.0, 1.0), 0.4)\
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.chain()
	tween.tween_property(border, "scale", Vector2.ONE, 0.4)\
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(border, "self_modulate", Color(1.0, 0.422, 0.0, 1.0), 0.4)\
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	border_tweens[border] = tween

func _clear_border(border: NinePatchRect) -> void:
	if border_tweens.has(border):
		border_tweens[border].kill()
		border_tweens.erase(border)
	border.scale = Vector2.ONE
	border.self_modulate = Color.WHITE
	border.visible = false

func _ready() -> void:
	Events.card_aim_started.connect(_on_card_aim_started)
	Events.card_aim_finished.connect(_on_card_aim_ended)

func _process(_delta: float) -> void:
	if not targeting:
		return
	area_2d.position = get_local_mouse_position()
	Ark.points = _get_points()
	Ark.emit_along_arc()

func _get_points() -> PackedVector2Array:
	var points := PackedVector2Array()
	var start := to_local(current_card.global_position + current_card.size * current_card.scale * 0.5)
	var target := get_local_mouse_position()
	var distance := (target - start)
	for i in range(MAGIC_ARC):
		var t := (1.0 / MAGIC_ARC) * i
		var x := start.x + (distance.x / MAGIC_ARC) * i
		var y := start.y + ease_out_cubic(t) * -60 + distance.y * t
		points.append(Vector2(x, y))
	points.append(target)
	return points

func ease_out_cubic(number: float) -> float:
	return 1.0 - pow(1.0 - number, 3.0)

func _on_card_aim_started(card: CardUI) -> void:
	if not card.card_data.is_SingleTarget():
		return
	targeting = true
	area_2d.monitoring = true
	area_2d.monitorable = true
	current_card = card
	Ark.set_idle()

func _on_card_aim_ended(_card: CardUI) -> void:
	targeting = false
	Ark.clear_points()
	Ark.reset()
	area_2d.position = Vector2.ZERO
	area_2d.monitoring = false
	area_2d.monitorable = false
	current_card = null
	if current_target_enemy and current_target_enemy.border:
		current_target_enemy.border.visible = false
		_clear_border(current_target_enemy.border)
	current_target_enemy = null

func _on_area_2d_area_entered(area: Area2D) -> void:
	if not current_card or not targeting:
		return
	if not current_card.is_ancestor_of(area):
		current_card.targets.append(area)
		Ark.set_targeted()
		var target_enemy := area as EnemyView
		if target_enemy:
			current_target_enemy = target_enemy
			if target_enemy.border:
				target_enemy.border.visible = true
				_pulse_border(target_enemy.border)

func _on_area_2d_area_exited(area: Area2D) -> void:
	if not current_card or not targeting:
		return
	current_card.targets.erase(area)
	Ark.set_idle()
	var target_enemy := area as EnemyView
	if target_enemy and target_enemy.border:
		target_enemy.border.visible = false
		_clear_border(target_enemy.border)
	if current_target_enemy == target_enemy:
		current_target_enemy = null
