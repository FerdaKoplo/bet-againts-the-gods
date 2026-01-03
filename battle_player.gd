extends TextureButton

signal health_changed(new_hp, max_hp)

var hp = 100
var max_hp = 100
var status_effects = []
var is_defending = false 

func _ready() -> void:
	health_changed.emit(hp, max_hp)

func take_damage(amount):
	if is_defending:
		amount = ceil(amount / 2.0)
		print("GUARD AKTIF! Damage berkurang menjadi: ", amount)
	
	hp -= amount
	
	if hp < 0:
		hp = 0
	
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
