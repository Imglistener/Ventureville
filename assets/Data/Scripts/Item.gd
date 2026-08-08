class_name Item extends Resource

@export var item_name : String = "SAMPLE"
@export_multiline var item_description: String = "SAMPLE DESCRIPTION"
@export var item_effect : Resource
@export var item_type : ITEM_TYPES
@export var item_icon : Texture2D
enum ITEM_TYPES{IsConsumableItem, IsQuestItem, IsKeyItem}

func use_item() -> void:
	pass

func is_item_usable() -> bool:
	return false
	
