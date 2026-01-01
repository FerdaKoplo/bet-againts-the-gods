extends TextureButton

# [1] TULIS INI AGAR MUNCUL DI LIST SIGNAL
signal health_changed(new_hp, max_hp)

var hp = 100
var max_hp = 100
var status_effects = [] 

# [2] HAPUS baris @onready var health_bar ... agar tidak error
# (Jangan pakai %HealthBar lagi)

func _ready() -> void:
	# [3] Kirim signal saat mulai
	health_changed.emit(hp, max_hp)

func take_damage(amount):
	hp -= amount
	
	# [4] Kirim signal saat kena damage
	health_changed.emit(hp, max_hp)
	
	print("Player terkena " + str(amount) + " damage! Sisa HP: " + str(hp))
	
	modulate = Color(1, 0, 0)
	await get_tree().create_timer(0.1).timeout
	check_puppet_color()

func apply_status(effect_name):
	if effect_name not in status_effects:
		status_effects.append(effect_name)
		print(">>> STATUS MASUK: " + effect_name + " <<<")
		check_puppet_color()

func check_puppet_color():
	if "puppet" in status_effects:
		modulate = Color(0.7, 0, 1) 
	else:
		modulate = Color(1, 1, 1) 

func is_controlled():
	return "puppet" in status_effects
