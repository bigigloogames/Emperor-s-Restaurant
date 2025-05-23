extends Node

const Penguindex = preload("res://scripts/Penguins/Penguindex.gd")
const Cookware = preload("res://scenes/Cookware.tscn")
const Serveware = preload("res://scenes/Serveware.tscn")

onready var Cam = $CameraOrigin/Camera
onready var UI = $UI
onready var Floor = $Floor
onready var Furni = $Furniture
onready var Astar = $Astar
onready var CustomerTimer = $CustomerTimer

var sav_dict = {}
var staff_names = []
var seats = []
var waiters = []
var chefs = []
var free_waiters = []
var queue = []
var selected_item = -1
var build_mode = false
var appliances = []
var chairs = []
var tables = []
var dragging = false
var cookware = null
var serveware = null


func _ready():
	load_game()
	load_names()
	var room_size = sav_dict["room_size"]
	var furniture = sav_dict["furniture"]
	Floor.populate_tiles(room_size)
	Furni.populate_furniture(furniture)

	init_store()
	init_inventory()
	init_staff()

	init_astar()
	init_equipment()
	spawn_staff()

	increment_currency(1000)


func _on_CustomerTimer_timeout():  # Spawn customers
	if !seats:
		return
	var customer = Penguindex.get_random_penguin()
	customer.initialize()
	self.add_child(customer)
	var seat = seats.pop_back()
	var chair = seat[0]
	Astar.toggle_point(chair)
	move_to(customer, chair)
	Astar.toggle_point(chair)
	customer.connect("dest_reached", self, "customer_seated", [customer, seat])


func move_to(body, destination, w2m = false):
	var path = Astar.generate_path(body.global_transform.origin, destination, w2m)
	if body.is_in_group("waiters"):
		path.resize(path.size() - 1)
	body.take_path(path)


func spawn_staff():
	var chef_count = 0
	for staff in sav_dict["staff"]:
		if not staff or staff["position"] == "Rest":
			continue
		var penguin = Penguindex.get_penguin(staff["species"])
		penguin.initialize(staff["position"])
		self.add_child(penguin)
		if staff["position"] == "Chef":
			if chef_count < chefs.size():
				var chef = chefs[chef_count]
				penguin.initialize_penguin_position(chef[0], chef[1])
				chef_count += 1
			else:
				penguin.queue_free()
		elif staff["position"] == "Waiter":
			var position = waiters.pop_front()
			if position:
				penguin.wait_for_order()
				free_waiters.append(penguin)
				penguin.initialize_penguin_position(position)
			else:
				penguin.queue_free()

			penguin.attach_equipment_item(serveware.get_node("FoodCloche"))
			penguin.attach_equipment_item(serveware.get_node("Menu"))
			penguin.attach_equipment_item(serveware.get_node("TableCloth"))
			penguin.toggle_equipment_item("left_lower_flipper", "FoodCloche", false)


func customer_seated(customer, seat):
	if not seat in queue:
		queue.append([seat, customer])
		var table = seat[1]
		customer.disconnect("dest_reached", self, "customer_seated")
		customer.face_direction(Astar.map_to_world(table.x, table.y, table.z))
		customer.sit()
		customer.order()


func serve_customer():
	if free_waiters.empty() or queue.empty():
		return
	var reservation = queue.pop_front()
	var waiter = free_waiters.pop_front()
	if !waiter:  # Waiters are busy
		queue.push_front(reservation)
		return
	var seat = reservation[0]
	var table = seat[1]
	var customer = reservation[1]
	Astar.toggle_point(table)
	move_to(waiter, table)
	waiter.serve()
	waiter.toggle_equipment_item("left_lower_flipper", "FoodCloche", true)
	waiter.toggle_equipment_item("left_lower_flipper", "Menu", false)
	Astar.toggle_point(table)
	waiter.connect("dest_reached", self, "_on_served", [waiter, seat, customer])


func _on_served(waiter, seat, customer):  # Waiter reached table
	waiter.disconnect("dest_reached", self, "_on_served")
	Astar.toggle_point(chefs[0][1], true)
	move_to(waiter, chefs[0][1], true)
	waiter.served()
	waiter.toggle_equipment_item("left_lower_flipper", "FoodCloche", false)
	waiter.toggle_equipment_item("left_lower_flipper", "Menu", true)
	Astar.toggle_point(chefs[0][1], true)
	var eating_timer = Timer.new()  # Eating time
	eating_timer.wait_time = 10
	eating_timer.one_shot = true
	customer.add_child(eating_timer)
	eating_timer.start()
	eating_timer.connect("timeout", self, "_on_eating_timeout", [customer, seat])
	customer.eat()
	waiter.connect("dest_reached", self, "_on_waiter_returned", [waiter])


func _on_waiter_returned(waiter):
	waiter.disconnect("dest_reached", self, "_on_waiter_returned")
	waiter.wait_for_order()
	if not waiter in free_waiters:
		free_waiters.append(waiter)


func _on_eating_timeout(customer, seat):  # Customer is finished eating
	if !customer:
		return
	customer.connect("dest_reached", self, "_on_customer_exited", [customer])
	move_to(customer, Vector3(-2, 0, 8))
	customer.walk()
	seats.push_back(seat)


func _on_customer_exited(customer):  # Dectect customer leaving
	customer.queue_free()
	UI.add_exp()
	increment_currency(50)


