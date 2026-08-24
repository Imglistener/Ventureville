class_name EnemyManager extends Node

var _enemy_views: Array[Node] = []
var _view_to_stat_manager: Dictionary = {}

signal enemy_registered(view: EnemyView, stat_manager: Stat_Manager)
signal enemy_unregistered(view: EnemyView, stat_manager: Stat_Manager)




func register(view: EnemyView, stat_manager: Stat_Manager) -> void:
	if view in _enemy_views:
		return
	_enemy_views.append(view)
	_view_to_stat_manager[view] = stat_manager
	enemy_registered.emit(view, stat_manager)


func unregister(view: EnemyView) -> void:
	if view not in _enemy_views:
		return
	var stat_manager: Stat_Manager = _view_to_stat_manager.get(view)
	_enemy_views.erase(view)
	_view_to_stat_manager.erase(view)
	enemy_unregistered.emit(view, stat_manager)


func get_enemy_views() -> Array[Node]:
	return _enemy_views.duplicate()


func get_stat_manager_for(view: EnemyView) -> Stat_Manager:
	return _view_to_stat_manager.get(view)


func get_view_for(stat_manager: Stat_Manager) -> EnemyView:
	for view in _view_to_stat_manager:
		if _view_to_stat_manager[view] == stat_manager:
			return view
	return null


# NEW: lets a listener that connects late catch up on registrations it missed
func connect_and_catch_up(callable: Callable) -> void:
	if not enemy_registered.is_connected(callable):
		enemy_registered.connect(callable)
	for view in _enemy_views:
		callable.call(view, _view_to_stat_manager[view])
