extends KinematicBody

var path = []
var path_idx = 0
const move_speed = 5
onready var astar_map = get_parent().get_node("Astar")

func _ready():
	pass #add_to_group("units")

func _process(delta):
	if path_idx < path.size():
		var mov_vec = (path[path_idx] - global_transform.origin)
		if mov_vec.length() < 0.1:
			path_idx += 1
		else:
			move_and_slide(mov_vec.normalized() * move_speed, Vector3(0, 1, 0))

func move_to(target_pos):
	path = astar_map.generate_path(global_transform.origin, target_pos)
	path_idx = 0

func move_to_via_click(target_pos):
	path = astar_map.generate_path_via_click(global_transform.origin, target_pos)
	path_idx = 0

func visit_restaurant():
	move_to(Vector3(1, 0, 10))
	yield(get_tree().create_timer(10.0), "timeout")
	move_to(Vector3(-2, 1, 1))
	yield(get_tree().create_timer(10.0), "timeout")
	self.queue_free()
