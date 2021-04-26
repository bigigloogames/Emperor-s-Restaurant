extends Camera

const ray_length = 1000
var build_mode = false

func _input(event):
	if event is InputEventMouseButton and event.pressed and event.button_index == 1:
		var from = project_ray_origin(event.position)
		var to = from + project_ray_normal(event.position) * ray_length
		var space_state = get_world().direct_space_state
		var result = space_state.intersect_ray(from, to, [], 1)
		if result:
			if build_mode:
				get_parent().get_parent().place_item(result.position)
			else:
				get_tree().call_group("units", "move_to_via_click", result.position)
		


func _on_BuildMode_toggled(_button_pressed):
	build_mode = !build_mode
	get_parent().get_parent().get_node("Control/ItemList").visible = build_mode
