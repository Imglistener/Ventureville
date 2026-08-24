extends VBoxContainer
@export var launch_on_ready: bool = false
signal btns_exited
signal btns_entered

@onready var buttons = get_children()

func _ready() -> void:
	for button in buttons:
		if button is Control:
			(button.material as ShaderMaterial).set_shader_parameter("offset_x", -300.0)
			button.modulate.a = 0.0
	if launch_on_ready:
		await get_tree().create_timer(0.3).timeout
		slide_in()

func slide_in(on_done: Callable = func(): 	btns_entered.emit()) -> void:
	var last_tween: Tween
	for i in buttons.size():
		if not buttons[i] is Control:
			continue
		var tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO)
		tween.tween_interval(i * 0.07)
		tween.tween_property(buttons[i], "material:shader_parameter/offset_x", 0.0, 0.35)
		tween.parallel().tween_property(buttons[i], "modulate:a", 1.0, 0.2)
		last_tween = tween
	if last_tween:
		await last_tween.finished
	on_done.call()

func slide_out(on_done: Callable = func(): btns_exited.emit()) -> void:
	var last_tween: Tween
	for i in buttons.size():
		if not buttons[i] is Control:
			continue
		var tween = create_tween().set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_EXPO)
		tween.tween_interval(i * 0.05)
		tween.tween_property(buttons[i], "material:shader_parameter/offset_x", -300.0, 0.2)
		tween.parallel().tween_property(buttons[i], "modulate:a", 0.0, 0.15)
		last_tween = tween
		buttons[i].disabled = true
	if last_tween:
		await last_tween.finished
	on_done.call()
	
