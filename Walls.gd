extends StaticBody2D

func _process(_delta):
	global_position.y = -get_viewport().canvas_transform.get_origin().y
	for s in [$LeftSprite, $RightSprite]:
		s.region_rect.position.y = global_position.y
