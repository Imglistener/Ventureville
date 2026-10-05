class_name CardDisplayScreen
extends Control

@export var card_displayed : Card
var card_scene : PackedScene = preload("res://assets/Data/NewScenes/Cards/card.tscn")
@export var player_data : CharacterInstance
@onready var main_margin: MarginContainer = $MarginContainer/Background/MainMargin

func _ready() -> void:
	display_card()

func display_card() -> void:
	var card_scene_instance : CardUI = card_scene.instantiate()
	card_scene_instance.card_data = card_displayed
	card_scene_instance.Mode = CardUI.CardMode.DISPLAYING
	card_scene_instance.is_displaying = true
	card_scene_instance.player_stats = player_data
	main_margin.add_child(card_scene_instance)
	card_scene_instance.update_description()
	card_scene_instance.set_display_size(Vector2(580.0/2 + 100, 580.0))
	card_scene_instance.size_flags_horizontal = Control.SIZE_SHRINK_CENTER

func erase_self() -> void:
	var t : Tween = create_tween()
	t.set_parallel().tween_property(self, 'modulate', Color(0.0, 0.0, 0.0, 0.0), 0.2).set_ease(Tween.EASE_OUT)
	await t.finished
	queue_free()
