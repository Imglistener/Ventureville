class_name SettingsMenu extends PanelContainer
# --- Signals ---
signal animated_out
# --- Constants ---

const SAVE_PATH = "user://settings.cfg"

const RESOLUTIONS = [
	Vector2i(1920, 1080),
	Vector2i(1280, 720),
	Vector2i(854, 480)
]

const FRAMERATES = [30, 60, 120, 144, 240, 0]  # 0 = unlimited

const DEFAULTS = {
	"resolution": 1,    # index → 1920x1080
	"framerate": 1,     # index → 60fps
	"vsync": true,
	"fullscreen": false,
	"bgm": 1.0,
	"sfx": 1.0
}

# --- Nodes ---

@onready var player: AudioStreamPlayer = get_tree().get_first_node_in_group("SFXBus")
@export var hover_sfx: AudioStream
@export var click_sfx: AudioStream

@onready var resolutions_picker: OptionButton = $MarginContainer/HBoxContainer/VBoxContainer2/PanelContainer/HBoxContainer/ResolutionsPicker
@onready var framerate_picker: OptionButton = $"MarginContainer/HBoxContainer/VBoxContainer2/PanelContainer2/HBoxContainer/Framerate Picker"
@onready var v_sync: CheckBox = $"MarginContainer/HBoxContainer/VBoxContainer2/HBoxContainer/V-Sync"
@onready var fullscreen: CheckBox = $MarginContainer/HBoxContainer/VBoxContainer2/HBoxContainer/Fullscreen
@onready var bgm_slider: HSlider = $"MarginContainer/HBoxContainer/VBoxContainer/PanelContainer2/HBoxContainer/BGM Slider"
@onready var sfx_slider: HSlider = $"MarginContainer/HBoxContainer/VBoxContainer/PanelContainer3/HBoxContainer/SFX Slider"
@onready var reset: Button = $MarginContainer/HBoxContainer2/Reset
@onready var save: Button = $MarginContainer/HBoxContainer2/Save
@onready var return_btn: Button = $MarginContainer/Return

# --- Lifecycle ---

func _ready() -> void:
	await get_tree().process_frame
	scan_buttons(self)
	_connect_controls()
	load_settings()

func _connect_controls() -> void:
	save.pressed.connect(_on_save_pressed)
	reset.pressed.connect(_on_reset_pressed)
	# Audio sliders apply live — standard UX expectation
	bgm_slider.value_changed.connect(set_bgm_volume)
	sfx_slider.value_changed.connect(set_sfx_volume)
	return_btn.pressed.connect(_return_previous)

# --- Save / Load ---

func save_settings() -> void:
	var config = ConfigFile.new()
	config.set_value("display", "resolution", resolutions_picker.selected)
	config.set_value("display", "framerate", framerate_picker.selected)
	config.set_value("display", "vsync", v_sync.button_pressed)
	config.set_value("display", "fullscreen", fullscreen.button_pressed)
	config.set_value("audio", "bgm", bgm_slider.value)
	config.set_value("audio", "sfx", sfx_slider.value)
	config.save(SAVE_PATH)

func load_settings() -> void:
	var config = ConfigFile.new()
	if config.load(SAVE_PATH) != OK:
		apply_defaults()
		return

	resolutions_picker.selected = config.get_value("display", "resolution", DEFAULTS.resolution)
	framerate_picker.selected   = config.get_value("display", "framerate",   DEFAULTS.framerate)
	v_sync.button_pressed       = config.get_value("display", "vsync",       DEFAULTS.vsync)
	fullscreen.button_pressed   = config.get_value("display", "fullscreen",  DEFAULTS.fullscreen)
	bgm_slider.value            = config.get_value("audio",   "bgm",         DEFAULTS.bgm)
	sfx_slider.value            = config.get_value("audio",   "sfx",         DEFAULTS.sfx)

	apply_settings()

func apply_defaults() -> void:
	resolutions_picker.selected = DEFAULTS.resolution
	framerate_picker.selected   = DEFAULTS.framerate
	v_sync.button_pressed       = DEFAULTS.vsync
	fullscreen.button_pressed   = DEFAULTS.fullscreen
	bgm_slider.value            = DEFAULTS.bgm
	sfx_slider.value            = DEFAULTS.sfx
	apply_settings()

# --- Apply ---

func apply_settings() -> void:
	set_resolution(resolutions_picker.selected)
	set_framerate(framerate_picker.selected)
	set_vsync(v_sync.button_pressed)
	set_fullscreen(fullscreen.button_pressed)
	set_bgm_volume(bgm_slider.value)
	set_sfx_volume(sfx_slider.value)

# --- Display ---

func set_resolution(index: int) -> void:
	DisplayServer.window_set_size(RESOLUTIONS[index])
	var screen = DisplayServer.screen_get_size()
	var win = DisplayServer.window_get_size()
	DisplayServer.window_set_position((screen - win) / 2)

func set_framerate(index: int) -> void:
	Engine.max_fps = FRAMERATES[index]

func set_vsync(enabled: bool) -> void:
	DisplayServer.window_set_vsync_mode(
		DisplayServer.VSYNC_ENABLED if enabled else DisplayServer.VSYNC_DISABLED
	)

func set_fullscreen(enabled: bool) -> void:
	DisplayServer.window_set_mode(
		DisplayServer.WINDOW_MODE_FULLSCREEN if enabled else DisplayServer.WINDOW_MODE_WINDOWED
	)

# --- Audio ---

func set_bgm_volume(value: float) -> void:
	var idx = AudioServer.get_bus_index("BGM")
	AudioServer.set_bus_volume_db(idx, linear_to_db(value/4))

func set_sfx_volume(value: float) -> void:
	var idx = AudioServer.get_bus_index("SFX")
	AudioServer.set_bus_volume_db(idx, linear_to_db(value/4))

# --- Button Handlers ---

func _on_save_pressed() -> void:
	apply_settings()
	save_settings()

func _on_reset_pressed() -> void:
	apply_defaults()
	save_settings()

# --- SFX Scanning ---

func scan_buttons(root: Node) -> void:
	for button in root.find_children("*", "Button", true, false):
		if not button.mouse_entered.is_connected(_on_button_hover):
			button.mouse_entered.connect(_on_button_hover)
		if not button.pressed.is_connected(_on_button_click):
			button.pressed.connect(_on_button_click)
		if not button.focus_entered.is_connected(_on_button_focus):
			button.focus_entered.connect(_on_button_focus)

func _on_button_hover() -> void:
	player.play_sfx(hover_sfx)


func _on_button_click() -> void:
	player.play_sfx(click_sfx)


func _on_button_focus() -> void:
	player.play_sfx(hover_sfx)
	

func _return_previous() -> void:
	animate_out()
	
func animate_in() -> void:
	self.visible = true
	var t = create_tween().tween_property(self, "modulate", Color(1.0, 1.0, 1.0, 1.0), 0.4).set_ease(Tween.EASE_IN_OUT)
	await t.finished
func animate_out() -> void:
	var t = create_tween().tween_property(self, "global_position", global_position + Vector2(0, -900), 0.4).set_ease(Tween.EASE_IN_OUT)
	await t.finished
	self.modulate = Color(1.0, 1.0, 1.0, 0.0)
	global_position += Vector2 (0, 900)
	self.visible = false
	animated_out.emit()
