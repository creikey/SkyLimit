extends CPUParticles2D

func _ready():
	one_shot = true
	get_tree().create_timer(lifetime).connect("timeout", self, "_timeout")

func _timeout():
	queue_free()
