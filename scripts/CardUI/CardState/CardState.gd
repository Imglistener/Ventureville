class_name CardState extends Node

enum State{IDLING, HOVERING, CLICKED, DRAGGING, TARGETING, RELEASED}

signal TransitionRequest(From: CardState, to: State)

@export var state: State

var card_UI : CardUI

func process(_delta: float) -> void:
	pass

func enter() -> void:
	pass
	
func exit() -> void:
	pass

func on_gui_input(_event: InputEvent) -> void:
	pass

func on_input(_event: InputEvent) -> void:
	pass

func mouse_entered()-> void:
	pass
	
func mouse_exited()-> void:
	pass
