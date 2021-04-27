extends GridMap

# GridMap orientation constants
const NE = 10
const SE = 16
const SW = 0
const NW = 22
# MeshLib item constants
const EMPTY = 0
#const PATH_TILE = 4
#const SEAT_TILE = 6
const CHAIR = 3
const TABLE = 2


func _ready():
	pass # Replace with function body.


func populate_furniture():
	set_cell_item(0, 0, 8, CHAIR, SW)  # no rotation
	set_cell_item(2, 0, 6, CHAIR, NE)  # 180
	set_cell_item(4, 0, 4, CHAIR, SE)  # +90 clockwise
	set_cell_item(6, 0, 2, CHAIR, NW)  # -90 clockwise
	set_cell_item(3, 0, 1, CHAIR, 0)  # no rotation
	set_cell_item(2, 0, 5, TABLE, NE)  # 180
	set_cell_item(5, 0, 4, TABLE, SE)  # +90 clockwise
	set_cell_item(5, 0, 2, TABLE, NW)  # -90 clockwise


func valid_chair(m, n):
	if get_cell_item(m - 1, 0, n) == CHAIR and get_cell_item_orientation(m - 1, 0, n) == SE:
		return Vector3(m - 1, 1, n)
	if get_cell_item(m + 1, 0, n) == CHAIR and get_cell_item_orientation(m + 1, 0, n) == NW:
		return Vector3(m + 1, 1, n)
	if get_cell_item(m, 0, n - 1) == CHAIR and get_cell_item_orientation(m, 0, n - 1) == SW:
		return Vector3(m, 1, n - 1)
	if get_cell_item(m, 0, n + 1) == CHAIR and get_cell_item_orientation(m, 0, n + 1) == NE:
		return Vector3(m, 1, n + 1)
	return null


func place_item(selected_item, position):
	position = world_to_map(position)
	set_cell_item(position.x, 0, position.z, selected_item, SW)


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
