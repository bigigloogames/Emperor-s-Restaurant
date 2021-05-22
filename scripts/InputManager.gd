extends Reference


static func pressed(event: InputEvent):
	return (
		event is InputEventMouseButton
		and event.pressed
		and (
			event.button_index == BUTTON_LEFT
			or event.button_index == BUTTON_RIGHT
		)
	)
