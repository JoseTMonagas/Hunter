extends Node
class_name Command

signal done
signal next

var history: Array = []
var queue: Array = []

onready var parent = get_parent()


func process_queue() -> void:
	var current = queue.pop_front()
	if current != null:
		history.push_back(current)
		_process_command(current)
		yield(self, "next")
		process_queue()
	emit_signal("done")


func add_to_queue(command: Dictionary) -> void:
	queue.push_back(command)


func undo() -> void:
	var current = history.pop_front()
	if current != null:
		queue.push_back(current)
		_process_command(current, true)
		yield(self, "next")
		undo()
	emit_signal("done")


func _process_command(command: Dictionary, undo: bool = false) -> void:
	var process: String = command.process
	var value: Vector3 = command.value

	if undo:
		value *= -1

	match process:
		"MOVE":
			parent._move(value)
		"ROTATE":
			parent._rotate(value)

	yield(parent, "finished")
	emit_signal("next")
