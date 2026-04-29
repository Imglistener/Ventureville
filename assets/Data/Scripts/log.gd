class_name Log extends RichTextLabel

func connect_to_entity(entity: BaseBattlerStats) -> void:
	if entity.damage_taken.is_connected(_on_damage_taken):
		return
	entity.damage_taken.connect(_on_damage_taken)
	entity.sanity_damage_taken.connect(_on_sanity_damage_taken)
	entity.health_restored.connect(_on_health_restored)
	entity.sanity_restored.connect(_on_sanity_restored)
	entity.block_gained.connect(_on_block_gained)
	entity.san_block_gained.connect(_on_san_block_gained)
	entity.entity_died.connect(_on_entity_died)

func disconnect_from_entity(entity: BaseBattlerStats) -> void:
	entity.damage_taken.disconnect(_on_damage_taken)
	entity.sanity_damage_taken.disconnect(_on_sanity_damage_taken)
	entity.health_restored.disconnect(_on_health_restored)
	entity.sanity_restored.disconnect(_on_sanity_restored)
	entity.block_gained.disconnect(_on_block_gained)
	entity.san_block_gained.disconnect(_on_san_block_gained)
	entity.entity_died.disconnect(_on_entity_died)
func _log(message: String) -> void:
	text += (message + "[br]")
	parse_bbcode(text)
	

func _on_damage_taken(amount: int, entity_name: String) -> void:
	_log("[br]%s took [color=red]%d[/color] damage." % [entity_name, amount])

func _on_sanity_damage_taken(amount: int, entity_name: String) -> void:
	_log("[br]%s lost [color=purple]%d[/color] sanity." % [entity_name, amount])

func _on_health_restored(amount: int, entity_name: String) -> void:
	_log("[br]%s restored [color=green]%d[/color] HP." % [entity_name, amount])

func _on_sanity_restored(amount: int, entity_name: String) -> void:
	_log("[br]%s restored [color=purple]%d[/color] sanity." % [entity_name, amount])

func _on_block_gained(amount: int, entity_name: String) -> void:
	_log("[br]%s gained [color=cyan]%d[/color] block." % [entity_name, amount])

func _on_san_block_gained(amount: int, entity_name: String) -> void:
	_log("[br]%s gained [color=purple]%d[/color] sanity block." % [entity_name, amount])

func _on_entity_died(entity_name: String) -> void:
	_log("[br]%s has been defeated." % entity_name)
