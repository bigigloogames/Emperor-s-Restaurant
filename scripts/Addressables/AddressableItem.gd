extends Spatial

const Orientation = preload("res://scripts/Orientation.gd")

var item_id = -1
var item_name = ""
var item_scene = ""
var node_name = ""
var orientation = Orientation.South
var item = null


func initialize(
	p_item_id: int,
	p_item_name: String,
	p_item_scene: String,
	p_translation: Vector3,
	p_orientation: int
):
	item_id = p_item_id
	item_name = p_item_name
	item_scene = p_item_scene
	node_name = item_name.trim_suffix(item_scene)
	translation = p_translation
	orientation = p_orientation
	rotation_degrees = Orientation.to_rotation_degrees(orientation)
	set_name(item_name)


func orientation_rotate():
	orientation = Orientation.rotate(orientation)
	rotation_degrees = Orientation.to_rotation_degrees(orientation)


func instance_item(scene: Spatial):
	if item:
		return

	var node = scene.get_node(node_name)
	item = node.duplicate()
	item.translation = Vector3()
	add_child(item)
