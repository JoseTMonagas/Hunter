extends Spatial


func _on_NewGame_pressed():
	get_tree().change_scene("res://Map/Map.tscn")


func _on_ExitGame_pressed():
	get_tree().quit()
