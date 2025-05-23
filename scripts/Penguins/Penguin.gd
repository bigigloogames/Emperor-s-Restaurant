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


func initialize(p_routine := "Customer"):
	routine = p_routine
	add_to_group(p_routine.to_lower() + "s")


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
			equipment[body_part] = bone_attachment
			skeleton.add_child(bone_attachment)


func attach_equipment_item(equipment_item, flip_lateralization=false):
	if !equipment_item.body_part:
		print('EquipmentItem "%s" is not assigned to a body part.' % equipment_item.name)
		return

	var item = equipment_item.clone(flip_lateralization)
	var lateralization = ""
	if item.lateralized:
		if item.right_dominant:
			lateralization = "right_"
		else:
			lateralization = "left_"
	var body_part = lateralization + item.body_part

	equipment[body_part].add_child(item)


func toggle_equipment_item(body_part, equipment_name, visible):
	equipment[body_part].get_node(equipment_name).visible = visible


func initialize_animations():
	if routine == "Waiter":
		# Routine Mixer: Combine
		AnimationTree.switch_routine_mixer(1)
	else:
		# Routine Mixer: Separate
		AnimationTree.switch_routine_mixer(-1)

	if routine == "Chef":
		AnimationTree.walk_or_routine(1)


func resolve_pedestrian_tree():
	return "PedestrianAdd" if routine == "Waiter" else "PedestrianBlend"


# Customer
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
	AnimationTree.routine_and_walk(0)
	AnimationTree.hold_other_or_carry_order(0)


# Waiter
func serve():
	AnimationTree.routine_and_walk(1)
	AnimationTree.hold_other_or_carry_order(1)


func served():
	AnimationTree.hold_other_or_carry_order(0)
