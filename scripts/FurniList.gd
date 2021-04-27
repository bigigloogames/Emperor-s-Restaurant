extends ItemList

const CHAIR = 3
const TABLE = 2


func _ready():
	#visible = false
	#set_max_columns(0)
	set_select_mode(ItemList.SELECT_SINGLE)
	set_same_column_width(true)


func populate_list(mesh_lib):
	var chair_id = mesh_lib.find_item_by_name("Chair")
	var chair_text = mesh_lib.get_item_preview(chair_id)
	var table_id = mesh_lib.find_item_by_name("Cube")
	var table_text = mesh_lib.get_item_preview(table_id)
	
	add_item(str(CHAIR), chair_text, true)
	add_item(str(TABLE), table_text, true)


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
