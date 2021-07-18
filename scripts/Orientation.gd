extends Reference

# South is generally the default orientation, i.e. objects will face the camera.
#
# Object Facing South
#   |
#   V
#
#   ^
#   |
# Camera

const North = 10
const East = 16
const South = 0
const West = 22


static func rotate(orientation: int):  # Direction: Clockwise
	match orientation:
		South:
			return West
		West:
			return North
		North:
			return East
		East:
			return South
	
	print("%d is not a valid Orientation; returning South instead." % orientation)
	return South


static func to_rotation_degrees(orientation: int):  # Axis: Y
	match orientation:
		South:
			return Vector3(0, 0, 0)
		West:
			return Vector3(0, -90, 0)
		North:
			return Vector3(0, -180, 0)
		East:
			return Vector3(0, -270, 0)


static func from_rotation_degrees(rotation_degrees: Vector3):
	match int(rotation_degrees.y):
		0:
			return South
		-90:
			return East
		-180:
			return North
		-270:
			return West
