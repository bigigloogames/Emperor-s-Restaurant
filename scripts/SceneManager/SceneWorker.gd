extends Node


var manager = null


func resign():
	if manager:
		manager.free_worker()
