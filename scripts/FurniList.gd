extends ItemList

const CHAIR = 3
const TABLE = 2


func _ready():
	#visible = false
	#set_max_columns(0)
	set_select_mode(ItemList.SELECT_SINGLE)
	set_same_column_width(true)


func populate_list(mesh_lib):
	var furniture = mesh_lib.get_item_list()
	for id in furniture:
		var name = mesh_lib.get_item_name(id)
		var texture = mesh_lib.get_item_preview(id)
		add_item(name, texture, true)


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
