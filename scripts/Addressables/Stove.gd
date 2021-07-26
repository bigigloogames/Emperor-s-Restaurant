extends Node

onready var Burners = get_node(name + "Burners")
onready var Knobs = get_node(name + "Knobs")
onready var Oven = get_node(name + "Oven")

var OvenOff = null
var OvenOn = null
var tween = null


func _ready():
	initialize_oven()
	initialize_tween()


func initialize_tween():
	tween = Tween.new()
	add_child(tween)
	tween.start()


func initialize_oven():
	OvenOff = Oven.get_node(Oven.name + "Off")
	OvenOn = Oven.get_node(Oven.name + "On")
	toggle_oven_light(false)


func toggle_oven_light(on: bool):
	if on:
		OvenOff.hide()
		OvenOn.show()
	else:
		OvenOff.show()
		OvenOn.hide()


func use_oven_door():
	open_oven_door(1, 0)
	close_oven_door(1, 1.5)


func open_oven_door(duration: float, delay: float):
	tween.interpolate_property(
		Oven,
		"rotation_degrees:x",
		0,
		90,
		duration,
		tween.TRANS_BACK,
		tween.EASE_OUT,
		delay
	)


func close_oven_door(duration: float, delay: float):
	tween.interpolate_property(
		Oven,
		"rotation_degrees:x",
		90,
		0,
		duration,
		tween.TRANS_BACK,
		tween.EASE_IN,
		delay
	)
