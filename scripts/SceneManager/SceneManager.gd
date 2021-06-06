extends Node


export var scene = ""
export var change_root_scene = false
export var toggle_self = false
export var toggle_group = false

signal new_scene_callback
signal disable
signal enable
signal scene_worker_freed

var active = true
var worker = null


func _ready():
	add_to_group("scene_managers")


func new_scene():
	if scene and active and not worker:
		if change_root_scene:
			var error_code = get_tree().change_scene("res://scenes/%s.tscn" % scene)
			if error_code != 0:
				print("Error %s" % error_code)
		else:
			worker = load("res://scenes/%s.tscn" % scene).instance()
			worker.manager = self
			self.owner.add_child(worker)
			
			if toggle_self:
				disable()
		
		emit_signal("new_scene_callback")


func disable():
	if toggle_group:
		get_tree().call_group("scene_managers", "_on_SceneManager_disable")
	else:
		emit_signal("disable")
	

func enable():
	if toggle_group:
		get_tree().call_group("scene_managers", "_on_SceneManager_enable")
	else:
		emit_signal("enable")


func _on_SceneManager_disable():
	active = false


func _on_SceneManager_enable():
	active = true


func free_worker():
	worker.queue_free()
	worker = null
	emit_signal("scene_worker_freed")
	
	if toggle_self:
		enable()
