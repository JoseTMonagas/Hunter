extends Spatial

signal round_end

const Mutant: PackedScene = preload("res://Enemy/Mutant/Mutant.tscn")
const Spider: PackedScene = preload("res://Enemy/Spider/Spider.tscn")

var enemy_count: int = 0
var max_enemy_count: int = 3
var min_enemy_count: int = 2
var wave_count: int = 1
var last_wave: int = wave_count

onready var wave_spawns: Timer = $WaveSpawns
onready var enemy_spawn: Timer = $EnemySpawns
onready var mutant_spawn_1: Position3D = $MutantSpawns/SpawnPoint
onready var mutant_spawn_2: Position3D = $MutantSpawns/SpawnPoint2
onready var mutant_spawn_3: Position3D = $MutantSpawns/SpawnPoint3
onready var spider_spawn_1: Position3D = $SpiderSpawns/SpiderSpawn
onready var spider_spawn_2: Position3D = $SpiderSpawns/SpiderSpawn2
onready var spider_spawn_3: Position3D = $SpiderSpawns/SpiderSpawn3
onready var jump_point: Position3D = $JumpPoint
onready var player: Player = $Player


func _ready() -> void:
	player._start_wave()


func _create_enemy(enemy: KinematicBody, pos: Vector3) -> void:
	enemy.difficulty += wave_count * 0.15
	$Enemies.add_child(enemy)
	enemy.add_to_group("enemies")
	enemy.global_transform.origin = pos
	enemy_count += 1
	var err = enemy.connect("killed", self, "_on_Enemy_killed")
	if err:
		enemy.queue_free()
		enemy_count -= 1


func _create_mutant(spawn: int) -> void:
	  var enemy: Enemy = Mutant.instance()
	  var pos: Vector3 = get("mutant_spawn_" + str(spawn)).global_transform.origin
	  _create_enemy(enemy, pos)


func _create_spider(spawn: int) -> void:
	  var enemy: Spider = Spider.instance()
	  var pos: Vector3 = get("spider_spawn_" + str(spawn)).global_transform.origin
	  enemy.jump_point = jump_point.transform.origin
	  _create_enemy(enemy, pos)


func _wave_start() -> void:
	min_enemy_count += wave_count
	max_enemy_count += round(wave_count * 1.25)
	wave_count += 1
	wave_spawns.wait_time += wave_count
	wave_spawns.start()
	enemy_spawn.start()


func _on_Enemy_killed() -> void:
	player.add_points(10)
	enemy_count -= 1
	if enemy_count <= 0:
		emit_signal("round_end")


func _on_Player_wave_start():
	_wave_start()


func _on_EnemySpawns_timeout():
	if ! wave_spawns.is_stopped() && enemy_count <= max_enemy_count:
		var random_enemy: int = randi() % 2 + 1
		var random_pos : int = randi() % 3 + 1
		match(random_enemy):
			1:
				_create_mutant(random_pos)
			2:
				_create_spider(random_pos)
		
		enemy_spawn.wait_time = rand_range(0.5, 2)

