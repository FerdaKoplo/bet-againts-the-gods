extends TileMapLayer

var target_opacity: float = 1.0
@export var fade_speed: float = 8.0

func _process(delta: float) -> void:
	modulate.a = move_toward(modulate.a, target_opacity, fade_speed * delta)
