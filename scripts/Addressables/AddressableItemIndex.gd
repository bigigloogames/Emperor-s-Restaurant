extends Reference

const AddressableItem = preload("res://scripts/Addressables/AddressableItem.gd")
const Orientation = preload("res://scripts/Orientation.gd")

const Appliances = preload("res://scenes/Appliances.tscn")
const Stove = preload("res://scripts/Addressables/Stove.gd")

var resources = {}
var scripts = {
	"Stove": Stove
}


func _init():
	resources = {
		"Appliance": Appliances.instance()
	}


func item_is_addressable(item_resource: String, item_script: String):
	return item_resource in resources && item_script in scripts


func new_addressable_item(
	item_id: int,
	item_name: String,
	translation: Vector3,
	orientation: int
):
	var item_name_array = item_name.capitalize().split(" ")
	var item_resource = item_name_array[-1]
	var item_script = item_name_array[-2]
	var addressable_item = null

	if item_is_addressable(item_resource, item_script):
		addressable_item = AddressableItem.new()
		addressable_item.initialize(
			item_id,
			item_name,
			item_resource,
			item_script,
			translation,
			orientation
		)
		addressable_item.instance_item(
			resources[item_resource],
			scripts[item_script]
		)

	return addressable_item
