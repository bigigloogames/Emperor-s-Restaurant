extends Reference

const AddressableItem = preload("res://scripts/Addressables/AddressableItem.gd")
const Appliances = preload("res://scenes/Appliances.tscn")
const TYPES = [
	"Stove"
]

var scenes = {}


func _init():
	scenes = {
		"Appliance": Appliances.instance()
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

	if item_scene in scenes and item_type in TYPES:
		addressable_item = AddressableItem.new()
		addressable_item.initialize(
			item_id,
			item_name,
			item_scene,
			translation,
			orientation
		)
		addressable_item.instance_item(scenes[item_scene])

	return addressable_item
