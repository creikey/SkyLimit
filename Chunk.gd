extends RigidBody2D

class_name Chunk

signal frozen
signal placed

export var one_way_platform: bool = false

onready var tile: TileMap = $TileMap

var frozen: bool = false
var placed: bool = false
var being_dropped_through: bool = false
var player_passed_through_me: bool = false
var frames_since_waiting_for_player_to_pass_through_me: int = 0

func _ready():
	$Debug.set_as_toplevel(true)
	
	set_can_collide(false)
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

func _physics_process(_delta):
	if one_way_platform:
		assert(has_node("TileMap/PlayerOverlapArea"))
		var overlap_area: Area2D = $TileMap/PlayerOverlapArea
		var player: RigidBody2D = get_tree().get_nodes_in_group("players")[0]
		if being_dropped_through:
			var overlapping = overlap_area.get_overlapping_bodies()
			var player_overlapping: bool = false
			for o in overlapping:
				if o.is_in_group("players"):
					player_overlapping = true
					break
			print(player_overlapping)
			if player_passed_through_me:
				if not player_overlapping:
					being_dropped_through = false
			else:
				frames_since_waiting_for_player_to_pass_through_me += 1
				if frames_since_waiting_for_player_to_pass_through_me >= 10:
					player_passed_through_me = true
				if player_overlapping:
					player_passed_through_me = true
				
		if not being_dropped_through and placed and player.linear_velocity.y > -1.0:
			set_collision_layer_bit(1, true)
			set_collision_mask_bit(1, true)
		else:
			set_collision_layer_bit(1, false)
			set_collision_mask_bit(1, false)

func drop():
	assert(one_way_platform)
	being_dropped_through = true
	player_passed_through_me = false
	frames_since_waiting_for_player_to_pass_through_me = 0

func get_overlapping_in_layer(layer: int) -> Array:
	var space_state: Physics2DDirectSpaceState = get_world_2d().direct_space_state
	var shape := RectangleShape2D.new()
	var tile_size := Vector2(8.0, 8.0)
	shape.extents = tile_size/2.0
	for t in tile.get_used_cells():
		var tile_pos: Vector2 = tile.to_global(tile.map_to_world(t))
		tile_pos += (tile_size/2.0).rotated(tile.global_rotation)
		var trans := Transform2D(tile.global_rotation, tile_pos)
		var params := Physics2DShapeQueryParameters.new()
		params.collision_layer = layer
		var scale_before = $Debug.scale
		$Debug.global_transform = trans
		$Debug.scale = scale_before
		params.set_shape(shape)
		params.transform = trans
		var result = space_state.intersect_shape(params) 
		if result:
			return result
	return []

func overlapping() -> bool:
	if get_overlapping_in_layer(1).size() > 0:
		return true
	return false

func freeze():
	frozen = true
	emit_signal("frozen")
	set_deferred("mode", RigidBody2D.MODE_STATIC)
	$TileMap.material = preload("res://frozen.tres")

func set_scale(s: Vector2):
	$TileMap.scale = s

func set_can_collide(can: bool):
	set_collision_layer_bit(0, can)
	set_collision_mask_bit(0, can)
	if one_way_platform:
		pass
	else:
		set_collision_layer_bit(1, can)
		set_collision_mask_bit(1, can)

func place():
	placed = true
	emit_signal("placed")
	set_can_collide(true)
	mode = RigidBody2D.MODE_STATIC
	$FallTimer.start()

func _on_FallTimer_timeout():
	if frozen:
		return
	sleeping = false
	mode = RigidBody2D.MODE_RIGID
	gravity_scale = 0.5
