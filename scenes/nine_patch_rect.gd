extends Node
var activemenu = null
var index: int = 1
@onready var menus : Array = get_children()
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

func getactivemenu() -> void:
	for menu in menus:
		if menu.is_visible():
			activemenu = menu
			
func transition(target: Node , menus: Array = menus) -> void:
	if target in menus:
		index = target.get_index()
	else: 
		return
	activemenu.visible = false
	activemenu = menus[index]
	activemenu.visible = true
	
			
func _process(delta: float) -> void:
		getactivemenu()
		if Input.is_action_just_pressed("esc"):
			transition(%ActionsMenu)



	


func _on_buttonhandlesystem_button_press(button: BaseButton) -> void:
	match button.name:
		"Battle":
			transition(%Battleactions)
