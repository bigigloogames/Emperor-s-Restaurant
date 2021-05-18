extends KinematicBody

var path = []
var path_idx = 0
const move_speed = 3

func _ready():
	set_collision_mask_bit(0, 0)
	add_to_group("customers")
	translation.x = -3
	translation.y = 2
	var col = CollisionShape.new()
	var box = BoxShape.new()
	box.extents = Vector3(0.1, 0.3, 0.1)
	col.translation.y = 0.3
	col.shape = box
	add_child(col)

func _process(delta):
	if path_idx < path.size():
		var mov_vec = (path[path_idx] - global_transform.origin)
		if mov_vec.length() < 0.1:
			path_idx += 1
		else:
			move_and_slide(mov_vec.normalized() * move_speed, Vector3.UP)


func take_path(new_path):
	path = new_path
	path_idx = 0
