class_name StatusEffect extends Resource

enum StatusEffects{Burning, Frostbite, BloodSyphon, Horrified, Concussed, Stunned, Withering, DamageUp, Regeneration, DefensePerTurn, RetainHand, Poison, SanguineShell, DamageDown, BloodDebt}
var current_duration : int = 0

@export var status_name : StatusEffects
@export var default_duration : int
@export var status_icon : Texture
@export var effect_texture: Texture2D
@export_multiline var status_description: String


func _get_entity(target: Node) -> BaseBattlerStats:
	if target is EnemyView:
		return target.Enemy.Entity
	if target is Stat_Manager:
		return target.Player
	return null
func _get_anchor(target: Node) -> Node2D:
	if target is EnemyView:
		return target.effect_vfx_marker
	if target is Stat_Manager:
		return target.player_view.effect_guide
	return null
func on_apply(_targets: Array[Node], duration : int = 1) -> void:
	pass

func on_activate() -> void:
	pass

func on_tick(_target: BaseBattlerStats) -> void:
	pass

func on_remove(_target: BaseBattlerStats) -> void:
	var existing = find_same_effect(_target.ActiveEffects)
	if existing:
		_target.ActiveEffects.erase(existing)
		Events.StatusWoreOff.emit(self, _target)
		
func is_applicable(targets: Array[Node]) -> bool:
	return false

func find_same_effect(effects: Array) -> StatusEffect:
	for effect in effects:
		if effect.get_script() == self.get_script():
			return effect
	return null
