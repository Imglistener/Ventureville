extends Label

func _on_visibilty_changed()-> void:
	if is_visible_in_tree():
		print("Node is visible in tree.")
	else:
		print("Node not visible in tree.")
