class_name TripleBiteVFX
extends Node2D
@onready var fire_bite_vfx_1: AnimatedSprite2D = $FireBiteVFX
@onready var fire_bite_vfx_2: AnimatedSprite2D = $FireBiteVFX2
@onready var fire_bite_vfx_3: AnimatedSprite2D = $FireBiteVFX3


func play_bites() -> void:
	fire_bite_vfx_1.show()
	fire_bite_vfx_1.play('firefang')
	fire_bite_vfx_1.animation_finished.connect(func(): fire_bite_vfx_1.queue_free())
	await get_tree().create_timer(0.60-0.13).timeout
	fire_bite_vfx_2.show()
	fire_bite_vfx_2.play('firefang')
	fire_bite_vfx_2.animation_finished.connect(func(): fire_bite_vfx_2.queue_free())
	await get_tree().create_timer(1.17-0.60).timeout
	fire_bite_vfx_3.show()
	fire_bite_vfx_3.play('firefang')
	await fire_bite_vfx_3.animation_finished
	queue_free()
