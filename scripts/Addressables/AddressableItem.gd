extends Spatial

const Orientation = preload("res://scripts/Orientation.gd")

var item_id = -1
var item_name = ""
var name_suffix = ""
var node_name = ""
var orientation = Orientation.South
var item = null


func initialize(
	p_item_id: int,
	p_item_name: String,
	p_name_suffix: String,
	p_translation: Vector3,
	p_orientation: int
):
	item_id = p_item_id
	item_name = p_item_name
	name_suffix = p_name_suffix
	node_name = item_name.trim_suffix(name_suffix)
	translation = p_translation
	orientation = p_orientation
	rotation_degrees = Orientation.to_rotation_degrees(orientation)
	set_name(item_name)


func orientation_rotate():
	orientation = Orientation.rotate(orientation)
	rotation_degrees = Orientation.to_rotation_degrees(orientation)


func instance_item(addressable_item_index):
	if item:
		return
	
	var resource = addressable_item_index.resources[name_suffix]
	var node = resource.get_node(node_name)
	item = node.duplicate()
	item.translation = Vector3()
	add_child(item)
	
