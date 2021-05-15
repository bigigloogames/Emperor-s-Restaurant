extends "res://scripts/SceneManager/SceneManager.gd"


func _on_SceneManager3D_input_event(_camera, event, _click_position, _click_normal, _shape_idx):
	if event is InputEventMouseButton and event.pressed:
		new_scene()
