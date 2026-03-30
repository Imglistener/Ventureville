extends Button
@export var hover_sound : AudioStream 	= preload("uid://cnuxlqejtckb5")
@export var click_sound : AudioStream	= preload("uid://p68vnmwk5kiw")
@export var angle_x_max: float = 15.0
@export var angle_y_max: float = 15.0
@export var max_offset_shadow: float = 50.0
@export var hover_offset: Vector2 = Vector2(-20.0, -30.0)

@export var destroy_duration: float = 0.4
@export var destroy_scale_target: float = 0.8
@export var destroy_fade_target: float = 0.0
@export var card_data : Player_Action_instance

var base_position: Vector2 = Vector2.ZERO
var tween_rot: Tween
var tween_hover: Tween
var tween_destroy: Tween
var is_destroying: bool = false  # Prevent multiple destroy calls

@onready var card_texture: TextureRect = $CardTexture
@onready var shadow = $Shadow
@onready var collision_shape: CollisionShape2D = $DestroyArea/CollisionShape2D
@onready var sfx: AudioStreamPlayer2D = $SFX

signal card_clicked()

func _ready() -> void:
	angle_x_max = deg_to_rad(angle_x_max)
	angle_y_max = deg_to_rad(angle_y_max)
	collision_shape.set_deferred("disabled", true)
	card_data.initialize_move(self)
	if card_texture.material:
		card_texture.material = card_texture.material.duplicate()
	await get_tree().process_frame
	base_position = position
	
	

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed():
		_on_card_clicked()
		return

	if not event is InputEventMouseMotion:
		return

	var mouse_pos: Vector2 = get_local_mouse_position()
	var lerp_val_x: float = remap(mouse_pos.x, 0.0, size.x, 0.0, 1.0)
	var lerp_val_y: float = remap(mouse_pos.y, 0.0, size.y, 0.0, 1.0)
	var rot_x: float = rad_to_deg(lerp_angle(-angle_x_max, angle_x_max, lerp_val_x))
	var rot_y: float = rad_to_deg(lerp_angle(angle_y_max, -angle_y_max, lerp_val_y))
	if card_texture.material:
		card_texture.material.set_shader_parameter("x_rot", rot_y)
		card_texture.material.set_shader_parameter("y_rot", rot_x)

func _on_mouse_entered() -> void:
	if is_destroying: return
	if tween_hover and tween_hover.is_running():
		tween_hover.kill()
	base_position = position
	z_index = 10
	tween_hover = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	tween_hover.tween_property(self, "scale", Vector2(1.2, 1.2), 0.2)
	tween_hover.parallel().tween_property(self, "position", base_position + hover_offset, 0.2)
	if sfx and hover_sound:
		sfx.stream = hover_sound
		sfx.play()
func _on_mouse_exited() -> void:
	if is_destroying: return
	if tween_rot and tween_rot.is_running():
		tween_rot.kill()
	tween_rot = create_tween().set_parallel(true).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	if card_texture.material:
		tween_rot.tween_property(card_texture.material, "shader_parameter/x_rot", 0.0, 0.2)
		tween_rot.tween_property(card_texture.material, "shader_parameter/y_rot", 0.0, 0.2)
	if tween_hover and tween_hover.is_running():
		tween_hover.kill()
	z_index = 0
	tween_hover = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	tween_hover.tween_property(self, "scale", Vector2.ONE, 0.2)
	tween_hover.parallel().tween_property(self, "position", base_position, 0.2)

func _on_card_clicked() -> void:
	if is_destroying:
		return
	is_destroying = true
	if sfx and click_sound:
		sfx.stream = click_sound
		sfx.play()
	# Disable future interactions
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	collision_shape.set_deferred("disabled", true)
	# Kill any ongoing tweens
	if tween_hover and tween_hover.is_running():
		tween_hover.kill()
	if tween_rot and tween_rot.is_running():
		tween_rot.kill()
	emit_signal("card_clicked" , card_data)
	# Reset visual state (prevent glitches)
	scale = Vector2.ONE
	rotation = 0.0
	z_index = 0
	if card_texture.material:
		card_texture.material.set_shader_parameter("x_rot", 0.0)
		card_texture.material.set_shader_parameter("y_rot", 0.0)

	# Record current global position (before reparenting)
	var saved_global_pos = global_position

	# Remove card from the container immediately so the layout updates
	var new_parent = get_tree().current_scene
	reparent(new_parent, true)  # keep_world_transform = true

	# Restore global position (reparenting may have changed it)
	global_position = saved_global_pos

	# Bring to front during animation
	z_index = 100

	# Start disappearance animation
	_start_destroy_animation()
	
	

func _start_destroy_animation() -> void:
	if tween_destroy and tween_destroy.is_running():
		tween_destroy.kill()

	# Store starting position
	var start_pos = global_position

	# Rise higher (40 pixels up) and slide slightly to the left (5 pixels)
	# This gives the impression of lifting out of a horizontal stack.
	var fly_offset = Vector2(-5, -40)

	tween_destroy = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	tween_destroy.set_parallel(true)

	# Fade out shadow a bit faster
	tween_destroy.tween_property(shadow, "self_modulate:a", 0.0, destroy_duration * 0.6)

	# Scale and fade the card
	tween_destroy.tween_property(self, "scale", Vector2(destroy_scale_target, destroy_scale_target), destroy_duration)
	tween_destroy.tween_property(self, "modulate:a", destroy_fade_target, destroy_duration)

	# Move the card upward and slightly sideways
	tween_destroy.tween_property(self, "global_position", start_pos + fly_offset, destroy_duration)

	# Optional dissolve shader effect
	var material = card_texture.material
	if material is ShaderMaterial and material.get_shader_parameter("dissolve_value") != null:
		tween_destroy.tween_property(material, "shader_parameter/dissolve_value", 1.0, destroy_duration).from(0.0)

	# After the tween, free the card
	tween_destroy.finished.connect(_on_destroy_finished, CONNECT_ONE_SHOT)
func _on_destroy_finished() -> void:
	queue_free()

func _process(delta: float) -> void:
	_update_shadow()

func _update_shadow() -> void:
	var center: Vector2 = get_viewport_rect().size / 2.0
	var distance: float = global_position.x - center.x
	var amount: float = clamp(abs(distance / max(center.x, 1.0)), 0.0, 1.0)
	shadow.position.x = lerp(0.0, -sign(distance) * max_offset_shadow, amount)
