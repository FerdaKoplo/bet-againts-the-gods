extends Control

enum States {
	OPTIONS,
	TARGETS,
}

var state: States = States.OPTIONS

@onready var _options: WindowDefault = $Options
@onready var _options_menu: Menu = $Options/Options
@onready var _enemies_menu: Menu = $Enemies

func _ready() -> void:
	_options_menu.button_focus(0)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		match state:
			States.OPTIONS:
				pass
			States.TARGETS:
				state = States.OPTIONS
				_options_menu.button_focus()
	
func _on_options_button_focused(button: BaseButton) -> void:
	pass
	
func _on_options_button_pressed(button: BaseButton) -> void:
	match button.text:
		"Attack":
			state = States.TARGETS
			_enemies_menu.button_focus()
			
