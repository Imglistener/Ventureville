class_name StatusVisualPlay
extends RefCounted

var statusVFX := preload("uid://b6w0xgmjfbqlj") as PackedScene
var icon: Texture2D

func activate(target: Node2D, offset: Vector2 = Vector2.ZERO) -> void:
	if not target:
		return
	var VFX_scene = statusVFX.instantiate() as StatusConditionVFX
	VFX_scene.set_displayed_icon(icon)
	target.add_child(VFX_scene)
	VFX_scene.position += offset
	VFX_scene.play_and_free()
