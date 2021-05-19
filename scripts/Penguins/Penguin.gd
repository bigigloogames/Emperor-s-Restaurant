extends KinematicBody

onready var AnimationTree = $AnimationTree
var path = []
var path_idx = 0
const move_speed = 3


func _ready():
	set_collision_mask_bit(0, 0)
	add_to_group("customers")
	translation = Vector3(-1.2, 0.4, 0.4)
	var col = CollisionShape.new()
	var box = BoxShape.new()
	box.extents = Vector3(0, 0.3, 0)
	col.translation.y = 0.3
	col.shape = box
	add_child(col)
	AnimationTree.active = true


func _process(_delta):
	if path_idx < path.size():
		var mov_vec = (path[path_idx] - global_transform.origin)
		if mov_vec.length() < 0.1:
			path_idx += 1
		else:
			move_and_slide(mov_vec.normalized() * move_speed, Vector3.UP)
			face_direction(path[path_idx])
	elif path.size() > 0:
		translation = path[-1]
		path = []


func take_path(new_path):
	path = new_path
	path_idx = 0


func face_direction(direction):
	look_at(direction, Vector3.UP)
	rotate_y(PI)


func walk():
	AnimationTree.walk_or_sit(0)


func sit():
	AnimationTree.walk_or_sit(1)


func eat():
	AnimationTree.eat(1)
