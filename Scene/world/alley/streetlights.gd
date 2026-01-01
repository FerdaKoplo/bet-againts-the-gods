extends Node2D

@export var min_energy: float = 0.8
@export var max_energy: float = 2.5
@export var flicker_speed: float = 70.0


@export var stable_duration_min: float = 2.0  
@export var stable_duration_max: float = 6.0
@export var flicker_duration_min: float = 0.5
@export var flicker_duration_max: float = 1.5


var light_states = {}

func _process(delta: float) -> void:
	var time = Time.get_ticks_msec() / 1000.0
	
	for i in get_child_count():
		var light = get_child(i)
		
		if light is PointLight2D:
			var id = light.get_instance_id()
			
			# 1. Initialize data if this light is new (hasn't been tracked yet)
			if not light_states.has(id):
				light_states[id] = {
					"is_flickering": false,
					"timer": randf_range(0.0, stable_duration_max) # Random start
				}
			
			# 2. Countdown the timer for this specific light
			light_states[id]["timer"] -= delta
			
			# 3. Switch states when timer hits zero
			if light_states[id]["timer"] <= 0:
				if light_states[id]["is_flickering"]:
					# Stop flickering -> Become Stable
					light_states[id]["is_flickering"] = false
					light_states[id]["timer"] = randf_range(stable_duration_min, stable_duration_max)
				else:
					# Stop being stable -> Start Flickering
					light_states[id]["is_flickering"] = true
					light_states[id]["timer"] = randf_range(flicker_duration_min, flicker_duration_max)
			
			# 4. Apply the visual effect based on current state
			if light_states[id]["is_flickering"]:
				# --- THIS IS YOUR FLICKER LOGIC ---
				var unique_offset = i * 20.5 
				var noise = sin((time + unique_offset) * flicker_speed)
				
				var random_glitch = randf()
				if random_glitch > 0.96: 
					noise -= 2.0 
				
				light.energy = clamp(noise + 1.5, min_energy, max_energy)
			else:
				# --- STABLE STATE ---
				# Smoothly return to max_energy so it doesn't snap awkwardly
				light.energy = move_toward(light.energy, max_energy, delta * 5.0)
