extends Node2D

const BULLET_HOLE = preload("res://Player/Bullet/BulletHole.png")
const BULLET_WOUND = preload("res://Player/Bullet/BulletWound.png")

onready var timer: Timer = $Timer


func create(bullet_type: String, bullet_position: Vector2) -> void:
	position = bullet_position
	match bullet_type:
		"HOLE":
			$Sprite.texture = BULLET_HOLE
		"WOUND":
			$Sprite.texture = BULLET_WOUND
	timer.start()


func _on_Timer_timeout():
	queue_free()
