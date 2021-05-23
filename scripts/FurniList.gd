extends ItemList


func _ready():
	#visible = false
	set_max_columns(0)
	set_select_mode(ItemList.SELECT_SINGLE)
	set_same_column_width(true)


func populate_store(mesh_lib, type):
	var items = []
	var furniture = mesh_lib.get_item_list()
	for id in furniture:
		var name_str = mesh_lib.get_item_name(id).capitalize()
		if type in name_str:
			var texture = mesh_lib.get_item_preview(id)
			add_item(name_str, texture, true)
			set_item_metadata(get_item_count() - 1, id)
			items.append(id)
	return items


func populate_inventory(mesh_lib, type, inventory):
	clear()
	for id in inventory:
		id = int(id)
		var name_str = mesh_lib.get_item_name(id).capitalize()
		if type in name_str:
			var texture = mesh_lib.get_item_preview(id)
			add_item(name_str, texture, true)
			set_item_metadata(get_item_count() - 1, id)


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
