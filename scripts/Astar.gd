extends GridMap

const PATH_TILE = 0
const SEAT_TILE = 1
# GridMap orientation constants
const NE = 10  # 180
const SE = 16  # +90 clockwise
const SW = 0  # no rotation
const NW = 22  # -90 clockwise

var astar = null
var all_points = {}


func _ready():
	pass # Replace with function body.


func populate_astar(room_size, furniture, tables, chairs):
	var seats = []
	for m in room_size:
		set_cell_item(-2, 1, m, PATH_TILE, 0)
		for n in room_size:
			if furniture[m][n] == null:
				set_cell_item(m, 1, n, PATH_TILE, 0)
			elif tables.has(int(furniture[m][n][0])):
				var chair = valid_chair(m, n, furniture, room_size, chairs)
				if chair:
					set_cell_item(chair.x, 1, chair.z, SEAT_TILE, 0)
					seats.push_back(chair)
	set_cell_item(-1, 1, int(room_size/2), PATH_TILE, 0)
	return seats


func valid_chair(m, n, furniture, room_size, chairs):
	var adjacent = [
		[m - 1, n, SE], [m + 1, n, NW], [m, n - 1, SW], [m, n + 1, NE]
	]
	for cell in adjacent:
		var x = cell[0]
		var z = cell[1]
		if x < 0 or z < 0 or x >= room_size or z >= room_size:
			continue
		var furni = furniture[x][z]
		if furni and chairs.has(int(furni[0])) and furni[1] == cell[2]:
			return Vector3(x, 1, z)
	return null


func generate_astar():
	astar = AStar.new()
	var cells = get_used_cells()
	for cell in cells:
		var idx = astar.get_available_point_id()
		astar.add_point(idx, map_to_world(cell.x, cell.y, cell.z))
		all_points[v3_to_index(cell)] = idx
		if get_cell_item(cell.x, cell.y, cell.z) == SEAT_TILE:
			astar.set_point_disabled(idx, true)
	for cell in cells:
		for x in [-1, 0, 1]:
			for y in [-1, 0, 1]:
				for z in [-1, 0, 1]:
					var v3 = Vector3(x, y, z)
					if v3 == Vector3(0, 0, 0):
						continue
					if v3_to_index(v3 + cell) in all_points:
						var idx1 = all_points[v3_to_index(cell)]
						var idx2 = all_points[v3_to_index(cell + v3)]
						if !astar.are_points_connected(idx1, idx2):
							astar.connect_points(idx1, idx2, true)


func generate_path(start, end):
	var grid_start = v3_to_index(start)
	var grid_end = v3_to_index(end)
	var start_id = 0
	var end_id = 0
	if grid_start in all_points:
		start_id = all_points[grid_start]
	else:
		start_id = astar.get_closest_point(start)
	if grid_end in all_points:
		end_id = all_points[grid_end]
	else:
		end_id = astar.get_closest_point(end)
	astar.set_point_disabled(end_id, false)
	return astar.get_point_path(start_id, end_id)


func toggle_seat(seat):
	var seat_id = all_points[v3_to_index(seat)]
	astar.set_point_disabled(seat_id, !astar.is_point_disabled(seat_id))


func v3_to_index(v3):
	var idx = str(int(round(v3.x)))
	idx += "," + str(int(round(v3.y)))
	idx += "," + str(int(round(v3.z)))
	return idx


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
