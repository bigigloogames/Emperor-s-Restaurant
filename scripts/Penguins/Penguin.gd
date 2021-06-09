extends KinematicBody

onready var AnimationTree = $AnimationTree
var path = []
var path_idx = 0
const move_speed = 3
signal dest_reached


func _ready():
	add_to_group("customers")
	translation = Vector3(-1.2, 0.4, 0.4)
	AnimationTree.switch_routine_mixer(-1)


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
		emit_signal("dest_reached")


func initialize_penguin_position(position, stove = null):
	translation = position
	if stove:
		face_direction(stove)


func take_path(new_path):
	path = new_path
	path_idx = 0


func face_direction(direction):
	look_at(direction, Vector3.UP)
	rotate_y(PI)


func walk():
	AnimationTree.walk_or_routine(0)


func sit():
	AnimationTree.walk_or_routine(1)


func order():
	AnimationTree.vocalize(true)


func eat():
	AnimationTree.vocalize(false)
	AnimationTree.eat(1)
