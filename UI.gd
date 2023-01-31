extends Control

func _process(_delta):
	rect_position.y = -get_viewport().canvas_transform.get_origin().y
	var left: int = get_node("../ChunkPlacer").chunks_left()
	if left == 0:
		$HowManyLeft.set("custom_colors/font_color", Color.red)
	else:
		$HowManyLeft.set("custom_colors/font_color", Color.white)
	$HowManyLeft.text = str(left)
