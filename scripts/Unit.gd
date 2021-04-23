extends KinematicBody

var path = []
var path_idx = 0
const move_speed = 5
onready var astar_map = get_parent()

func _ready():
	add_to_group("units")

func _process(delta):
	if path_idx < path.size():
		var mov_vec = (path[path_idx] - global_transform.origin)
		if mov_vec.length() < 0.1:
			path_idx += 1
		else:
			move_and_slide(mov_vec.normalized() * move_speed, Vector3(0, 1, 0))

func move_to(target_pos):
	path = astar_map.generate_path(global_transform.origin, target_pos)
	print(path)
	path_idx = 0
