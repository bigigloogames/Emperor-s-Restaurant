extends MeshInstance

export (String,
	"",
	"head",
	"lower_flipper"
) var body_part
export var lateralized = false
export var right_dominant = false
export var delta_translation = Vector3()  # Unit: Meter
export var delta_rotation = Vector3()  # Unit: Degree


func clone(flip_lateralization: bool):
	var item = self.duplicate()
	item.translation = delta_translation
	item.rotation_degrees = delta_rotation
	
	if flip_lateralization:
		item.right_dominant = !item.right_dominant
		item.translation.x *= -1
		item.rotation_degrees.z *= -1 

	return item
