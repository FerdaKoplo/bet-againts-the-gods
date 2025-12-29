extends Area2D

@onready var loot_message = get_tree().get_first_node_in_group("loot_message")

var player_in_range := false
var looted := false
var player_ref: CharacterBody2D

func _on_body_entered(body):
	if body.is_in_group("player"):
		player_in_range = true
		player_ref = body

func _on_body_exited(body):
	if body.is_in_group("player"):
		player_in_range = false
		player_ref = null

func _process(_delta):
	if player_in_range and not looted:
		if Input.is_action_just_pressed("interact"):
			loot()

func loot():
	if player_ref == null:
		return

	looted = true

	var roll = randi() % 100
	var item_name := ""
	var amount := 1

	if roll < 50:
		item_name = "Dirt"
	elif roll < 85:
		item_name = "Gold"
		amount = randi_range(1, 5)
	else:
		item_name = "Health Potion"

	if loot_message:
		loot_message.show_message("Mendapat %s x%d" % [item_name, amount])

	player_ref.add_item(item_name, amount)
