extends MeshInstance

export var burner_count = 4

const BURNER_ORIGIN = 0
const BURNER_COOKWARE = 1

onready var Burners = get_node(name + "Burners")
onready var Knobs = get_node(name + "Knobs")
onready var Oven = get_node(name + "Oven")

var OvenOff = null
var OvenOn = null
var burners = []
var tween = null


func _ready():
	add_to_group("stoves")
	initialize_burners()
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


func initialize_burners():
	var prefix = name + "BurnerOrigin"
	burners.resize(burner_count)
	
	for n in burner_count:
		var burner = []
		burner.resize(2)
		burner[BURNER_ORIGIN] = Burners.get_node(prefix + String(n))
		burner[BURNER_COOKWARE] = null
		burners[n] = burner


func place_cookware(to: int, cookware: MeshInstance):
	burners[to][BURNER_ORIGIN].add_child(cookware)
	burners[to][BURNER_COOKWARE] = cookware


func move_cookware(from: int, to: int):
	var cookware = burners[from][BURNER_COOKWARE]
	burners[from][BURNER_ORIGIN].remove_child(cookware)
	burners[from][BURNER_COOKWARE] = null
	place_cookware(to, cookware)


func remove_cookware(from: int):
	burners[from][BURNER_COOKWARE].queue_free()
