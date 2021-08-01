extends MeshInstance

onready var Lid = get_node(name + "Lid")


func clone():
	var cookware = duplicate()
	cookware.translation = Vector3()
	cookware.rotation = Vector3()
	return cookware
