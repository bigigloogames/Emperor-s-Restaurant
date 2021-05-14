extends Node

const Unit = preload("res://scenes/Unit.tscn")

onready var Cam = $CameraOrigin/Camera
onready var Build = $Control/Panel
onready var Chairs = $Control/Panel/Build/Inventory/Chairs
onready var Tables = $Control/Panel/Build/Inventory/Tables
onready var Floor = $Floor
onready var Furni = $Furniture
onready var Astar = $Astar
onready var Menu = $Control/Menu
onready var ExpBar = $Control/Menu/ExpBar
onready var Level = $Control/Menu/Level
onready var CustomerTimer = $CustomerTimer
onready var Recipes = $Recipes
var sav_dict = {}
var seats = []
var selected_item = -1
var build_mode = false
var tables = []
var chairs = []


func _ready():
	load_game()
	var room_size = sav_dict["room_size"]
	var furniture = sav_dict["furniture"]
	Floor.populate_tiles(room_size)
	Furni.populate_furniture(furniture)
	
	initialize_astar()

	var mesh_lib = Furni.mesh_library
	tables = Tables.populate_list(mesh_lib, "Table")
	chairs = Chairs.populate_list(mesh_lib, "Chair")


func _on_CustomerTimer_timeout():  # Spawn customers
	if seats:
		var NewUnit = Unit.instance()
		self.add_child(NewUnit)
		var free_seat = seats.pop_back()
		Astar.toggle_seat(free_seat)
		NewUnit.move_to(free_seat)
		Astar.toggle_seat(free_seat)


func _on_Seating_body_entered(body):  # Detect customers entering seats
	var eating_timer = Timer.new()  # Eating time
	eating_timer.wait_time = 10
	eating_timer.one_shot = true
	body.add_child(eating_timer)
	eating_timer.start()
	eating_timer.connect("timeout", self, "_on_EatingTimer_timeout", [body])


func _on_EatingTimer_timeout(body):  # Customer is finished eating
	if body:
		body.move_to(Vector3(-2, 1, 8))


func _on_Seating_body_exited(body, seat):  # Detect customers leaving seats
	seats.push_back(seat)


func _on_Exit_body_entered(body):  # Dectect customer leaving
	body.queue_free()
	ExpBar.set_value(ExpBar.get_value() + 20)


func _on_ItemList_item_selected(index, type):
	if type == 0:
		selected_item = tables[index]
	else:
		selected_item = chairs[index]


func _input(event):
	if event is InputEventMouseButton and event.pressed and event.button_index == 1:
		var result = Cam.get_clicked_position(event)
		if result:
			if build_mode:
				var position = Furni.place_item(selected_item, result.position)
				if position:
					sav_dict["furniture"][position.x][position.z] = [selected_item, 0]


func _on_BuildMode_toggled(_button_pressed):
	build_mode = !build_mode
	Build.visible = build_mode
	Menu.visible = !build_mode
	if build_mode:
		CustomerTimer.stop()
		var customers = get_tree().get_nodes_in_group("customers")
		for customer in customers:
			customer.queue_free()
	else:
		initialize_astar()
		CustomerTimer.start()

func _on_Build_pressed():
	build_mode = !build_mode
	Build.visible = build_mode
	Menu.visible = !build_mode
	if build_mode:
		CustomerTimer.stop()
		var customers = get_tree().get_nodes_in_group("customers")
		for customer in customers:
			customer.queue_free()
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
	sav_dict["furniture"] = furniture_array


func initialize_astar():
	var seat_areas = get_tree().get_nodes_in_group("seat_area")
	for seat_area in seat_areas:
		seat_area.queue_free()
	seats = Astar.populate_astar(sav_dict["room_size"], sav_dict["furniture"])
	Astar.generate_astar()
	for seat in seats:
		var area = Area.new()
		add_child(area)
		area.add_to_group("seat_area")
		var collision = CollisionShape.new()
		collision.shape = BoxShape.new()
		collision.shape.extents = Vector3(0.25, 0.25, 0.25)
		area.add_child(collision)
		var coord = Astar.map_to_world(seat.x, seat.y, seat.z)
		area.translation.x = coord.x
		area.translation.z = coord.z
		area.translation.y = 1
		area.connect("body_entered", self, "_on_Seating_body_entered")
		area.connect("body_exited", self, "_on_Seating_body_exited", [seat])


func _on_Map_pressed():
	get_tree().change_scene("res://scenes/Map.tscn")


func _on_Recipes_pressed():
	Recipes.visible = !Recipes.visible
	Menu.visible = !Menu.visible
