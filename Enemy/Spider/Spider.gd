extends KinematicBody
class_name Spider

signal killed

const GRAVITY: int = 96

var velocity: Vector3 = Vector3.ZERO
var player: Player
var is_attacking: bool = false
var health: int = 2
var jump_point: Vector3
var difficulty: float = 1.0

onready var animation_player: AnimationPlayer = $Model/AnimationPlayer
onready var hit_timer: Timer = $HitTimer
onready var blood_particles: CPUParticles = $BloodParticles


func _ready():
	player = get_tree().get_nodes_in_group("player")[0]
	rotate_x(180)


func _physics_process(_delta: float) -> void:
	var distance_to_player: float = global_transform.origin.distance_to(jump_point)

	if ! is_attacking:
		animation_player.play("walk")

	velocity = move_and_slide(_speed(distance_to_player), Vector3.UP)


func _speed(distance_to_player: float) -> Vector3:
	var player_position: Vector3 = jump_point
	var self_position: Vector3 = global_transform.origin

	var speed: Vector3 = (player_position - self_position).normalized() * difficulty

	if distance_to_player > 3:
		speed.y += GRAVITY

	return speed if hit_timer.is_stopped() else Vector3.ZERO


func take_damage(damage: int, particle_pos: Vector3) -> void:
	blood_particles.global_transform.origin = particle_pos
	blood_particles.emitting = true
	hit_timer.start()
	health -= damage
	if health <= 0:
		emit_signal("killed")
		queue_free()


func _on_AttackRange_body_entered(body: KinematicBody):
	
	if body == player:
		player.take_damage()
