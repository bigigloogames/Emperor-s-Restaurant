extends ScrollContainer

onready var HBox = $HBoxContainer


# Called when the node enters the scene tree for the first time.
func _ready():
	HBox.set("custom_constants/separation", 400)
	var recipes = File.new()
	if not recipes.file_exists("res://assets/src/recipes.json"):
		return
	recipes.open("res://assets/src/recipes.json", File.READ)
	while not recipes.eof_reached():
		var recipe = parse_json(recipes.get_line())
		var control = Control.new()
		var recipe_panel = Panel.new()
		recipe_panel.rect_size.x = 200
		recipe_panel.rect_size.y = 200
		recipe_panel.rect_position.x = 100
		var recipe_label = Label.new()
		recipe_label.text = recipe["name"]
		recipe_panel.add_child(recipe_label)
		var ingredients = recipe["ingredients"]
		var ingredient_label = Label.new()
		for ingredient in ingredients:
			ingredient_label.text += '\n'
			ingredient_label.text += ingredient
		recipe_panel.add_child(ingredient_label)
		var recipe_button = Button.new()
		recipe_button.text = "Learn"
		recipe_button.rect_position.y = 200
		recipe_panel.add_child(recipe_button)
		control.add_child(recipe_panel)
		HBox.add_child(control)
	recipes.close()


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
