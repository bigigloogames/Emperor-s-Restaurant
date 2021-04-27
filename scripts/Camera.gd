extends Camera

const ray_length = 1000
const min_size = 1
const max_size = 20
const min_y = -40
const max_y = -20

func get_clicked_position(event):
	var from = project_ray_origin(event.position)
	var to = from + project_ray_normal(event.position) * ray_length
	var space_state = get_world().direct_space_state
	return space_state.intersect_ray(from, to, [], 1)


func zoom_out():
	if size < max_size:
		size += 0.25


func zoom_in():
	if size > min_size:
		size -= 0.25

func pan_up():
	if translation.y < max_y:
		translation.y += 1

func pan_down():
	if translation.y > min_y:
		translation.y -= 1
