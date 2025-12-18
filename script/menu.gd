class_name Menu extends Control

signal button_focused(button: BaseButton)
signal button_pressed(button: BaseButton)

@export var auto_wrap: bool = true

var index: int = 0

func _ready() -> void:
	for button in get_buttons():
		button.focus_exited.connect(_on_Button_focus_exited.bind(button))
		button.focus_entered.connect(_on_Button_focused.bind(button))
		button.pressed.connect(_on_Button_pressed.bind(button))
		
	if !auto_wrap:
		return
	
	var _class: String = get_class()
	var buttons: Array = get_buttons()
	var use_this_on_grid_containers: bool = false
	
	if use_this_on_grid_containers and get("columns"):
		var top_row: Array = []
		var bottom_row: Array = []
		var cols: int = self.columns
		@warning_ignore("integer_division")
		var rows: int = roundi(buttons.size() / cols)
		var btm_range: Array = [rows * cols - cols, rows * cols - 1]
		
		for x in cols:
			top_row.append(buttons[x])
		for x in range(btm_range[0], btm_range[1]):
			if x > buttons.size():
				bottom_row.append(buttons[x - cols])
				continue
			bottom_row.append(buttons[x])
		
		for x in cols:
			var top_button: BaseButton = top_row[x]
			var bottom_button: BaseButton = bottom_row[x]
			if top_button == bottom_button:
				continue
			top_button.focus_neighbor_top = bottom_button.get_path()
			bottom_button.focus_neighbor_bottom = top_button.get_path()
			
		for i in range(0, buttons.size(), cols):
			var left_button: BaseButton = buttons[i]
			var right_button: BaseButton = buttons[i + cols - 1]
			left_button.focus_neighbor_left = right_button.get_path()
			right_button.focus_neighbor_right = left_button.get_path()
	elif _class.begins_with("VBox"):
		var top_button: BaseButton = buttons.front()
		var bottom_button: BaseButton = buttons.back()
		top_button.focus_neighbor_top = bottom_button.get_path()
		bottom_button.focus_neighbor_bottom = top_button.get_path()
	elif _class.begins_with("HBox"):
		var first_button: BaseButton = buttons.front()
		var last_button: BaseButton = buttons.back()
		first_button.focus_neighbor_left = last_button.get_path()
		last_button.focus_neighbor_right = first_button.get_path()
		
	button_enable_focus(false)
		
func get_buttons() -> Array:
	return get_children()
	
func connect_to_buttons(target: Object, _name: String = name) -> void:
	var callable: Callable = Callable()
	callable = Callable(target, "_on_" + _name + "_focused")
	button_focused.connect(callable)
	callable = Callable(target, "_on_" + _name + "_pressed")
	button_pressed.connect(callable)
	
func button_enable_focus(on: bool) -> void:
	var mode: FocusMode = FocusMode.FOCUS_ALL if on else FocusMode.FOCUS_NONE
	for button in get_buttons():
		button.set_focus_mode(mode)	

func button_focus(n: int = index) -> void:
	button_enable_focus(true)
	var button: BaseButton = get_buttons()[n]
	button.grab_focus()
	
func _on_Button_focus_exited(_button: BaseButton) -> void:
	await get_tree().process_frame
	if not get_viewport().gui_get_focus_owner() in get_buttons():
		button_enable_focus(false)

func _on_Button_focused(button: BaseButton) -> void:
	index = button.get_index()
	emit_signal("button_focused", button)
	
func _on_Button_pressed(button: BaseButton) -> void:
	emit_signal("button_pressed", button)
