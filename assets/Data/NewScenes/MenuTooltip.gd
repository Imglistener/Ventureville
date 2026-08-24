extends VBoxContainer

@onready var menu: VBoxContainer = $"../Menu"
var _tweens: Array[Tween] = []

func _ready() -> void:
	for child in get_children():
		if child is CanvasItem and child.material:
			child.modulate.a = 0.0
			child.material = child.material.duplicate()
	_tweens.resize(get_child_count())
	connect_signals()
func connect_signals() -> void:
	var menu_children := menu.get_children()
	for i in menu_children.size():
		var child := menu_children[i]
		if child is Control:
			child.mouse_entered.connect(slide_in.bind(i))
			child.mouse_exited.connect(slide_out.bind(i))

func slide_in(i: int) -> void:
	if _tweens[i]:
		_tweens[i].kill()
	var tween := create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO)
	tween.tween_property(get_children()[i], "material:shader_parameter/offset_x", 0.0, 0.35)
	tween.parallel().tween_property(get_children()[i], "modulate:a", 1.0, 0.2)
	_tweens[i] = tween

func slide_out(i: int) -> void:
	if _tweens[i]:
		_tweens[i].kill()
	var tween := create_tween().set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_EXPO)
	tween.tween_property(get_children()[i], "material:shader_parameter/offset_x", -300.0, 0.2)
	tween.parallel().tween_property(get_children()[i], "modulate:a", 0.0, 0.15)
	_tweens[i] = tween
