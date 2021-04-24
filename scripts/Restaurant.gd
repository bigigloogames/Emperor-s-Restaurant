extends Node

const Unit = preload("res://scenes/Unit.tscn")
const PATH_TILE = 4
const SEAT_TILE = 6
const CHAIR = 3
const TABLE = -2

var level = 0
var room_size = 9 + level
onready var Camera = $CameraOrigin/Camera
var all_points = {}
var astar = null
onready var gridmap = $Astar
var seats = []

# Called when the node enters the scene tree for the first time.
func _ready():
	for m in room_size:
		for n in room_size:
			# $GridMap.set_cell_item(x, y, z, item, orientation)
			$Floor.set_cell_item(m, 0, n, 0, 0)
	$Furniture.set_cell_item(0, 0, 8, 3, 0)  # no rotation
	$Furniture.set_cell_item(2, 0, 6, 3, 10)  # 180
	$Furniture.set_cell_item(4, 0, 4, 3, 16)  # +90 clockwise
	$Furniture.set_cell_item(6, 0, 2, 3, 22)  # -90 clockwise
	$Furniture.set_cell_item(0, 0, 8, 3, 0)  # no rotation
	
	for m in room_size:
		$Floor.set_cell_item(-2, 0, m, 0, 0)
		$Astar.set_cell_item(-2, 1, m, 4, 0)
	$Floor.set_cell_item(-1, 0, int(room_size/2), 0)
	$Astar.set_cell_item(-1, 1, int(room_size/2), 4, 0)
	
	for m in room_size:
		for n in room_size:
			if $Furniture.get_cell_item(m, 0, n) == -1:
				$Astar.set_cell_item(m, 1, n, PATH_TILE, 0)
			elif $Furniture.get_cell_item(m, 0, n) == CHAIR:
				# Remember to check for valid seating
				$Astar.set_cell_item(m, 1, n, SEAT_TILE, 0)
				seats.push_back(Vector3(m, 1, n))
			#elif #Furniture.get_cell_item(m, 0, n) == TABLE:
				# Check if there's a chair next to the table
				# that is facing the right way
				# if
				# Furniture.get_cell_item(m - 1, 0, n) == CHAIR or
				# Furniture.get_cell_item(m + 1, 0, n) == CHAIR or
				# Furniture.get_cell_item(m, 0, n - 1) == CHAIR or
				# Furniture.get_cell_item(m, 0, n + 1) == CHAIR or:
					#$Astar.set_cell_item(m, 1, n, SEAT_TILE, 0)
					#seats.push_back(Vector3(m, 1, n))

	generate_astar()

	while seats:
		var NewUnit = Unit.instance()
		NewUnit.translation.x = -3
		NewUnit.translation.y = 2
		self.add_child(NewUnit)
		#NewUnit.visit_restaurant()
		var free_seat = seats.pop_back()
		NewUnit.move_to(free_seat)
		yield(get_tree().create_timer(10.0), "timeout")
		NewUnit.move_to(Vector3(-2, 1, 0))
		#seats.push_back(free_seat)
		yield(get_tree().create_timer(10.0), "timeout")
		NewUnit.queue_free()

func generate_astar():
	astar = AStar.new()
	var cells = gridmap.get_used_cells()
	for cell in cells:
		var idx = astar.get_available_point_id()
		astar.add_point(idx, gridmap.map_to_world(cell.x, cell.y, cell.z))
		all_points[v3_to_index(cell)] = idx
		if gridmap.get_cell_item(cell.x, cell.y, cell.z) == SEAT_TILE:
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

func v3_to_index(v3):
	return str(int(round(v3.x))) + "," + str(int(round(v3.y))) + "," + str(int(round(v3.z)))

func generate_path(start, end):  # From mouse click
	#var grid_start = v3_to_index(gridmap.world_to_map(start))
	var grid_start = v3_to_index(start)
	#var grid_end = v3_to_index(gridmap.world_to_map(end))
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
	var grid_start = v3_to_index(gridmap.world_to_map(start))
	var grid_end = v3_to_index(gridmap.world_to_map(end))
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

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	zoom()
	pan()

func zoom():
	if Input.is_action_just_released('wheel_down') and Camera.size < 20:
		Camera.size += 0.25
	if Input.is_action_just_released('wheel_up') and Camera.size > 1:
		Camera.size -= 0.25

func pan():
	if Input.is_action_just_pressed("ui_up") and Camera.translation.y < -20:
		Camera.translation.y += 1
	if Input.is_action_just_pressed("ui_down") and Camera.translation.y > -40:
		Camera.translation.y -= 1
