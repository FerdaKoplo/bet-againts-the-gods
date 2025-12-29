extends Label

var is_showing := false

func _ready():
	visible = false
	process_mode = Node.PROCESS_MODE_ALWAYS

func show_message(msg: String):
	text = msg
	visible = true
	is_showing = true
	get_tree().paused = true

func hide_message():
	visible = false
	is_showing = false
	get_tree().paused = false

func _unhandled_input(event):
	if not is_showing:
		return

	if event.is_action_pressed("interact"):
		hide_message()
