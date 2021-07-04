extends "res://scripts/SceneManager/SceneWorker.gd"

onready var StartPanel = $StartPanel
onready var ProgressBar = $ProgressBar

var game = false
var status = 0


func _on_BackButton_pressed():
	resign()


func _start_game():
	StartPanel.visible = false
	game = true
	status = 0
	ProgressBar.set_value(0)


func _on_Button_pressed():
	ProgressBar.set_value(ProgressBar.get_value() + 2)

func _process(_delta):
	if game:
		ProgressBar.set_value(ProgressBar.get_value() - 0.1)
		if ProgressBar.get_value() < 60 and ProgressBar.get_value() > 50:
			status += 1
		else:
			status = 0
		if status >= 500:
			game = false
			StartPanel.visible = true
