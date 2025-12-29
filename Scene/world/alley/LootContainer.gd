extends Area2D

var player_in_range := false
var looted := false

func _on_body_entered(body):
	print("Body masuk:", body.name)
	if body.name == "player":
		player_in_range = true

func _on_body_exited(body):
	print("Body keluar:", body.name)
	if body.name == "player":
		player_in_range = false

func _process(delta):
	if player_in_range and not looted:
		if Input.is_action_just_pressed("interact"):
			print("E ditekan")
			loot()

func loot():
	looted = true
	print("LOOT BERHASIL!")
	$Sprite2D.modulate = Color(0.5, 0.5, 0.5)
