extends AnimationTree


func _ready():
	# Default Non-Zero Parameters
	# Penguin
	self.set("parameters/mouth/add_amount", 1)
	self.set("parameters/walk loop/add_amount", 1)
	# Customer
	self.set("parameters/Customer/sit loop/add_amount", 1)
	# Chef
	self.set("parameters/Chef/cook deep fryer left and right/add_amount", 1)
	self.set("parameters/Chef/cook stove left and right/add_amount", 1)
	# Waiter
	self.set("parameters/Waiter/waiter right and left/add_amount", 1)
	self.active = true	


func walk_or_sit(blend_amount: float):
	# TODO: Refactor to accomodate employee routines.
	self.set("parameters/walk or routine/blend_amount", blend_amount)


func walk_arms_still_or_sway(blend_amount: float):
	self.set("parameters/walk loop upper/blend_amount", blend_amount)


func sit_arms_still_or_flap(blend_amount: float):
	self.set("parameters/flap/blend_amount", blend_amount)


func eat(add_amount: float):
	self.set("parameters/eat/add_amount", add_amount)


func mouth_closed_or_open(blend_amount: float):
	self.set("parameters/mouth closed or open/blend_amount", blend_amount)


func vocalize(active: bool):
	self.set("parameters/vocalize/active", active)


func look_horizontal(add_amount: float):
	self.set("parameters/look horizontal/add_amount", add_amount)


func look_up(add_amount: float):
	self.set("parameters/look up/add_amount", add_amount)
