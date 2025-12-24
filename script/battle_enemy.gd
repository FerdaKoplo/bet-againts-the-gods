extends TextureButton

# Mengambil referensi Health Bar (biarkan saja, jangan dihapus)
@onready var _atb_bar: ATBHealthBar = $ATBHealthBar

# Status dasar musuh
var max_hp = 100
var hp = 100
var enemy_name = "Enemy"

func _ready() -> void:
	_atb_bar.hide()
	hp = max_hp # Set darah penuh saat mulai

# Fungsi untuk menerima serangan
func take_damage(amount):
	hp -= amount
	print(enemy_name + " terkena " + str(amount) + " damage! Sisa HP: " + str(hp))
	
	if hp <= 0:
		die()

# Fungsi saat mati
func die():
	print(enemy_name + " kalah!")
	queue_free() # Menghapus musuh dari layar
