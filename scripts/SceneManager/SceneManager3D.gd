extends "res://scripts/SceneManager/SceneManager.gd"


const InputManager = preload("res://scripts/InputManager.gd")


func _on_SceneManager3D_input_event(_camera, event, _click_position, _click_normal, _shape_idx):
	if InputManager.pressed(event):
		new_scene()
