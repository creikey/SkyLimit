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
	var space_state = get_world_2d().direct_space_state
	var result: Dictionary = space_state.intersect_ray($CastFrom.global_position, body.global_position,[],2)
	if enabled and body is Player and not result.empty() and result.collider.is_in_group("players"):
		body.hurt(1)
		body.apply_central_impulse((Vector2(0, -1).rotated(global_rotation)).normalized()*300.0)
