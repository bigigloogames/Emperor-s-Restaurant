extends Node

var level = 0
var room_size = 9 + level
onready var Camera = $CameraOrigin/Camera

# Called when the node enters the scene tree for the first time.
func _ready():
	for m in room_size:
		for n in room_size:
			# $GridMap.set_cell_item(x, y, z, item, orientation)
			$GridMap.set_cell_item(m, 0, n, 2, 0)
	$GridMap.set_cell_item(0, 1, 8, 3, 0)  # no rotation
	$GridMap.set_cell_item(2, 1, 6, 3, 10)  # 180
	$GridMap.set_cell_item(4, 1, 4, 3, 16)  # +90 clockwise
	$GridMap.set_cell_item(6, 1, 2, 3, 22)  # -90 clockwise


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	zoom()
	pan()

func zoom():
	if Input.is_action_just_released('wheel_down') and Camera.size < 20:
		Camera.size += 0.25
	if Input.is_action_just_released('wheel_up') and Camera.size > 1:
		Camera.size -= 0.25

func pan():
	if Input.is_action_just_pressed("ui_up") and Camera.translation.y < -20:
		Camera.translation.y += 1
	if Input.is_action_just_pressed("ui_down") and Camera.translation.y > -40:
		Camera.translation.y -= 1
