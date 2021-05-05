extends GridMap


func _ready():
	pass # Replace with function body.


func populate_furniture(furniture):
	var size = furniture.size()
	for m in range(size):
		for n in range(size):
			if furniture[m][n]:
				set_cell_item(m, -1, n, furniture[m][n][0], furniture[m][n][1])


func place_item(selected_item, position):
	position = world_to_map(position)
	var m = position.x
	var n = position.z
	if m >= 0 and n >= 0 and m < 9 and n < 9:
		set_cell_item(m, 0, n, selected_item, 0)
		return position
	return null


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
