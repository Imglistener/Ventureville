extends TextureButton
@onready var enemy_name_margin: MarginContainer = $"../EnemyNameMargin"
var t : Tween
func _ready() -> void:
	await get_tree().process_frame
	pivot_offset.x = size.x/2
	pivot_offset.y = size.y/2
	texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	set_meta("_edit_use_anchors_", false)

func reveal_name() -> void:
	if disabled:
		return
	if t:
		if t.is_running():
			t.kill()
	t = create_tween().set_parallel(true)
	t.tween_property(enemy_name_margin, 'position', Vector2(0.0 , 265.0), 0.2).set_ease(Tween.EASE_IN)
	t.tween_property(enemy_name_margin, 'modulate', Color(1.0, 1.0, 1.0, 1.0), 0.2).set_ease(Tween.EASE_IN_OUT)
	await t.finished

func hide_name() -> void:
	if disabled:
		return
	if t:
		if t.is_running():
			t.kill()
	t = create_tween().set_parallel(true)
	t.tween_property(enemy_name_margin, 'position', Vector2(0.0 , 215.0), 0.2).set_ease(Tween.EASE_IN)
	t.tween_property(enemy_name_margin, 'modulate', Color(1.0, 1.0, 1.0, 0.0), 0.2).set_ease(Tween.EASE_IN_OUT)
	await t.finished
