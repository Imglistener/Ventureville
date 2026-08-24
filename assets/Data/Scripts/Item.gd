class_name Item extends Resource

@export var item_name : String = "SAMPLE"
@export_multiline var item_description: String = "SAMPLE DESCRIPTION"
@export var item_effect : ItemEffect
@export var item_type : ITEM_TYPES
@export var item_icon : Texture2D
@export var item_cost: int = 1
enum ITEM_TYPES{IsConsumableItem, IsQuestItem, IsKeyItem}
