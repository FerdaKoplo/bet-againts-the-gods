extends TextureButton

# Mengambil referensi Health Bar
@onready var _atb_bar: ATBHealthBar = $ATBHealthBar

# Status dasar musuh
var max_hp = 500
var hp = 500
var enemy_name = "Enemy"

func _ready() -> void:
	hp = max_hp 
	
	# --- UPDATE BAR ---
	if _atb_bar:
		_atb_bar.max_value = max_hp
		_atb_bar.value = hp
		_atb_bar.show() # Pastikan terlihat

# Fungsi untuk menerima serangan
func take_damage(amount):
	hp -= amount
	
	# --- UPDATE BAR SAAT KENA DAMAGE ---
	if _atb_bar:
		_atb_bar.value = hp
		
	print(enemy_name + " terkena " + str(amount) + " damage! Sisa HP: " + str(hp))
	
	if hp <= 0:
		die()

func die():
	print(enemy_name + " kalah!")
	queue_free()
