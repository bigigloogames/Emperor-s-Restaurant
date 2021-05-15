extends Reference


const FRAME_DURATION = float(1)/60


static func loop_tracks(
	animation_player: AnimationPlayer,
	tracks: PoolStringArray,
	loop: bool
):
	for track in tracks:
		animation_player.get_animation(track).loop = loop


static func seek_penultimate_frame(
	animation_tree: AnimationTree,
	seek_node: String,
	animation_player: AnimationPlayer,
	track: String
):
	# Set the seek position to the second to last frame of the animation to fix the negative time scale bug
	animation_tree.set(seek_node, animation_player.get_animation(track).length - FRAME_DURATION)
