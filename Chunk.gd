extends RigidBody2D

class_name Chunk

onready var tile: TileMap = $TileMap

func _ready():
	set_collision_layer_bit(0, false)
	set_collision_mask_bit(0, false)
	gravity_scale = 0.0
	
	# adjust center of mass
	assert(tile != null)
	var total := Vector2()
	var total_mass: float = 0.0
	for t in tile.get_used_cells():
		total += tile.map_to_world(t) + tile.cell_size/2.0
		total_mass += 1.0
	mass = total_mass/5.0
	var local_center_of_mass: Vector2 = total / total_mass
	tile.position = -local_center_of_mass

func freeze():
	mode = RigidBody2D.MODE_STATIC
	$TileMap.material = preload("res://frozen.tres")

func set_scale(s: Vector2):
	$TileMap.scale = s

func place():
	set_collision_layer_bit(0, true)
	set_collision_mask_bit(0, true)
	gravity_scale = 1.0
