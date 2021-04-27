extends GridMap

const PATH_TILE = 4
const SEAT_TILE = 6

var astar = null
var all_points = {}


func _ready():
	pass # Replace with function body.


func populate_astar(room_size):
	for m in room_size:
		set_cell_item(-2, 1, m, PATH_TILE, 0)
	set_cell_item(-1, 1, int(room_size/2), PATH_TILE, 0)


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


func generate_path_via_click(start, end):  # From mouse click
	var grid_start = v3_to_index(world_to_map(start))
	var grid_end = v3_to_index(world_to_map(end))
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
	return astar.get_point_path(start_id, end_id)


func v3_to_index(v3):
	var idx = str(int(round(v3.x)))
	idx += "," + str(int(round(v3.y)))
	idx += "," + str(int(round(v3.z)))
	return idx


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
