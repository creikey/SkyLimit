extends Sprite

export var likelihood: float = 0.5

func _ready():
	randomize()
	if rand_range(0.0, 1.0) < likelihood:
		visible = true
	else:
		visible = false
