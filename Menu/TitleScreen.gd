extends Spatial


onready var animation_player: AnimationPlayer = $AnimationPlayer


func _ready():
	animation_player.play("InsertDick")
	pass


func _on_NewGame_pressed():
	get_tree().change_scene("res://Map/Map.tscn")


func _on_ExitGame_pressed():
	get_tree().quit()


func _on_InsertCoin_pressed():
	get_tree().change_scene("res://Map/Map.tscn")
	pass # Replace with function body.
