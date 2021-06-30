extends AnimationTree


func _ready():
	# Default Non-Zero Parameters
	# Penguin
	self.walk_lower_and_upper('PedestrianAdd', 0)
	self.walk_lower_and_upper('PedestrianBlend', 1)
	self.set("parameters/mouth/add_amount", 1)
	# Customer
	self.set("parameters/Customer/sit loop/add_amount", 1)
	# Chef
	self.set("parameters/Chef/cook deep fryer left and right/add_amount", 1)
	self.set("parameters/Chef/cook stove left and right/add_amount", 1)
	# Waiter
	self.set("parameters/Waiter/waiter right and left/add_amount", 1)
	self.active = true	


# Routine Mixer
func walk_or_routine(blend_amount: float):
	# Separates Pedestrian and Routine Animations
	self.set("parameters/walk or routine/blend_amount", blend_amount)


func routine_and_walk(add_amount: float):
	# Combines Routine and Pedestrian Animations
	self.set("parameters/routine and walk/add_amount", add_amount)


# Penguin
func switch_routine_mixer(add_amount: float):
	self.set("parameters/switch routine mixer/add_amount", add_amount)


func walk_lower_and_upper(blend_tree: String, add_amount: float):
	self.set("parameters/%s/walk loop/add_amount" % blend_tree, add_amount)


func walk_arms_still_or_sway(blend_tree: String, blend_amount: float):
	self.set("parameters/%s/walk loop upper/blend_amount" % blend_tree, blend_amount)


func mouth_closed_or_open(blend_amount: float):
	self.set("parameters/mouth closed or open/blend_amount", blend_amount)


func vocalize(active: bool):
	self.set("parameters/vocalize/active", active)


func look_horizontal(add_amount: float):
	self.set("parameters/look horizontal/add_amount", add_amount)


func look_up(add_amount: float):
	self.set("parameters/look up/add_amount", add_amount)


# Customer
func sit_arms_still_or_flap(blend_amount: float):
	self.set("parameters/Customer/flap/blend_amount", blend_amount)


func eat(add_amount: float):
	self.set("parameters/Customer/eat/add_amount", add_amount)


# Waiter
func hold_other_or_carry_order(blend_amount: float):
	self.set("parameters/Waiter/waiter left hold or carry/blend_amount", blend_amount)


func pick_up(active: bool):
	self.set("parameters/Waiter/waiter left carry or pick up/active", active)
