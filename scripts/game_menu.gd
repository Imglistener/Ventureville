@tool
class_name ExpandingHBoxContainer extends Container

enum Direction { LEFT_TO_RIGHT, RIGHT_TO_LEFT }

@export var direction: Direction = Direction.LEFT_TO_RIGHT:
	set(value):
		direction = value
		queue_sort()

@export var min_gap: float = 4.0:
	set(value):
		min_gap = max(0.0, value)
		queue_sort()

@export var gap_growth: float = 8.0:
	set(value):
		gap_growth = max(0.0, value)
		queue_sort()


func _get_gap(index: int) -> float:
	return min_gap + (gap_growth * index)


func _notification(what: int) -> void:
	if what == NOTIFICATION_SORT_CHILDREN:
		_arrange_children()


func _arrange_children() -> void:
	var children: Array[Node] = get_children().filter(func(c): return c is Control and c.visible)

	if direction == Direction.RIGHT_TO_LEFT:
		children.reverse()

	var x_cursor: float = 0.0

	for i in children.size():
		var child := children[i] as Control
		var child_size := child.get_combined_minimum_size()

		fit_child_in_rect(child, Rect2(
			Vector2(x_cursor, 0.0),
			Vector2(child_size.x, size.y)
		))

		x_cursor += child_size.x
		if i < children.size() - 1:
			x_cursor += _get_gap(i)


func _get_minimum_size() -> Vector2:
	var children: Array[Node] = get_children().filter(func(c): return c is Control and c.visible)
	var total_width: float = 0.0
	var max_height: float = 0.0

	for i in children.size():
		var child := children[i] as Control
		var child_min := child.get_combined_minimum_size()
		total_width += child_min.x
		max_height = max(max_height, child_min.y)
		if i < children.size() - 1:
			total_width += _get_gap(i)

	return Vector2(total_width, max_height)
