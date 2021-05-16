extends GridMap

# GridMap orientation constants
const NE = 10  # 180
const SE = 16  # +90 clockwise
const SW = 0  # no rotation
const NW = 22  # -90 clockwise

var selected = null


func _ready():
	pass # Replace with function body.


func populate_furniture(furniture):
	var size = furniture.size()
	for m in range(size):
		for n in range(size):
			if furniture[m][n]:
				set_cell_item(m, 0, n, furniture[m][n][0], furniture[m][n][1])


func place_item(selected_item, position):
	position = world_to_map(position)
	var m = position.x
	var n = position.z
	if m >= 0 and n >= 0 and m < 9 and n < 9:
		set_cell_item(m, 0, n, selected_item, 0)
		return position
	return null


func remove_item(position):
	position = world_to_map(position)
	set_cell_item(position.x, position.y, position.z, -1)


func rotate_item(position):
	position = world_to_map(position)
	var item = get_cell_item(position.x, position.y, position.z)
	var orientation = get_cell_item_orientation(position.x, position.y, position.z)
	var new_orientation = null
	match orientation:
		SW:
			new_orientation = NW
		NW:
			new_orientation = NE
		NE:
			new_orientation = SE
		SE:
			new_orientation = SW
	set_cell_item(position.x, position.y, position.z, item, new_orientation)


func is_occupied(position):
	position = world_to_map(position)
	return get_cell_item(position.x, position.y, position.z) != -1


func select_item(position):
	selected = world_to_map(position)


func drag(position):
	if is_occupied(position):
		return
	position = world_to_map(position)
	var item = get_cell_item(selected.x, selected.y, selected.z)
	var orientation = get_cell_item_orientation(selected.x, selected.y, selected.z)
	set_cell_item(selected.x, selected.y, selected.z, -1)
	selected = position
	set_cell_item(position.x, position.y, position.z, item, orientation)

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
