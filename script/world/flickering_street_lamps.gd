extends Node2D


func _process(delta: float) -> void:
	# Loop through every single light
	for light in get_children():
		if light is PointLight2D:
			# Give each light a unique random chance to flicker
			# changing 0.05 makes it flicker more/less often
			if randf() < 0.10: 
				light.energy = randf_range(0.5, 1.0)
			else:
				# Slowly return to normal (stabilize)
				light.energy = move_toward(light.energy, 1.0, delta * 2.0)
