extends KinematicBody

onready var AnimationTree = $AnimationTree
var routine = "Customer"

const move_speed = 3
var path = []
var path_idx = 0

var skeleton = null
const BODY_PARTS = [
	"head",
	"left_lower_flipper",
	"right_lower_flipper"
]
var equipment = {}

signal dest_reached


func initialize(r="Customer"):
	routine = r
	add_to_group(r.to_lower() +  's')


func _ready():
	translation = Vector3(-1.2, 0.4, 0.4)
	initialize_equipment()
	initialize_animations()


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


func initialize_equipment():
	skeleton = $Spatial/Armature/Skeleton
	if skeleton:
		for body_part in BODY_PARTS:
			var bone_attachment = BoneAttachment.new()
			bone_attachment.bone_name = body_part
			equipment[body_part] = {
				"bone_attachment": bone_attachment,
				"item": null
			}
			skeleton.add_child(bone_attachment)


func attach_equipment_item(body_part, equipment_item):
	var flip_x = "right" in body_part
	var item = equipment_item.clone(flip_x)
	equipment[body_part].bone_attachment.add_child(item)
	equipment[body_part].item = item


func initialize_animations():
	if routine == 'Waiter':
		# Routine Mixer: Combine
		AnimationTree.switch_routine_mixer(1)
	else:
		# Routine Mixer: Separate
		AnimationTree.switch_routine_mixer(-1)


func resolve_pedestrian_tree():
	return 'PedestrianAdd' if routine == 'Waiter' else 'PedestrianBlend'


func walk():
	AnimationTree.walk_or_routine(0)


func sit():
	AnimationTree.walk_or_routine(1)


func order():
	AnimationTree.vocalize(true)


func eat():
	AnimationTree.vocalize(false)
	AnimationTree.eat(1)


func wait_for_order():
	AnimationTree.walk_legs_still_or_move(resolve_pedestrian_tree(), 0)


func serve():
	AnimationTree.walk_legs_still_or_move(resolve_pedestrian_tree(), 1)
