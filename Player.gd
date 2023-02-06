extends RigidBody2D

class_name Player

signal collected_pickup
signal hurt

const max_velocity: float = 500.0
const move_force_floor: float = 600.0 + 350.0
const move_force_air: float = 150.0
const held_down_gravity_multiply: float = 0.5
const jump_impulse: float = 230.0
const wall_jump_up_impulse: float = jump_impulse * 0.8
const wall_jump_impulse: float = 100.0

var lives: int = 3
var jumping: bool = false

onready var jump_casts = [
	$NoRotation/JumpCast,
	$NoRotation/JumpCast2,
	$NoRotation/JumpCast3,
]

onready var wall_casts = [
	$NoRotation/WallCastLeft,
	$NoRotation/WallCastRight,
]

func _ready():
	for j in jump_casts:
		j.add_exception(self)
	for w in wall_casts:
		w.add_exception(self)
		

func hurt(amount_lives: int):
	lives -= amount_lives
	$Hurt.play()
	emit_signal("hurt")

func on_floor() -> bool:
	for j in jump_casts:
		if j.is_colliding():
			return true
	return false

func touching_wall() -> bool:
	for w in wall_casts:
		if w.is_colliding():
			return true
	return false

func on_collect_pickup():
	$Pickup.play()
	emit_signal("collected_pickup")

func _physics_process(_delta):
	applied_force = Vector2()
	$NoRotation.rotation = -global_rotation
	var move_force: float
	if on_floor():
		move_force = move_force_floor
	else:
		move_force = move_force_air
	
	if linear_velocity.y > 0.0:
		jumping = false
	
	if jumping:
		gravity_scale = held_down_gravity_multiply
	else:
		gravity_scale = 1.0
	
	applied_force += Vector2(Input.get_action_strength("right") - Input.get_action_strength("left"), 0.0)*move_force

func _integrate_forces(state):
	if state.linear_velocity.length() >= max_velocity:
		state.linear_velocity = state.linear_velocity.normalized() * max_velocity

func _input(event):
	if not jumping and event.is_action_pressed("jump") and on_floor():
		apply_central_impulse(Vector2(0, -jump_impulse))
		$Jump.pitch_scale = rand_range(0.9, 1.1)
		$Jump.play()
		var new_particle: Node2D = preload("res://JumpParticles.tscn").instance()
		get_parent().add_child(new_particle)
		new_particle.global_position = global_position
		jumping = true
	if not on_floor() and event.is_action_pressed("jump") and touching_wall():
		var horizontal_impulse_direction: float = 0.0
		$SideJump.play()
		if $NoRotation/WallCastLeft.is_colliding():
			horizontal_impulse_direction = 1.0
			var new_particle: Node2D = preload("res://RightParticles.tscn").instance()
			get_parent().add_child(new_particle)
			new_particle.global_position = global_position
		else:
			horizontal_impulse_direction = -1.0
			var new_particle: Node2D = preload("res://RightParticles.tscn").instance()
			get_parent().add_child(new_particle)
			new_particle.global_position = global_position
			new_particle.scale.x = -1.0
		apply_central_impulse(Vector2(horizontal_impulse_direction*wall_jump_impulse, -wall_jump_up_impulse))
		jumping = true
	if event.is_action_released("jump"):
		jumping = false
