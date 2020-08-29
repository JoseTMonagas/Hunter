extends KinematicBody
class_name Enemy

signal killed

const GRAVITY: int = -96
const GROWLING_SFX: Array = [
	preload("res://Enemy/sfx/growl_1.wav"),
	preload("res://Enemy/sfx/growl_2.wav"),
	preload("res://Enemy/sfx/growl_3.wav")
]

var velocity: Vector3 = Vector3.ZERO
var is_active: bool = false
var health: int = 100
var can_attack: bool = false
var player: Player
var difficulty: float = 1.0

onready var animation_player: AnimationPlayer = $AnimationPlayer
onready var attack_cooldown: Timer = $AttackCooldown
onready var hit_timer: Timer = $HitTimer
onready var growling_sfx: AudioStreamPlayer3D = $GrowlSfx
onready var growling_cd: Timer = $GrowlCooldown
onready var blood_particles: CPUParticles = $BloodParticles


func _ready():
	player = get_tree().get_nodes_in_group("player")[0]
	growling_sfx.stream = GROWLING_SFX[randi() % GROWLING_SFX.size()]


func _physics_process(_delta: float):
	if ! can_attack && hit_timer.is_stopped():
		animation_player.play("walk")
		velocity = move_and_slide(_speed(), Vector3.UP)
	elif can_attack && attack_cooldown.is_stopped():
		animation_player.play("attack")


func attack() -> void:
	player.take_damage()
	attack_cooldown.start()


func take_damage(damage: int, particles_pos: Vector3) -> void:
	blood_particles.global_transform.origin = particles_pos
	blood_particles.emitting = true
	hit_timer.start()
	health -= damage
	animation_player.play("hurt")
	if health <= 0:
		emit_signal("killed")
		queue_free()


func _speed() -> Vector3:
	var player_position: Vector3 = player.global_transform.origin
	var self_position: Vector3 = global_transform.origin

	var enemies: Array = get_tree().get_nodes_in_group("enemies")

	var speed: Vector3 = (player_position - self_position).normalized() * difficulty
	speed.y += GRAVITY

	for enemy in enemies:
		if enemy != self:
			var dist: Vector3 = global_transform.origin - enemy.global_transform.origin
			if 0 < dist.length() && dist.length() < 3:
				speed += dist.normalized()

	return speed


func _on_AttackRange_body_entered(body: KinematicBody):
	if body == player:
		can_attack = true


func _on_AttackRange_body_exited(body: KinematicBody):
	if body == player:
		can_attack = false


func _on_GrowlCooldown_timeout():
	growling_sfx.play()
	growling_cd.start(randi() % 20 + 8)
