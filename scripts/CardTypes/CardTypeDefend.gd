class_name DefendCard extends Card

# Export names kept identical to the old per-card scripts so existing .tres values survive.
@export_group("Defend")
@export var BaseShield: int
@export var BaseSanShield: int
@export var VFX: PackedScene


func _init() -> void:
	type = Type.DEFEND


func _gain_block(targets: Array[Node]) -> void:
	if BaseShield > 0:
		var block := BlockEffect.new()
		block.amount = BaseShield
		block.activate(targets)
	if BaseSanShield > 0:
		var san_block := SanBlockEffect.new()
		san_block.amount = BaseSanShield
		san_block.activate(targets)

## Spawns the VFX on the player's effect guide and frees it when the animation ends.
## on_finished (optional) runs after the animation completes.
func _play_vfx(player: Stat_Manager, on_finished: Callable = Callable()) -> void:
	if not VFX:
		return
	var visual := VFX.instantiate()
	var anchor: Marker2D = player.player_view.effect_guide
	anchor.add_child(visual)
	visual.global_position = anchor.global_position
	visual.animation_player.play("BloodBarrier")
	visual.animation_player.animation_finished.connect(
		func(_anim_name: StringName) -> void:
			visual.queue_free()
			if on_finished.is_valid():
				on_finished.call()
	);
