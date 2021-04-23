extends Node

var level = 0
var room_size = 9 + level
onready var Camera = $CameraOrigin/Camera
var all_points = {}
var astar = null
onready var gridmap = $Astar

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
		for n in room_size:
			if $Furniture.get_cell_item(m, 0, n) == -1:
				$Astar.set_cell_item(m, 1, n, 4, 0)

	astar = AStar.new()
	var cells = gridmap.get_used_cells()
	for cell in cells:
		var idx = astar.get_available_point_id()
		astar.add_point(idx, gridmap.map_to_world(cell.x, cell.y, cell.z))
		all_points[v3_to_index(cell)] = idx
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

func generate_path(start, end):
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
