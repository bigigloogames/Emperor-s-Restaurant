extends GridMap

const FLOOR_TILE = 0


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func populate_tiles(room_size):
	for m in room_size:
		set_cell_item(-2, 0, m, FLOOR_TILE, 0)
		for n in room_size:
			# $GridMap.set_cell_item(x, y, z, item, orientation)
			set_cell_item(m, 0, n, FLOOR_TILE, 0)
	set_cell_item(-1, 0, int(room_size/2), 0)


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
