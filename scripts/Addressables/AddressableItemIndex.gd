extends Reference

const AddressableItem = preload("res://scripts/Addressables/AddressableItem.gd")
const Appliances = preload("res://scenes/Appliances.tscn")

const SCENE_INSTANCE = 0
const SCENE_SUBTYPES = 1

var scenes = {}


func _init():
	scenes = {
		"Appliance": [
			Appliances.instance(),
			["Stove"]
		]
	}


func new_addressable_item(
	item_id: int,
	item_name: String,
	translation: Vector3,
	orientation: int
):
	var item_name_array = item_name.capitalize().split(" ")
	var item_scene = item_name_array[-1]
	var item_type = item_name_array[-2]
	var addressable_item = null

	if item_scene in scenes and item_type in scenes[item_scene][SCENE_SUBTYPES]:
		addressable_item = AddressableItem.new()
		addressable_item.initialize(
			item_id,
			item_name,
			item_scene,
			item_type,
			translation,
			orientation
		)
		addressable_item.instance_item(scenes[item_scene][SCENE_INSTANCE])

	return addressable_item
