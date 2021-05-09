extends ScrollContainer

onready var HBox = $HBoxContainer


# Called when the node enters the scene tree for the first time.
func _ready():
	HBox.set("custom_constants/separation", 400)
	for x in 10:
		var control = Control.new()
		var recipe_panel = Panel.new()
		recipe_panel.rect_size.x = 100
		recipe_panel.rect_size.y = 200
		recipe_panel.rect_position.x = 100
		var recipe_label = Label.new()
		recipe_label.text = "Recipe Name"
		recipe_panel.add_child(recipe_label)
		var recipe_button = Button.new()
		recipe_button.text = "Learn"
		recipe_button.rect_position.y = 200
		recipe_panel.add_child(recipe_button)
		control.add_child(recipe_panel)
		HBox.add_child(control)


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
