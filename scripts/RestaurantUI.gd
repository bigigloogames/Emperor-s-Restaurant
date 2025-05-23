extends Control

onready var Menu = $Menu
onready var Level = $Menu/Level
onready var ExpBar = $Menu/ExpBar
onready var Currency = $Currency
onready var Recipes = $Recipes
onready var Build = $Build
onready var Staff = $Staff
onready var StaffList = $Staff/StaffList
onready var Profile = $Staff/Profile
onready var StaffName = $Staff/Profile/Name
onready var StaffPosition = $Staff/Profile/Position
onready var StaffOptions = $Staff/Profile/Options
onready var StaffHire = $Staff/Profile/Hire
onready var StoreAppliances = $Build/Items/Store/Appliances
onready var StoreChairs = $Build/Items/Store/Chairs
onready var StoreTables = $Build/Items/Store/Tables
onready var InventoryAppliances = $Build/Items/Inventory/Appliances
onready var InventoryChairs = $Build/Items/Inventory/Chairs
onready var InventoryTables = $Build/Items/Inventory/Tables
enum {APPLIANCE, CHAIR, TABLE}

var selected_staff = 0


func _toggle_recipes():
	Recipes.visible = !Recipes.visible
	Menu.visible = !Menu.visible


func _toggle_build():
	Build.visible = !Build.visible
	Menu.visible = !Menu.visible


func _toggle_staff():
	Staff.visible = !Staff.visible
	Menu.visible = !Menu.visible


func add_exp():
	ExpBar.set_value(ExpBar.get_value() + 20)


func update_level(level, experience):
	Level.set_text(level)
	ExpBar.set_value(experience)


func update_currency(currency):
	Currency.text = currency


func add_build_buttons(target, binds):
	var rotate = Button.new()
	rotate.text = "Rotate"
	rotate.set_position(Vector2(4, 32))
	rotate.add_to_group("build_buttons")
	rotate.connect("pressed", target, "_on_rotate_pressed", binds)
	Build.add_child(rotate)
	var remove = Button.new()
	remove.text = "Remove"
	remove.set_position(Vector2(65, 32))
	remove.add_to_group("build_buttons")
	remove.connect("pressed", target, "_on_remove_pressed", binds)
	Build.add_child(remove)


func populate_store(mesh_lib):
	var items = {}
	items["appliances"] = StoreAppliances.populate_store(mesh_lib, "Appliance")
	items["chairs"] = StoreChairs.populate_store(mesh_lib, "Chair")
	items["tables"] = StoreTables.populate_store(mesh_lib, "Table")
	return items


func populate_inventory(mesh_lib, inventory):
	InventoryAppliances.populate_inventory(mesh_lib, "Appliance", inventory)
	InventoryChairs.populate_inventory(mesh_lib, "Chair", inventory)
	InventoryTables.populate_inventory(mesh_lib, "Table", inventory)


func get_store_item_info(type, index):
	var item_info = {}
	match type:
		APPLIANCE:
			item_info["cart_item"] = StoreAppliances.get_item_text(index)
			item_info["item_id"] = StoreAppliances.get_item_metadata(index)
		CHAIR:
			item_info["cart_item"] = StoreChairs.get_item_text(index)
			item_info["item_id"] = StoreChairs.get_item_metadata(index)
		TABLE:
			item_info["cart_item"] = StoreTables.get_item_text(index)
			item_info["item_id"] = StoreTables.get_item_metadata(index)
	return item_info


func get_inventory_item_info(type, index):
	match type:
		APPLIANCE:
			return InventoryAppliances.get_item_metadata(index)
		CHAIR:
			return InventoryChairs.get_item_metadata(index)
		TABLE:
			return InventoryTables.get_item_metadata(index)


func populate_staff(staff):
	StaffList.clear()
	for s in staff:
		if s:
			StaffList.add_item(s["name"])
		else:
			StaffList.add_item("Hire")
		StaffList.set_item_metadata(StaffList.get_item_count() - 1, s)


func display_profile(index):
	selected_staff = index
	var staff_info = StaffList.get_item_metadata(index)
	if staff_info:
		StaffName.text = staff_info["name"]
		StaffPosition.text = staff_info["position"]
		StaffOptions.visible = true
		StaffHire.visible = false
	else:
		StaffName.text = ""
		StaffPosition.text = ""
		StaffOptions.visible = false
		StaffHire.visible = true

func get_selected_staff():
	return selected_staff
