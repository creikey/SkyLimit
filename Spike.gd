extends Area2D

export var chance_is_destroyed: float = 0.3

var enabled: bool = false

func _ready():
	randomize()
	if rand_range(0.0, 1.0) < chance_is_destroyed:
		queue_free()
	var chunk: Chunk = get_parent().get_parent()
	var _err = chunk.connect("placed", self, "on_placed")

func on_placed():
	enabled = true

func _on_Spike_body_entered(body):
	if enabled and body is Player:
		body.hurt(1)
		body.apply_central_impulse((Vector2(0, -1).rotated(global_rotation)).normalized()*300.0)