func _on_Store_item_selected(index, type):
	if sav_dict["currency"] < 50:
		print("Not enough money")
		return
	var confirm = ConfirmationDialog.new()
	var dialogue = "Purchase "
	var item_info = UI.get_store_item_info(type, index)
	var cart_item = item_info["cart_item"]
	var item_id = item_info["item_id"]
	dialogue += cart_item + "?"
	confirm.dialog_text = dialogue
	confirm.connect("confirmed", self, "_on_purchase_confirmed", [cart_item, item_id])
	add_child(confirm)
	confirm.popup()


func _on_purchase_confirmed(item, id):
	print("Purchased " + item)
	increment_currency(-50)
	increment_inventory(id, 1)
	init_inventory()


func _on_Inventory_item_selected(index, type):
	selected_item = UI.get_inventory_item_info(type, index)


func _input(event):
	if build_mode and event is InputEventMouseButton:
		var result = Cam.get_clicked_position(event)
		if !result:
			return
		var position = result.position
		if Furni.is_occupied(position) and !dragging and Input.is_action_pressed("ui_select"):
			dragging = true
			Furni.select_item(position)
			remove_in_group("build_buttons")
		elif Input.is_action_pressed("ui_select"):
			remove_in_group("build_buttons")
			if selected_item != -1 and increment_inventory(selected_item, -1):
				init_inventory()
				var coord = Furni.place_item(selected_item, position)
				if coord:
					sav_dict["furniture"][coord.x][coord.z] = [selected_item, 0]
			selected_item = -1
		if dragging and not Input.is_action_pressed("ui_select"):
			dragging = false
			UI.add_build_buttons(self, [position])
	# Move furniture along with mouse
	if event is InputEventMouseMotion and dragging:
		var result = Cam.get_clicked_position(event)
		if result:
			Furni.drag(result.position)


func _on_rotate_pressed(position):
	Furni.rotate_item(position)


func _on_remove_pressed(position):
	var item = Furni.remove_item(position)
	increment_inventory(item, 1)
	init_inventory()
	remove_in_group("build_buttons")


func _on_Build_pressed():
	build_mode = !build_mode
	if build_mode:
		close_restaurant()
	else:
		sav_dict["furniture"] = Furni.save(sav_dict["room_size"])
		init_astar()
		open_restaurant()


func _on_Staff_pressed(close):
	if close:
		close_restaurant()
		refresh_staff_profile(0)
	else:
		init_astar()
		open_restaurant()


func _on_staff_selected(index):
	UI.display_profile(index)


func _assign_staff(position):
	var index = UI.get_selected_staff()
	var staff = sav_dict["staff"]
	if position == "Sack":
		staff[index] = null
	else:
		staff[index]["position"] = position
	refresh_staff_profile(index)


func _hire_employee():
	var index = UI.get_selected_staff()
	randomize()
	var name = staff_names[randi() % staff_names.size()]
	var species = Penguindex.get_random_species()
	sav_dict["staff"][index] = {"name":name, "position":"Rest", "species":species}
	refresh_staff_profile(index)


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
		UI.update_level(str(sav_dict["level"]), value - 100)


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


func load_names():
	var names = File.new()
	if not names.file_exists("res://data/names.txt"):
		return
	names.open("res://data/names.txt", File.READ)
	while not names.eof_reached():
		staff_names.append(names.get_line())
	names.close()


func init_sav_dict():
	sav_dict["level"] = 1
	sav_dict["exp"] = 0
	sav_dict["currency"] = 1000
	sav_dict["floor"] = 0
	sav_dict["tiles"] = 0
	var room_size = 9
	sav_dict["room_size"] = room_size
	sav_dict["furniture"] = Furni.init_save_data(room_size)
	sav_dict["furni_inv"] = {}
	sav_dict["recipes"] = {}
	sav_dict["rec_inv"] = {}
	sav_dict["staff"] = [null, null]


func init_store():
	var mesh_lib = Furni.mesh_library
	var items = UI.populate_store(mesh_lib)
	appliances = items["appliances"]
	chairs = items["chairs"]
	tables = items["tables"]


func increment_currency(amount):
	sav_dict["currency"] += amount
	UI.update_currency(str(sav_dict["currency"]))


func increment_inventory(item, quantity):
	item = str(item)
	var inventory = sav_dict["furni_inv"]
	if not item in inventory:
		inventory[item] = 0
	if inventory[item] + quantity < 0:
		return false
	inventory[item] += quantity
	if inventory[item] == 0:
		inventory.erase(item)
	return true


func init_inventory():
	var mesh_lib = Furni.mesh_library
	if not "furni_inv" in sav_dict:
		sav_dict["furni_inv"] = {}
	UI.populate_inventory(mesh_lib, sav_dict["furni_inv"])


func init_staff():
	if not "staff" in sav_dict:
		sav_dict["staff"] = [null, null]
	UI.populate_staff(sav_dict["staff"])


func refresh_staff_profile(index):
	init_staff()
	UI.display_profile(index)


func init_astar():
	var coordinates = Astar.populate_astar(
		Furni, sav_dict["room_size"], sav_dict["furniture"], tables, chairs
	)
	seats = coordinates["seats"]
	waiters = coordinates["waiters"]
	chefs = coordinates["chefs"]
	Astar.generate_astar()


func init_equipment():
	cookware = Cookware.instance()
	serveware = Serveware.instance()


func open_restaurant():
	spawn_staff()
	CustomerTimer.start()


func close_restaurant():
	CustomerTimer.stop()
	remove_in_group("customers")
	remove_in_group("waiters")
	remove_in_group("chefs")
	queue.clear()
	free_waiters.clear()


func remove_in_group(group_name):
	var group = get_tree().get_nodes_in_group(group_name)
	for member in group:
		member.queue_free()


func _on_Map_pressed():
	if get_tree().change_scene("res://scenes/Map.tscn") != OK:
		print("Error changing scenes")
