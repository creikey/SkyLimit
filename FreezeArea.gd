extends Area2D

func _on_FreezeArea_body_entered(body):
	if body is Chunk:
		body.freeze()
