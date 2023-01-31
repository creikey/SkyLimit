extends Node2D


func _on_ChunkPlacer_up_next_changed(new_up_next):
	for c in get_children():
		c.queue_free()
	
	var cur_vertical_offset: float = 0.0
	for n in new_up_next:
		var new: Node2D = n.instance()
		add_child(new)
		new.set_scale(Vector2(0.3, 0.3))
		new.position.y = cur_vertical_offset
		var maximum_blocks_tall: float = 12.0
		cur_vertical_offset += 0.4*8.0*maximum_blocks_tall
		
