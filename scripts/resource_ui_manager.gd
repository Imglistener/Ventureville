class_name UI_Manager extends Node
@onready var AP_bar: TextureProgressBar = $"../../Control_Layer/Control_Base/AP_Background/AP_Bar"
@onready var MP_UI: Mana_UI = $"../../Control_Layer/Control_Base/Mana_UI"
@onready var Resource_manager: resource_manager = $"../ResourceManager"
@onready var player_stat_manager: Stat_Manager = $"../PlayerStatManager"


func _ready() -> void:
	await get_tree().process_frame
	reset_bars_UI()
	if not Events.card_played.is_connected(update_bars_UI):
		Events.card_played.connect(update_bars_UI.unbind(1))
	Events.PlayerStandbyStart.connect(update_bars_UI.unbind(1))
	Events.item_used.connect(update_bars_UI.unbind(1))


func reset_bars_UI() -> void:
	AP_bar.max_value 	= player_stat_manager.Player.AP
	AP_bar.value		= player_stat_manager.Player.AP
	MP_UI.MP_Label.text = str(player_stat_manager.Player.max_mana)

func update_bars_UI() -> void:
	await get_tree().process_frame
	if AP_bar.value != player_stat_manager.Player.AP:
		AP_bar.change_value(player_stat_manager.Player.AP)
	if MP_UI.MP_Label.text != str(player_stat_manager.Player.mana):
		MP_UI.MP_Label.text = str(player_stat_manager.Player.mana)
