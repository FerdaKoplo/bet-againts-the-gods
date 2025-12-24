extends TextureRect

# Angka ini akan muncul di Inspector.
# Coba ubah X jadi positif (misal 10 atau 20) agar panah masuk ke dalam kotak.
@export var cursor_offset: Vector2 = Vector2(10, 0) 

func _ready() -> void:
	visible = false
	# Auto-detect tombol apapun yang difokus
	get_viewport().gui_focus_changed.connect(_on_focus_changed)

func _on_focus_changed(control: Control) -> void:
	if control is BaseButton:
		visible = true
		
		# Ambil posisi kiri-atas tombol
		var target_pos = control.global_position
		
		# Hitung posisi tengah vertikal tombol (biar panah pas di tengah tinggi tombol)
		var center_y_button = control.size.y / 2.0
		var center_y_cursor = size.y / 2.0
		
		# Rumus Posisi Akhir:
		# X = Posisi Kiri Tombol + Offset X kamu
		# Y = Posisi Atas Tombol + Setengah Tinggi Tombol - Setengah Tinggi Panah + Offset Y kamu
		
		global_position.x = target_pos.x + cursor_offset.x
		global_position.y = target_pos.y + center_y_button - center_y_cursor + cursor_offset.y
		
	else:
		visible = false
