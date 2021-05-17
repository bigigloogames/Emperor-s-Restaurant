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
var waiters = []
var queue = []
var selected_item = -1
var build_mode = false
var tables = []
var chairs = []
var dragging = false


func _ready():
	load_game()
	var room_size = sav_dict["room_size"]
	var furniture = sav_dict["furniture"]
	Floor.populate_tiles(room_size)
	Furni.populate_furniture(furniture)

	var mesh_lib = Furni.mesh_library
	tables = Tables.populate_list(mesh_lib, "Table")
	chairs = Chairs.populate_list(mesh_lib, "Chair")
	
	init_astar()
	spawn_waiters()


func _on_CustomerTimer_timeout():  # Spawn customers
	if seats:
		var NewUnit = Unit.instance()
		self.add_child(NewUnit)
		var free_seat = seats.pop_back()[0]
		Astar.toggle_seat(free_seat)
		NewUnit.move_to(free_seat)
		Astar.toggle_seat(free_seat)


func spawn_waiters():
	waiters.clear()
	var Waiter = Unit.instance()
	self.add_child(Waiter)
	waiters.append(Waiter)


func _on_Seating_body_entered(_body, table):  # Detect customers entering seats
	queue.append(table)


func serve_customer():
	if !queue.empty() and !waiters.empty():		
		var table = queue.pop_front()
		Astar.toggle_seat(table)
		waiters.pop_front().move_to(table)
		Astar.toggle_seat(table)


func _on_Table_body_entered(body, seat):  # Detect waiter reaching table
	var customer = seat.get_overlapping_bodies()[0]
	body.move_to(Vector3(0, 1, 0))
	var eating_timer = Timer.new()  # Eating time
	eating_timer.wait_time = 10
	eating_timer.one_shot = true
	customer.add_child(eating_timer)
	eating_timer.start()
	eating_timer.connect("timeout", self, "_on_EatingTimer_timeout", [customer])


func _on_Waiter_body_entered(body):
	waiters.append(body)


func _on_EatingTimer_timeout(body):  # Customer is finished eating
	if body:
		body.move_to(Vector3(-2, 1, 8))


func _on_Seating_body_exited(_body, seat):  # Detect customers leaving seats
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
	if build_mode and event is InputEventMouseButton and event.button_index == BUTTON_LEFT:
		var result = Cam.get_clicked_position(event)
		if result:
			if Furni.is_occupied(result.position):
				if not dragging and event.pressed:
					dragging = true
					Furni.select_item(result.position)
					var buttons = get_tree().get_nodes_in_group("build_buttons")
					for button in buttons:
						button.queue_free()
			elif event.pressed:
				var buttons = get_tree().get_nodes_in_group("build_buttons")
				for button in buttons:
					button.queue_free()
				var position = Furni.place_item(selected_item, result.position)
				if position:
					sav_dict["furniture"][position.x][position.z] = [selected_item, 0]
			if dragging and not event.pressed:
				dragging = false
				var rotate = Button.new()
				rotate.text = "Rotate"
				rotate.set_position(Vector2(15, -650))
				rotate.add_to_group("build_buttons")
				rotate.connect("pressed", self, "_on_rotate_pressed", [result.position])
				Build.add_child(rotate)
				var remove = Button.new()
				remove.text = "Remove"
				remove.set_position(Vector2(75, -650))
				remove.add_to_group("build_buttons")
				remove.connect("pressed", self, "_on_remove_pressed", [result.position])
				Build.add_child(remove)
	# Move furniture along with mouse
	if event is InputEventMouseMotion and dragging:
		var result = Cam.get_clicked_position(event)
		if result:
			Furni.drag(result.position)


func _on_rotate_pressed(position):
	Furni.rotate_item(position)


func _on_remove_pressed(position):
	Furni.remove_item(position)


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
		var furni_array = init_furni(sav_dict["room_size"])
		for furni in Furni.get_used_cells():
			var data = []
			data.append(Furni.get_cell_item(furni[0], furni[1], furni[2]))
			data.append(Furni.get_cell_item_orientation(furni[0], furni[1], furni[2]))
			furni_array[furni[0]][furni[2]] = data
		sav_dict["furniture"] = furni_array
		init_astar()
		spawn_waiters()
		CustomerTimer.start()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	zoom()
	pan()
	serve_customer()


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
		init_sav_dict()
		return
	save_file.open("user://savegame.save", File.READ)
	sav_dict = parse_json(save_file.get_line())
	save_file.close()


func init_sav_dict():
	sav_dict["level"] = 1
	sav_dict["exp"] = 0
	sav_dict["currency"] = 0
	sav_dict["floor"] = 0
	sav_dict["tiles"] = 0
	var room_size = 9
	sav_dict["room_size"] = room_size
	sav_dict["furniture"] = init_furni(room_size)


func init_furni(room_size):
	var furniture_array = []
	for x in range(room_size):
		furniture_array.append([])
		furniture_array[x].resize(room_size)
	return furniture_array

func init_astar():
	var seat_areas = get_tree().get_nodes_in_group("seat_area")
	for seat_area in seat_areas:
		seat_area.queue_free()
	seats = Astar.populate_astar(
			sav_dict["room_size"], sav_dict["furniture"], tables, chairs)
	Astar.generate_astar()
	for seat in seats:
		var chair = seat[0]
		var table = seat[1]
		var chair_area = Area.new()
		add_child(chair_area)
		chair_area.add_to_group("seat_area")
		var chair_collision = CollisionShape.new()
		chair_collision.shape = BoxShape.new()
		chair_collision.shape.extents = Vector3(0.05, 0.1, 0.05)
		chair_area.add_child(chair_collision)
		var seat_coord = Astar.map_to_world(chair.x, chair.y, chair.z)
		chair_area.translation.x = seat_coord.x
		chair_area.translation.z = seat_coord.z
		chair_area.translation.y = 1.5
		chair_area.connect("body_entered", self, "_on_Seating_body_entered", [table])
		chair_area.connect("body_exited", self, "_on_Seating_body_exited", [seat])
		var table_area = Area.new()
		add_child(table_area)
		table_area.add_to_group("seat_area")
		var table_collision = CollisionShape.new()
		table_collision.shape = BoxShape.new()
		table_collision.shape.extents = Vector3(0.01, 0.01, 0.01)
		table_area.add_child(table_collision)
		var table_coord = Astar.map_to_world(table.x, table.y, table.z)
		table_area.translation.x = table_coord.x
		table_area.translation.z = table_coord.z
		table_area.translation.y = 1
		table_area.connect("body_entered", self, "_on_Table_body_entered", [chair_area])
		var waiter_area = Area.new()
		add_child(waiter_area)
		waiter_area.add_to_group("seat_area")
		var waiter_collision = CollisionShape.new()
		waiter_collision.shape = BoxShape.new()
		waiter_collision.shape.extents = Vector3(0.01, 0.01, 0.01)
		waiter_area.add_child(waiter_collision)
		var waiter_coord = Astar.map_to_world(0, 1, 0)
		waiter_area.translation.x = waiter_coord.x
		waiter_area.translation.z = waiter_coord.z
		waiter_area.translation.y = 1
		waiter_area.connect("body_entered", self, "_on_Waiter_body_entered")


func _on_Map_pressed():
	get_tree().change_scene("res://scenes/Map.tscn")


func _on_Recipes_pressed():
	Recipes.visible = !Recipes.visible
	Menu.visible = !Menu.visible
