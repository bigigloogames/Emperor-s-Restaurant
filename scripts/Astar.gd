extends GridMap

enum {PATH_TILE, SEAT_TILE, TABLE_TILE, WAITER_TILE, CHEF_TILE}
# GridMap orientation constants
const NE = 10  # 180
const SE = 16  # +90 clockwise
const SW = 0  # no rotation
const NW = 22  # -90 clockwise

var astar = null
var all_points = {}


func _ready():
	pass # Replace with function body.


func populate_astar(room_size, furniture, tables, chairs, appliances):
	clear()
	var seats = []
	var waiters = []
	var chefs = []
	for m in room_size:
		set_cell_item(-2, 0, m, PATH_TILE)
		for n in room_size:
			if furniture[m][n] == null:
				set_cell_item(m, 0, n, PATH_TILE)
			elif tables.has(int(furniture[m][n][0])):
				var chair = valid_chair(m, n, furniture, room_size, chairs)
				if chair:
					set_cell_item(chair.x, 0, chair.z, SEAT_TILE)
					set_cell_item(m, 0, n, TABLE_TILE)
					seats.append([chair, Vector3(m, 0, n)])
			elif appliances.has(int(furniture[m][n][0])):
				var orientation = int(furniture[m][n][1])
				var waiter = valid_waiter(m, n, room_size, furniture, orientation)
				var chef = valid_chef(m, n, room_size, furniture, orientation)
				if waiter and chef:
					var appliance = map_to_world(m, 0, n)
					set_cell_item(m, 0, n, WAITER_TILE)
					waiter = map_to_world(waiter.x, waiter.y, waiter.z)
					waiters.append(waiter)
					set_cell_item(chef.x, 0, chef.z, CHEF_TILE)
					chef = map_to_world(chef.x, chef.y, chef.z)
					chefs.append([chef, appliance])
	set_cell_item(-1, 0, int(room_size/2), PATH_TILE)
	var coordinates = {}
	coordinates["seats"] = seats
	coordinates["waiters"] = waiters
	coordinates["chefs"] = chefs
	return coordinates


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
			return Vector3(x, 0, z)
	return null


func valid_waiter(m, n, room_size, furniture, orientation):
	var x = null
	var z = null
	match orientation:
		NW:
			x = m + 1
			z = n
		SE:
			x = m - 1
			z = n
		NE:
			x = m
			z = n + 1
		SW:
			x = m
			z = n - 1
	if x < 0 or z < 0 or x >= room_size or z >= room_size or furniture[x][z] != null:
		return null
	return Vector3(x, 0, z)


func valid_chef(m, n, room_size, furniture, orientation):
	var x = null
	var z = null
	match orientation:
		NW:
			x = m - 1
			z = n
		SE:
			x = m + 1
			z = n
		NE:
			x = m
			z = n - 1
		SW:
			x = m
			z = n + 1
	if x < 0 or z < 0 or x >= room_size or z >= room_size or furniture[x][z] != null:
		return null
	return Vector3(x, 0, z)


func generate_astar():
	astar = AStar.new()
	all_points.clear()
	var cells = get_used_cells()
	for cell in cells:
		var idx = astar.get_available_point_id()
		astar.add_point(idx, map_to_world(cell.x, cell.y, cell.z))
		all_points[v3_to_index(cell)] = idx
		if get_cell_item(cell.x, cell.y, cell.z) != PATH_TILE:
			astar.set_point_disabled(idx, true)
	for cell in cells:
		for x in [-1, 0, 1]:
			for y in [-1, 0, 1]:
				for z in [-1, 0, 1]:
					var v3 = Vector3(x, y, z)
					if v3 == Vector3(0, 0, 0):
						continue
					var adj = v3 + cell
					if v3_to_index(adj) in all_points and is_valid(cell, adj):
						var idx1 = all_points[v3_to_index(cell)]
						var idx2 = all_points[v3_to_index(adj)]
						if !astar.are_points_connected(idx1, idx2):
							astar.connect_points(idx1, idx2, true)


func is_valid(cell1, cell2):
	var c1 = get_cell_item(cell1.x, cell1.y, cell1.z) == PATH_TILE
	var c2 = get_cell_item(cell2.x, cell2.y, cell2.z) == PATH_TILE
	return c1 or c2


func generate_path(start, end, w2m):
	start = world_to_map(start)
	if w2m:
		end = world_to_map(end)
	var grid_start = v3_to_index(start)
	var grid_end = v3_to_index(end)
	var start_id = 0
	var end_id = 0
	if grid_start in all_points:
		start_id = all_points[grid_start]
	else:
		start_id = astar.get_closest_point(start, true)
	if grid_end in all_points:
		end_id = all_points[grid_end]
	else:
		return []
	return astar.get_point_path(start_id, end_id)


func toggle_point(point, w2m = false):
	if w2m:
		point = world_to_map(point)
	var point_id = all_points[v3_to_index(point)]
	astar.set_point_disabled(point_id, !astar.is_point_disabled(point_id))


func v3_to_index(v3):
	var idx = str(int(round(v3.x)))
	idx += "," + str(int(round(v3.y)))
	idx += "," + str(int(round(v3.z)))
	return idx


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
