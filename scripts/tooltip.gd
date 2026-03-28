extends RichTextLabel

var description : String
var hover_timer := 0.0
var hover_delay := 0.5

var is_hovering := false
var current_text := ""

func _ready():
	visible = false
	
func _process(delta):
	global_position = get_global_mouse_position() + Vector2(12, 12)

	if is_hovering:
		hover_timer += delta
		if hover_timer >= hover_delay:
			text = current_text
			visible = true

func start_hover(description: String):
	current_text = description
	hover_timer = 0.0
	is_hovering = true
	visible = false

func stop_hover():
	is_hovering = false
	visible = false
