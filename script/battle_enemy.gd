extends TextureButton

@onready var _atb_bar: ATBHealthBar = $ATBHealthBar

func _ready() -> void:
	_atb_bar.hide()
