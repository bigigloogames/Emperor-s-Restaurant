extends Node

const Unit = preload("res://scenes/Unit.tscn")
# MeshLib item constants
const CHAIR = 3
const TABLE = 2
# GridMap orientation constants
const NE = 10
const SE = 16
const SW = 0
const NW = 22

onready var Cam = $CameraOrigin/Camera
onready var Build = $Control/Build
onready var FurniList = $Control/Build/Inventory/Chairs
onready var Floor = $Floor
onready var Furni = $Furniture
onready var Astar = $Astar
onready var Menu = $Control/Menu
onready var ExpBar = $Control/Menu/ExpBar
onready var Level = $Control/Menu/Level
onready var CustomerTimer = $CustomerTimer
var sav_dict = {}
var seats = []
var selected_item = -1
var build_mode = false

func _ready():
	load_game()
	var room_size = sav_dict["room_size"]
	var furniture = sav_dict["furniture"]
	Floor.populate_tiles(room_size)
	Furni.populate_furniture(furniture)
	
	initialize_astar()

	var mesh_lib = Furni.mesh_library
	FurniList.populate_list(mesh_lib)


func _on_CustomerTimer_timeout():  # Spawn customers
	if seats:
		var NewUnit = Unit.instance()
		NewUnit.add_to_group("customers")
		NewUnit.translation.x = -3
		NewUnit.translation.y = 2
		self.add_child(NewUnit)
		#NewUnit.visit_restaurant()
		var free_seat = seats.pop_back()
		var seat_id = Astar.all_points[Astar.v3_to_index(free_seat)]
		Astar.astar.set_point_disabled(seat_id, false)
		NewUnit.move_to(free_seat)
		Astar.astar.set_point_disabled(seat_id, true)
		#
		yield(get_tree().create_timer(20.0), "timeout")
		seats.push_back(free_seat)


func _on_Seating_body_entered(body):  # Detect customers entering seats
	yield(get_tree().create_timer(10.0), "timeout")  # Eating time
	body.move_to(Vector3(-2, 1, 8))


func _on_Exit_body_entered(body):  # Dectect customer leaving
	body.queue_free()
	ExpBar.set_value(ExpBar.get_value() + 20)


func _on_ItemList_item_selected(index):
	selected_item = int(FurniList.get_item_text(index))


func _input(event):
	if event is InputEventMouseButton and event.pressed and event.button_index == 1:
		var result = Cam.get_clicked_position(event)
		if result:
			if build_mode:
				var position = Furni.place_item(selected_item, result.position)
				if position:
					sav_dict["furniture"][position.x][position.z] = [selected_item, 0]
			else:
				get_tree().call_group("units", "move_to_via_click", result.position)


func _on_BuildMode_toggled(_button_pressed):
	build_mode = !build_mode
	Build.visible = build_mode
	Menu.visible = !build_mode
	if build_mode:
		CustomerTimer.stop()
		var customers = get_tree().get_nodes_in_group("customers")
		for customer in customers:
			customer.visible = false  # customer.queue_free()
	else:
		initialize_astar()
		CustomerTimer.start()


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
		sav_dict["level"] += 1
		Level.set_text(str(sav_dict["level"]))
		ExpBar.set_value(value - 100)


func save_game():
	var save_file = File.new()
	save_file.open("user://savegame.save", File.WRITE)
	save_file.store_line(to_json(sav_dict))
	save_file.close()


func _on_Save_pressed():
	save_game()


func load_game():
	var save_file = File.new()
	if not save_file.file_exists("user://savegame.save"):
		initialize_sav_dict()
		return
	save_file.open("user://savegame.save", File.READ)
	sav_dict = parse_json(save_file.get_line())
	save_file.close()


func initialize_sav_dict():
	sav_dict["level"] = 1
	sav_dict["exp"] = 0
	sav_dict["currency"] = 0
	sav_dict["floor"] = 0
	sav_dict["tiles"] = 0
	var room_size = 9
	sav_dict["room_size"] = room_size
	var furniture_array = []
	for x in range(room_size):
		furniture_array.append([])
		furniture_array[x].resize(room_size)
	# For debugging purposes
#	furniture_array[0][8] = [CHAIR, SW]  # no rotation
#	furniture_array[2][6] = [CHAIR, NE]  # 180
#	furniture_array[4][4] = [CHAIR, SE]  # +90 clockwise
#	furniture_array[6][2] = [CHAIR, NW]  # -90 clockwise
#	furniture_array[3][1] = [CHAIR, SW]  # no rotation
#	furniture_array[2][5] = [TABLE, NE]  # 180
#	furniture_array[5][4] = [TABLE, SE]  # +90 clockwise
#	furniture_array[5][2] = [TABLE, NW]  # -90 clockwise
	sav_dict["furniture"] = furniture_array


func initialize_astar():
	seats = Astar.populate_astar(sav_dict["room_size"], sav_dict["furniture"])
	Astar.generate_astar()


func _on_Map_pressed():
	get_tree().change_scene("res://scenes/Map.tscn")
