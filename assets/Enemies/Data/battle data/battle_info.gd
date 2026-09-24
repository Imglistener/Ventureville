class_name BattleInfo extends Resource

@export var battle_id : int
@export var enemies_involved : Array[EnemyBattlerStats]
@export var is_unique_battle : bool
@export var is_boss_battle : bool
@export_category('Dialogue')
@export var unique_dialogue : Array[DialogueLine]
@export var basic_dialogue_1: Array[DialogueLine]
@export var basic_dialogue_2: Array[DialogueLine]
@export var battle_music : AudioStream = preload("res://assets/SFX/AliceBattleMusic (5).ogg")

func calculate_xp() -> int: 
	var total := 0
	for enemy in enemies_involved:
		match enemy.Difficulty:
			EnemyBattlerStats.DC.BASIC:
				total += 50
			EnemyBattlerStats.DC.ELITE:
				total += 100
			EnemyBattlerStats.DC.BOSS:
				total += 200
			EnemyBattlerStats.DC.OVERLORD:
				total += 500
	return total

func get_dialogue(enemy_number: int) -> Array[DialogueLine]:
	if is_unique_battle and enemies_involved.size() == 1:
		return enemies_involved[0].Dialogue
	if is_unique_battle and enemies_involved.size() != 1:
		return unique_dialogue
	elif not is_unique_battle and enemy_number > 1:
		return basic_dialogue_2
	else:
		return basic_dialogue_1
