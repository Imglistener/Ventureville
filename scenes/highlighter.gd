extends TextureRect
const Offset : Vector2 =  Vector2(25, 14)

var target : Node = null

func _ready() -> void:
	get_viewport().gui_focus_changed.connect(_on_viewpoert_gui_focuschanged)
	set_process(false)


func _on_viewpoert_gui_focuschanged(node: Control) -> void:
	if node is BaseButton:
		target = node
		show()
		set_process(true)
	else:
		hide()
		set_process(false)
	if target.is_hovered():
		hide()
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	global_position = target.global_position + Offset
