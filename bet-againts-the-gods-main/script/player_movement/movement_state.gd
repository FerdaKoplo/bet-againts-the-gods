extends Node


enum MovementState {
	IDLE,
	MOVING_UP,
	MOVING_DOWN,
	MOVING_RIGHT,
	MOVING_LEFT,
}


const ANIMATIONS = {
	"movement": {
		MovementState.MOVING_UP: "move_up",
		MovementState.MOVING_DOWN: "move_down",
		MovementState.MOVING_LEFT: "move_left",
		MovementState.MOVING_RIGHT: "move_right",
	},

}
