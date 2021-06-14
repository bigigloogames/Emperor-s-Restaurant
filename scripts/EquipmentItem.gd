extends MeshInstance

export (String,
	"default",
	"handheld"
) var type = "default"


func clone(flip_x: bool):
	var item = self.duplicate()
	var direction = -1 if flip_x else 1
	
	if type == "handheld":
		item.translation = Vector3(direction * 0.05, 0.1, 0)
		item.rotation = Vector3(PI/2, 0, direction * -PI/2)

	return item
