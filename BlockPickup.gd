extends Area2D

export var chance_of_deleting: float = 0.5

var enabled: bool = false

func _ready():
	randomize()
	if rand_range(0.0, 1.0) < chance_of_deleting:
		queue_free()
	var chunk: Chunk = get_parent().get_parent()
	var _err = chunk.connect("frozen", self, "on_frozen")

func on_frozen():
	modulate.a = 1.0
	enabled = true


func _on_BlockPickup_body_entered(body):
	if body is Player:
		body.on_collect_pickup()
		queue_free()
