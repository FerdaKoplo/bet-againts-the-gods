extends TextureButton

var hp = 100
var max_hp = 100
var status_effects = [] # Tas untuk menyimpan semua penyakit/kutukan

func take_damage(amount):
	hp -= amount
	print("Player terkena " + str(amount) + " damage! Sisa HP: " + str(hp))
	
	# Efek visual sederhana saat kena hit (berkedip merah)
	modulate = Color(1, 0, 0)
	await get_tree().create_timer(0.1).timeout
	check_puppet_color() # Kembalikan warna (atau tetap ungu jika puppet)

func apply_status(effect_name):
	# Fungsi ini dipanggil oleh Boss saat Phase 2
	if effect_name not in status_effects:
		status_effects.append(effect_name)
		print(">>> STATUS MASUK: " + effect_name + " <<<")
		check_puppet_color()

func check_puppet_color():
	# Jika sedang jadi Puppet, warna jadi UNGU
	if "puppet" in status_effects:
		modulate = Color(0.7, 0, 1) # Ungu Gelap
	else:
		modulate = Color(1, 1, 1) # Putih Normal

# Fungsi untuk mengecek apakah player masih sadar atau dikendalikan
func is_controlled():
	return "puppet" in status_effects
