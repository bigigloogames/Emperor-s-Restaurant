extends Node

const AdeliePenguin = preload("res://scenes/Penguins/AdeliePenguin.tscn")
const ChinstrapPenguin = preload("res://scenes/Penguins/ChinstrapPenguin.tscn")
const EmperorPenguin = preload("res://scenes/Penguins/EmperorPenguin.tscn")
const GentooPenguin = preload("res://scenes/Penguins/GentooPenguin.tscn")
const KingPenguin = preload("res://scenes/Penguins/KingPenguin.tscn")

onready var Cam = $CameraOrigin/Camera
onready var Build = $Control/Panel
onready var StoreChairs = $Control/Panel/Build/Store/Chairs
onready var StoreTables = $Control/Panel/Build/Store/Tables
onready var InventoryChairs = $Control/Panel/Build/Inventory/Chairs
onready var InventoryTables = $Control/Panel/Build/Inventory/Tables
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
var free_waiters = []
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
	var _store_tables = StoreTables.populate_list(mesh_lib, "Table")
	var _store_chairs = StoreChairs.populate_list(mesh_lib, "Chair")
	tables = InventoryTables.populate_list(mesh_lib, "Table")
	chairs = InventoryChairs.populate_list(mesh_lib, "Chair")
	
	init_astar()
	spawn_waiters()


func _on_CustomerTimer_timeout():  # Spawn customers
	if seats:
		var customer = null
		randomize()
		var species = randi() % 5 + 1
		match species:
			1:
				customer = AdeliePenguin.instance()
			2:
				customer = ChinstrapPenguin.instance()
			3:
				customer = EmperorPenguin.instance()
			4:
				customer = GentooPenguin.instance()
			5:
				customer = KingPenguin.instance()
		self.add_child(customer)
		var free_seat = seats.pop_back()[0]
		Astar.toggle_seat(free_seat)
		move_to(customer, free_seat)
		Astar.toggle_seat(free_seat)


func move_to(body, destination):
	var path = Astar.generate_path(body.global_transform.origin, destination)
#	if body.is_in_group("waiters"):
#		path.resize(path.size() - 1)
	body.take_path(path)


func spawn_waiters():
	var Waiter = EmperorPenguin.instance()
	self.add_child(Waiter)
	free_waiters.append(Waiter)
	Waiter.add_to_group("waiters")
	Waiter.remove_from_group("customers")


func _on_Seating_body_entered(body, table, direction):  # Detect customers entering seats
	if body.is_in_group("customers") and not table in queue:
		queue.append(table)
		body.sit()
		body.face_direction(direction)


func serve_customer():
	if free_waiters.empty() or queue.empty():
		return
	var table = queue.pop_front()
	var waiter = free_waiters.pop_front()
	if waiter:
		Astar.toggle_seat(table)
		move_to(waiter, table)
		Astar.toggle_seat(table)
	else:
		queue.push_front(table)


func _on_Table_body_entered(body, seat):  # Detect waiter reaching table
	if !body.is_in_group("waiters"):
		return
	var customer = seat.get_overlapping_bodies()
	if customer.empty():
		return
	customer = customer[0]
	move_to(body, Vector3(0, 0, 0))
	var eating_timer = Timer.new()  # Eating time
	eating_timer.wait_time = 10
	eating_timer.one_shot = true
	customer.add_child(eating_timer)
	eating_timer.start()
	eating_timer.connect("timeout", self, "_on_EatingTimer_timeout", [customer])
	customer.eat()


func _on_Waiter_body_entered(body):
	if not body in free_waiters:
		free_waiters.append(body)


func _on_EatingTimer_timeout(body):  # Customer is finished eating
	if body:
		move_to(body, Vector3(-2, 0, 8))
		body.walk()


func _on_Seating_body_exited(body, seat):  # Detect customers leaving seats
	if body.is_in_group("customers"):
		seats.push_back(seat)


func _on_Exit_body_entered(body):  # Dectect customer leaving
	body.queue_free()
	ExpBar.set_value(ExpBar.get_value() + 20)


func _on_Store_item_selected(index, type):
	var confirm = ConfirmationDialog.new()
	var dialogue = "Purchase "
	var cart_item = null
	if type == 0:
		cart_item = InventoryTables.get_item_text(index)
	else:
		cart_item = InventoryChairs.get_item_text(index)
	dialogue += cart_item + "?"
	confirm.dialog_text = dialogue
	confirm.connect("confirmed", self, "_on_purchase_confirmed", [cart_item])
	add_child(confirm)
	confirm.popup()


func _on_purchase_confirmed(item):
	print("Purchased " + item)


func _on_Inventory_item_selected(index, type):
	if type == 0:
		selected_item = tables[index]
	else:
		selected_item = chairs[index]


func _input(event):
	if build_mode and event is InputEventMouseButton and event.button_index == BUTTON_LEFT:
		var result = Cam.get_clicked_position(event)
		if !result:
			return
		if Furni.is_occupied(result.position) and !dragging and event.pressed:
			dragging = true
			Furni.select_item(result.position)
			remove_in_group("build_buttons")
		elif event.pressed:
			remove_in_group("build_buttons")
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
	remove_in_group("build_buttons")


func _on_Build_pressed():
	build_mode = !build_mode
	Build.visible = build_mode
	Menu.visible = !build_mode
	if build_mode:
		CustomerTimer.stop()
		remove_in_group("customers")
		remove_in_group("waiters")
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
func _process(_delta):
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
	queue.clear()
	free_waiters.clear()
	remove_in_group("area")
	seats = Astar.populate_astar(
			sav_dict["room_size"], sav_dict["furniture"], tables, chairs)
	Astar.generate_astar()
	for seat in seats:
		var chair = seat[0]
		var table = seat[1]
		var seat_coord = Astar.map_to_world(chair.x, chair.y, chair.z)
		var table_coord = Astar.map_to_world(table.x, table.y, table.z)
		# Seat area
		var chair_area = create_collision_area(seat_coord.x, 1, seat_coord.z)
		chair_area.connect("body_entered", self, "_on_Seating_body_entered", [table, table_coord])
		chair_area.connect("body_exited", self, "_on_Seating_body_exited", [seat])
		# Table area
		var table_area = create_collision_area(table_coord.x, 1, table_coord.z)
		table_area.connect("body_entered", self, "_on_Table_body_entered", [chair_area])
	# Waiter area
	var waiter_coord = Astar.map_to_world(0, 1, 0)
	var waiter_area = create_collision_area(waiter_coord.x, 1, waiter_coord.z)
	waiter_area.connect("body_entered", self, "_on_Waiter_body_entered")


func create_collision_area(x, y, z):
	var area = Area.new()
	var collision = CollisionShape.new()
	collision.shape = BoxShape.new()
	collision.shape.extents = Vector3(0.08, 0.08, 0.08)
	area.add_child(collision)
	area.translation = Vector3(x, y, z)
	add_child(area)
	area.add_to_group("area")
	return area


func remove_in_group(group_name):
	var group = get_tree().get_nodes_in_group(group_name)
	for member in group:
		member.queue_free()


func _on_Map_pressed():
	if get_tree().change_scene("res://scenes/Map.tscn") != OK:
		print("Error changing scenes")


func _on_Recipes_pressed():
	Recipes.visible = !Recipes.visible
	Menu.visible = !Menu.visible
