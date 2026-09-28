@tool
extends EditorScript

func _run():
	var card_uid := "uid://cpy8tjlulsna2"  # Card.gd's uid
	var dir_paths := ["res://assets/Data/Player/PlayerActions/BloodMagusActions/"]  # add other folders as needed

	for dir_path in dir_paths:
		var dir := DirAccess.open(dir_path)
		if not dir:
			continue
		dir.list_dir_begin()
		var file_name := dir.get_next()
		while file_name != "":
			if file_name.ends_with(".tres"):
				var full_path = dir_path + file_name
				var res := ResourceLoader.load(full_path)
				if res is Card:
					res.set_meta("_custom_type_script", card_uid)
					ResourceSaver.save(res, full_path)
					print("Fixed: ", full_path)
			file_name = dir.get_next()
		dir.list_dir_begin()
