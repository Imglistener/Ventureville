class_name EnemyViewContainer2D
extends Node2D

@export var enemy_view_scene: PackedScene
var assigned_views: Array[EnemyView] = []

# Slot node indices per enemy count (child indices of this container)
const SLOTS := {
	1: [0],
	2: [1, 2],
	3: [0, 1, 2], # adjust to your layout
}

func build_enemy_views(count: int) -> Array[EnemyView]:
	assigned_views.clear()
	if not SLOTS.has(count):
		push_warning("Unsupported enemy count: %d" % count)
		return assigned_views

	for slot_idx in SLOTS[count]:
		var view := enemy_view_scene.instantiate() as EnemyView
		view.process_mode = Node.PROCESS_MODE_DISABLED
		get_child(slot_idx).add_child(view)
		assigned_views.append(view)
	return assigned_views
