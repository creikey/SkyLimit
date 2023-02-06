extends RigidBody2D

class_name Chunk

signal frozen
signal placed

onready var tile: TileMap = $TileMap

func _ready():
	$Debug.set_as_toplevel(true)
	
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

var trans_debug := Transform2D()


func overlapping() -> bool:
	update()
	var space_state: Physics2DDirectSpaceState = get_world_2d().direct_space_state
	var shape := RectangleShape2D.new()
	var tile_size := Vector2(8.0, 8.0)
	shape.extents = tile_size/2.0
	for t in tile.get_used_cells():
		var tile_pos: Vector2 = tile.to_global(tile.map_to_world(t))
		tile_pos += (tile_size/2.0).rotated(tile.global_rotation)
		var trans := Transform2D(tile.global_rotation, tile_pos)
		var params := Physics2DShapeQueryParameters.new()
		var scale_before = $Debug.scale
		$Debug.global_transform = trans
		$Debug.scale = scale_before
		params.set_shape(shape)
		params.transform = trans
		if space_state.intersect_shape(params):
			return true
	return false

func freeze():
	emit_signal("frozen")
	mode = RigidBody2D.MODE_STATIC
	$TileMap.material = preload("res://frozen.tres")

func set_scale(s: Vector2):
	$TileMap.scale = s

func place():
	emit_signal("placed")
	set_collision_layer_bit(0, true)
	set_collision_mask_bit(0, true)
	gravity_scale = 0.5
