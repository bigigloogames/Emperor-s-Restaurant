extends Spatial


const Animator = preload("res://scripts/Animator.gd")


func _ready():
	Animator.loop_tracks($AnimationPlayer, ["ocean tide", "waves tide"], true)
	$AnimationTree.active = true


func _on_Fishing_new_scene_callback():
	$GUI.hide()


func _on_Fishing_scene_worker_freed():
	$GUI.show()

 
func _on_ForagingButton_new_scene_callback():
	$GUI.hide()
	$AnimationTree.set("parameters/forage transition position/seek_position", 0)
	$AnimationTree.set("parameters/forage transition speed/scale", 1)
	$AnimationTree.set("parameters/forage transition/add_amount", 1)


func _on_ForagingButton_scene_worker_freed():
	Animator.seek_penultimate_frame(
		$AnimationTree,
		"forage transition position",
		$AnimationPlayer,
		"camera pivot pan"
	)
	$AnimationTree.set("parameters/forage transition speed/scale", -1)
	$AnimationTree.set("parameters/forage transition/add_amount", 1)
	$GUI.show()
