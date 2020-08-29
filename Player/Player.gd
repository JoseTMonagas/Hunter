extends KinematicBody
class_name Player

signal wave_start

const Bullet := preload("res://Player/Bullet/Bullet.tscn")

const CURSOR := preload("res://Player/crosshair110.png")
const CURSOR_CORRECTION: Vector2 = Vector2(35, 35)
const BULLET_DISTANCE: int = 7
const BULLET_TEXTURE := preload("res://Player/bullet.png")
const MAX_AMMO: int = 7
const MAX_LIFE: int = 3
const HURT_SFX: Array = [
	preload("res://Player/sfx/hurt_1.wav"),
	preload("res://Player/sfx/hurt_2.wav"),
	preload("res://Player/sfx/hurt_3.wav")
]
const DEATH_SFX := preload("res://Player/sfx/killed.wav")
const WAVE_END_BONUS: int = 100

var ammo: int = MAX_AMMO
var life: int = MAX_LIFE
var score: int = 0
var accumulated_score: int = 0

onready var animation_player: AnimationPlayer = $AnimationPlayer
onready var camera: Camera = $Camera
onready var light: SpotLight = $SpotLight
onready var shot_cooldown: Timer = $ShotCooldown
onready var reloading_timer: Timer = $Reloading
onready var gunshot_sfx: AudioStreamPlayer2D = $Gunshot
onready var hurt_sfx: AudioStreamPlayer = $HurtSfx
onready var hud: CanvasLayer = $HUD
onready var hud_bullet: HBoxContainer = $HUD/GUI/Rows/Bullets
onready var hud_hearts: HBoxContainer = $HUD/GUI/Rows/Hearts
onready var reloading_label: Label = $HUD/GUI/Rows/ReloadingLabel
onready var wave_label: Label = $HUD/GUI/Rows/WaveLabel
onready var score_label: Label = $HUD/GUI/Rows/ScoreLabel


func _ready() -> void:
	Input.set_custom_mouse_cursor(CURSOR)


func _physics_process(_delta: float):
	_update_score()
	if ! reloading_timer.is_stopped():
		reloading_label.text = (
			"- "
			+ tr("RELOADING")
			+ " "
			+ str(stepify(reloading_timer.time_left, 0.01))
			+ " -"
		)


func _input(event: InputEvent):
	if event is InputEventMouseMotion:
		var project_position: Vector3 = camera.project_position(
			event.position + CURSOR_CORRECTION, 4
		)
		light.look_at(project_position, Vector3.UP)

	if event is InputEventMouseButton && event.is_pressed():
		match event.button_index:
			1:
				if ammo > 0 && shot_cooldown.is_stopped() && reloading_timer.is_stopped():
					_play_gunshot_sfx(event.position + CURSOR_CORRECTION)
					_bullet_effect("HOLE", event.position + CURSOR_CORRECTION)
					ammo -= 1
					var collision: Dictionary = _shot_raycast(event.position + CURSOR_CORRECTION)
					if ! collision.empty():
						if collision.collider.has_method("take_damage"):
							collision.collider.take_damage(50, collision.position)
							_bullet_effect("WOUND", event.position + CURSOR_CORRECTION)
			2:
				reloading_timer.start()
		_update_bullet_count()


func take_damage() -> void:
	life -= 1
	_update_life_count()
	animation_player.play("Hurt")
	hurt_sfx.stream = HURT_SFX[randi() % HURT_SFX.size()]
	hurt_sfx.play()
	if life <= 0:
		hurt_sfx.stream = DEATH_SFX
		hurt_sfx.play()
		(get_tree().change_scene("res://Menu/GameOver.tscn"))


func add_points(points: int) -> void:
	accumulated_score += points


func _update_score() -> void:
	  var points: int = lerp(score, accumulated_score, 2)
	  score_label.text = tr("PLAYER_SCORE_LABEL" + ": " + str(score) + " +" + str(points))
	  score += points


func _start_wave() -> void:
	var wave_number: int = get_parent().wave_count
	wave_label.text = tr("PLAYER_WAVE_START" + " " + str(wave_number))
	animation_player.play("WaveStart")
	yield(animation_player, "animation_finished")
	wave_label.text = ""
	life = MAX_LIFE
	ammo = MAX_AMMO
	emit_signal("wave_start")


func _end_wave() -> void:
	wave_label.text = tr("PLAYER_WAVE_FINISHED")
	add_points(WAVE_END_BONUS)
	var timer: SceneTreeTimer = get_tree().create_timer(1)
	yield(timer, "timeout")
	_start_wave()

func _update_life_count() -> void:
	var life_points: Array = hud_hearts.get_children()
	var current_life: int = 1
	for life_point in life_points:
		if current_life > life:
			life_point.visible = false
		else:
			life_point.visible = true
		current_life += 1


func _update_bullet_count() -> void:
	var bullets: Array = hud_bullet.get_children()
	var current_bullet: int = 1
	for bullet in bullets:
		if current_bullet > ammo:
			bullet.visible = false
		else:
			bullet.visible = true
		current_bullet += 1


func _shot_raycast(position: Vector2) -> Dictionary:
	var from: Vector3 = camera.project_ray_origin(position)
	var to: Vector3 = from + camera.project_ray_normal(position) * BULLET_DISTANCE

	var space_state: PhysicsDirectSpaceState = get_world().direct_space_state
	return space_state.intersect_ray(from, to, [self])


func _play_gunshot_sfx(position: Vector2) -> void:
	gunshot_sfx.position = position
	gunshot_sfx.play()


func _bullet_effect(type: String, position: Vector2) -> void:
	var bullet: Node = Bullet.instance()
	hud.add_child(bullet)
	bullet.create(type, position)


func _on_Reloading_timeout() -> void:
	ammo = 7
	_update_bullet_count()
	reloading_label.text = ""


func _on_Map_round_end():
	_end_wave()
