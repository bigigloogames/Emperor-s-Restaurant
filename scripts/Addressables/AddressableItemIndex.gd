extends Reference

const Appliances = preload("res://scenes/Appliances.tscn")

var resources = {}


func _init():
	resources = {
		"Appliance": Appliances.instance()
	}
