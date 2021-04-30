extends Node

const Unit = preload("res://scenes/Unit.tscn")
# MeshLib item constants
const EMPTY = -1
const PATH_TILE = 4
const SEAT_TILE = 6
const TABLE = 2

onready var Cam = $CameraOrigin/Camera
onready var Build = $Control/Build
onready var FurniList = $Control/Build/Inventory/Chairs
onready var Floor = $Floor
onready var Furni = $Furniture
onready var Astar = $Astar
onready var ExpBar = $Control/ExpBar
onready var Level = $Control/Level
var level = 1
var room_size = 8 + level
var seats = []
var selected_item = -1
var build_mode = false


func _ready():
	Floor.populate_tiles(room_size)
	Furni.populate_furniture()
	Astar.populate_astar(room_size)
	
	for m in room_size:
		for n in room_size:
			if Furni.get_cell_item(m, 0, n) == EMPTY:
				Astar.set_cell_item(m, 1, n, PATH_TILE, 0)
			elif Furni.get_cell_item(m, 0, n) == TABLE:
				var chair = Furni.valid_chair(m, n)
				if chair:
					Astar.set_cell_item(chair.x, 1, chair.z, SEAT_TILE, 0)
					seats.push_back(chair)

	Astar.generate_astar()

	var mesh_lib = Furni.mesh_library
	FurniList.populate_list(mesh_lib)


func _on_CustomerTimer_timeout():
	while seats:
		var NewUnit = Unit.instance()
		NewUnit.translation.x = -3
		NewUnit.translation.y = 2
		self.add_child(NewUnit)
		#NewUnit.visit_restaurant()
		var free_seat = seats.pop_back()
		var seat_id = $Astar.all_points[$Astar.v3_to_index(free_seat)]
		$Astar.astar.set_point_disabled(seat_id, false)
		NewUnit.move_to(free_seat)
		$Astar.astar.set_point_disabled(seat_id, true)
		yield(get_tree().create_timer(10.0), "timeout")
		NewUnit.move_to(Vector3(-2, 1, 0))
		seats.push_back(free_seat)
		yield(get_tree().create_timer(10.0), "timeout")
		NewUnit.queue_free()
		ExpBar.set_value(ExpBar.get_value() + 20)


func _on_ItemList_item_selected(index):
	selected_item = int(FurniList.get_item_text(index))


func _input(event):
	if event is InputEventMouseButton and event.pressed and event.button_index == 1:
		var result = Cam.get_clicked_position(event)
		if result:
			if build_mode:
				Furni.place_item(selected_item, result.position)
			else:
				get_tree().call_group("units", "move_to_via_click", result.position)


func _on_BuildMode_toggled(_button_pressed):
	build_mode = !build_mode
	Build.visible = build_mode


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	zoom()
	pan()


func zoom():
	if Input.is_action_just_released('wheel_down'):
		Cam.zoom_out()
	if Input.is_action_just_released('wheel_up'):
		Cam.zoom_in()


func pan():
	if Input.is_action_just_pressed("ui_up"):
		Cam.pan_up()
	if Input.is_action_just_pressed("ui_down"):
		Cam.pan_down()


func _on_ExpBar_value_changed(value):
	if value >= 100:
		level += 1
		Level.set_text(str(level))
		ExpBar.set_value(value - 100)
