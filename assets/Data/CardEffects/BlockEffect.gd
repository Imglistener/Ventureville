class_name BlockEffect extends CardEffect


var Effect:	PackedScene = preload("res://assets/Data/NewScenes/block_visual_effect.tscn")
var amount : int

func activate(targets : Array[Node]) -> void:
	for target in targets:
		if not target:
			continue
		if target is EnemyView:
			target.Enemy.Entity.current_block += amount
			target.Enemy.Entity.block_gained.emit(amount, target.Enemy.Entity.entity_name)
			var appliedEffect = Effect.instantiate()
			target.add_child(appliedEffect)
			if not appliedEffect.is_node_ready():
				await appliedEffect.ready
			appliedEffect.play_animation()
			
			
		if target is Stat_Manager:
			var appliedEffect = Effect.instantiate() as VisualEffect
			target.player_view.add_child(appliedEffect)
			appliedEffect.position = target.player_view.position + Vector2(130, 180)
			if not appliedEffect.is_node_ready():
				await appliedEffect.ready
			appliedEffect.play_animation()
			
			target.Player.current_block += amount
			target.Player.block_gained.emit(amount, target.Player.entity_name)
			
			
