class_name DialogueLine extends Resource
enum SPEAKER{PLAYER, ENEMY, NONE, UNKNOWN}

@export_group("Dialogue Properties")
@export var Speaker : SPEAKER
@export_multiline var Line	: String
