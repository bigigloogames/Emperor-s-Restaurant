extends Spatial


func _ready():
	$AnimationTree.active = true


func _on_Fishing_new_scene_callback():
	$GUI.hide()


func _on_Fishing_scene_worker_freed():
	$GUI.show()

 
func _on_ForagingButton_new_scene_callback():
	$GUI.hide()
	$AnimationTree.set("parameters/forage transition position/seek_position", 0)
	$AnimationTree.set("parameters/forage transition speed/scale", 1)
	$AnimationTree.set("parameters/forage transition/active", true)


func _on_ForagingButton_scene_worker_freed():
	# Set the seek position to the second to last frame of the animation to fix the negative time scale bug
	$AnimationTree.set(
		"parameters/forage transition position/seek_position",
		$AnimationPlayer.get_animation("camera pivot pan").length - float(1)/60
	)
	$AnimationTree.set("parameters/forage transition speed/scale", -1)
	$AnimationTree.set("parameters/forage transition/active", true)
	$GUI.show()
