extends "res://scripts/SceneManager/SceneWorker.gd"

onready var StartPanel = $StartPanel
onready var FishingBar = $FishingBar
onready var FishingCircle = $FishingBar/FishingCircle

var game = false
var x = -16  # Hardcoded values
var y = 459  # Change later

func _on_BackButton_pressed():
	resign()


func _start_game():
	StartPanel.visible = false
	game = true
	FishingBar.set_value(0)
	FishingCircle.set_value(0)
	FishingCircle.set_position(Vector2(x, y))


func _on_Button_pressed():
	FishingBar.set_value(FishingBar.get_value() + 2)

func _process(_delta):
	if game:
		FishingBar.set_value(FishingBar.get_value() - 0.1)
		var newPosition = Vector2(x, y - (FishingBar.get_value() * 5))
		FishingCircle.set_position(newPosition)
		if FishingBar.get_value() < 80 and FishingBar.get_value() > 60:
			FishingCircle.set_value(FishingCircle.get_value() + 0.2)
		else:
			FishingCircle.set_value(0)
		if FishingCircle.get_value() == 100:
			game = false
			StartPanel.visible = true
