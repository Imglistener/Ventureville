class_name CardFrame extends MarginContainer
@onready var card: CardUI = $Card

func _ready() -> void:
	if not card.is_node_ready():
		await card.ready
