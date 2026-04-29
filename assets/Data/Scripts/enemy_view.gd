extends TextureButton

func _ready() -> void:
	pivot_offset.x = size.x/2
	pivot_offset.y = size.y/2
	texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	set_meta("_edit_use_anchors_", false)
