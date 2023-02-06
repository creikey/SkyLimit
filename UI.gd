extends Control

onready var hearts = [
	$Hearts/Heart1,
	$Hearts/Heart2,
	$Hearts/Heart3,
]

func _input(event):
	if event is InputEventMouseMotion:
		$HowManyLeft.rect_position = event.position/2.0 - Vector2($HowManyLeft.rect_size.x/2.0, $HowManyLeft.rect_size.y/2.0)

func _process(_delta):
	rect_position.y = -get_viewport().canvas_transform.get_origin().y
	var left: int = get_node("../ChunkPlacer").chunks_left()
	if left == 0:
		$HowManyLeft.set("custom_colors/font_color", Color.red)
	else:
		$HowManyLeft.set("custom_colors/font_color", Color.white)
	$HowManyLeft.text = str(left)

	for h_i in range(0, hearts.size()):
		var h: Node2D = hearts[h_i]
		h.visible = h_i < get_node("../Player").lives
	
	if get_node("../Player").lives == 0:
		get_tree().paused = true
		$Died.visible = true
