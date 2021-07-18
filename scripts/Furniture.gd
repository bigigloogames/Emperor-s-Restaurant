extends GridMap

const Orientation = preload("res://scripts/Orientation.gd")
const AddressableItem = preload("res://scripts/Addressables/AddressableItem.gd")
const AddressableItemIndex = preload("res://scripts/Addressables/AddressableItemIndex.gd")

var addressable_item_index = null
var addressables_spatial = null
var addressables = {}
var selected = null


func _ready():
	addressable_item_index = AddressableItemIndex.new()
	addressables_spatial = Spatial.new()
	addressables_spatial.set_name("Addressables")
	add_child(addressables_spatial)


func populate_furniture(furniture):
	var size = furniture.size()
	for m in range(size):
		for n in range(size):
			if furniture[m][n]:
				place_item(
					furniture[m][n][0],
					Vector3(m, 0, n),
					furniture[m][n][1],
					false
				)


func new_addressable_item(item_id: int, position: Vector3, orientation := Orientation.South):
	var item_name = mesh_library.get_item_name(item_id)
	var addressable_item = null

	if "StoveAppliance" in item_name or "DeepFryerAppliance" in item_name:
		addressable_item = AddressableItem.new()
		addressable_item.initialize(item_id, item_name, "Appliance", position, orientation)
		addressable_item.instance_item(addressable_item_index)

	return addressable_item


func position_to_key(position: Vector3):
	return "%s,%s" % [position.x, position.z]


func key_to_position(key: String):
	var position = key.split(",")
	return Vector3(position[0], 0, position[1])


func place_item(selected_item, position, orientation = Orientation.South, convert_position = true):
	if convert_position:
		position = world_to_map(position)
		
	var m = position.x
	var n = position.z

	if m >= 0 and n >= 0 and m < 9 and n < 9:
		var addressable_item = new_addressable_item(selected_item, map_to_world(m, 0, n))

		if addressable_item:
			addressables[position_to_key(position)] = addressable_item
			addressables_spatial.add_child(addressable_item)
		else:
			set_cell_item(m, 0, n, selected_item, orientation)

		return position

	return null


func remove_item(position):
	position = world_to_map(position)
	var item = get_cell_item(position.x, position.y, position.z)
	
	if item == INVALID_CELL_ITEM:
		var key = position_to_key(position)
		var addressable_item = addressables[key]
		item = addressable_item.item_id
		addressables_spatial.remove_child(addressable_item)
		addressables.erase(key)
		addressable_item.queue_free()
	
	set_cell_item(position.x, position.y, position.z, INVALID_CELL_ITEM)
	return item


func rotate_item(position):
	position = world_to_map(position)
	var item = get_cell_item(position.x, position.y, position.z)
	
	if item == INVALID_CELL_ITEM:
		var key = position_to_key(position)
		var addressable_item = addressables[key]
		addressable_item.orientation_rotate()
	else:
		var orientation = get_cell_item_orientation(position.x, position.y, position.z)
		var new_orientation = Orientation.rotate(orientation)
		set_cell_item(position.x, position.y, position.z, item, new_orientation)


func is_occupied(position):
	position = world_to_map(position)
	return (
		get_cell_item(position.x, position.y, position.z) != -1
		|| addressables.has(position_to_key(position))
	)


func select_item(position):
	selected = world_to_map(position)


func drag(position):
	if is_occupied(position):
		return
		
	position = world_to_map(position)
	var item = get_cell_item(selected.x, selected.y, selected.z)
	
	if item == INVALID_CELL_ITEM:
		var key = position_to_key(selected)
		var addressable_item = addressables[key]
		addressables[position_to_key(position)] = addressables.get(key)
		addressables.erase(key)
		selected = position
		addressable_item.translation = map_to_world(position.x, position.y, position.z)
	else:
		var orientation = get_cell_item_orientation(selected.x, selected.y, selected.z)
		set_cell_item(selected.x, selected.y, selected.z, -1)
		selected = position
		set_cell_item(position.x, position.y, position.z, item, orientation)


func init_save_data(room_size):
	var data = []
	for x in range(room_size):
		data.append([])
		data[x].resize(room_size)
	return data


func serialize_item(position: Vector3):
	var x = int(position.x)
	var y = int(position.y)
	var z = int(position.z)
	return [
		get_cell_item(x, y, z),
		get_cell_item_orientation(x, y, z)
	]


func serialize_addressable_item(key: String):
	var addressable_item = addressables[key]
	return [
		addressable_item.item_id,
		Orientation.South
	]


func save(room_size):
	var data = init_save_data(room_size)
	
	for position in get_used_cells():
		data[position.x][position.z] = serialize_item(position)
		
	for key in addressables:
		var position = key_to_position(key)
		data[position.x][position.z] = serialize_addressable_item(key)
	
	return data
