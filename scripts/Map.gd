extends Node


func update_Destination(destination):
	$GUI/Destination.text = "Destination: " + destination


func _on_Restaurant_input_event(_camera, event, _click_position, _click_normal, _shape_idx):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT and event.pressed:
				update_Destination("Restaurant")


func _on_Fishing_input_event(_camera, event, _click_position, _click_normal, _shape_idx):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT and event.pressed:
				update_Destination("Fishing")


func _on_Foraging_input_event(_camera, event, _click_position, _click_normal, _shape_idx):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT and event.pressed:
				update_Destination("Foraging")
