extends Node

var level = 0
var room_size = 9 + level

# Called when the node enters the scene tree for the first time.
func _ready():
	for m in room_size:
		for n in room_size:
			# $GridMap.set_cell_item(x, y, z, item, orientation)
			$GridMap.set_cell_item(m, 0, n, 0, 0)


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
