extends TextureRect
class_name TiltCard

# Maximum tilt angles
@export var angle_x_max: float = 15.0
@export var angle_y_max: float = 15.0

# Whether the card is currently being dragged
var following_mouse: bool = false

# Reference to the card texture (TextureRect itself has the texture)
@onready var card_texture: TextureRect = self

func _ready() -> void:
	# Ensure the TextureRect has a ShaderMaterial
	if not card_texture.material:
		var shader := Shader.new()
		shader.code = """
			shader_type canvas_item;

			uniform float x_rot : hint_range(-90,90);
			uniform float y_rot : hint_range(-90,90);

			void fragment() {
				COLOR = texture(TEXTURE, UV);
			}
		"""
		var mat := ShaderMaterial.new()
		mat.shader = shader
		card_texture.material = mat

func _gui_input(event: InputEvent) -> void:
	handle_mouse_click(event)

	# Don't compute rotation if the card is being dragged
	if following_mouse:
		return
	if not event is InputEventMouseMotion:
		return

	# Get local mouse position relative to the TextureRect
	var mouse_pos: Vector2 = get_local_mouse_position()

	# Convert to 0..1 range
	var lerp_val_x: float = remap(mouse_pos.x, 0.0, size.x, 0.0, 1.0)
	var lerp_val_y: float = remap(mouse_pos.y, 0.0, size.y, 0.0, 1.0)

	# Lerp angles
	var rot_x: float = lerp_angle(-deg_to_rad(angle_x_max), deg_to_rad(angle_x_max), lerp_val_x)
	var rot_y: float = lerp_angle(deg_to_rad(angle_y_max), -deg_to_rad(angle_y_max), lerp_val_y)

	# Apply rotation to shader (convert to degrees)
	card_texture.material.set_shader_parameter("x_rot", rad_to_deg(rot_y))
	card_texture.material.set_shader_parameter("y_rot", rad_to_deg(rot_x))

func handle_mouse_click(event: InputEvent) -> void:
	# Example: start/stop dragging
	if event is InputEventMouseButton and event.pressed:
		following_mouse = true
	elif event is InputEventMouseButton and not event.pressed:
		following_mouse = false

func remap(value: float, from_min: float, from_max: float, to_min: float, to_max: float) -> float:
	# Linearly remaps value from one range to another
	return to_min + (value - from_min) * (to_max - to_min) / (from_max - from_min)
