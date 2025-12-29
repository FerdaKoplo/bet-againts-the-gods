extends Node2D

signal roll_finished(value)

var dice_nodes: Array[Sprite2D] = []

func _ready():
	# Memasukkan referensi node. Pastikan tipe nodenya adalah Sprite2D
	dice_nodes = [
		$Dadu1, $Dadu2, $Dadu3, $Dadu4, $Dadu5, $Dadu6
	]
	
	# Sembunyikan semua dan reset frame ke 0
	for d in dice_nodes:
		d.visible = false
		d.frame = 0
	
	visible = false

func hide_all():
	for d in dice_nodes:
		d.visible = false

func roll() -> int:
	visible = true
	var timer = 0.0
	var roll_duration = 0.8 # Lama dadu mengocok
	
	# --- FASE 1: MENGOCOK (SHUFFLE) ---
	# Kita tampilkan dadu secara acak dengan frame acak agar terlihat cepat
	while timer < roll_duration:
		hide_all()
		
		# Pilih dadu acak (0 sampai 5 indexnya)
		var random_index = randi() % 6
		var active_dice = dice_nodes[random_index]
		
		active_dice.visible = true
		# Ubah frame secara acak (0-5) agar terlihat berputar liar
		active_dice.frame = randi() % 6 
		
		# Kecepatan ganti gambar saat mengocok
		await get_tree().create_timer(0.05).timeout
		timer += 0.05
	
	# --- FASE 2: MENDARAT (LANDING) ---
	hide_all()
	
	# Tentukan angka hasil akhir (1-6)
	var final_value = randi_range(1, 6)
	
	# Ambil node yang sesuai (Index array = nilai - 1)
	var final_dice = dice_nodes[final_value - 1]
	final_dice.visible = true
	
	# --- ANIMASI MENDARAT ---
	# Kita mainkan frame dari 0 sampai 5 (frame terakhir) pada dadu yang terpilih
	# Asumsi gambar kamu memiliki 6 frame (sesuai Hframes 6)
	for i in range(6):
		final_dice.frame = i
		# Jeda antar frame agar gerakan terlihat (0.1 detik)
		await get_tree().create_timer(0.1).timeout
	
	# Pastikan berhenti di frame terakhir (gambar angka dadu yang jelas)
	final_dice.frame = 5 
	
	print("Dadu mendarat di angka: ", final_value)
	
	# Tunggu sebentar sebelum signal dikirim
	await get_tree().create_timer(0.5).timeout
	
	visible = false
	roll_finished.emit(final_value)
	return final_value
