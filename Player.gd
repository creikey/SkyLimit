extends RigidBody2D

const move_force_floor: float = 600.0
const move_force_air: float = 300.0
const held_down_gravity_multiply: float = 0.5
const jump_impulse: float = 230.0

var jumping: bool = false

onready var jump_casts = [
	$JumpCast,
	$JumpCast2,
	$JumpCast3,
]

func can_jump() -> bool:
	for j in jump_casts:
		if j.is_colliding():
			return true
	return false
	
func _physics_process(_delta):
	applied_force = Vector2()
	for j in jump_casts:
		j.rotation = -global_rotation
	var move_force: float
	if can_jump():
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

func _input(event):
	if event.is_action_pressed("jump") and can_jump():
		apply_central_impulse(Vector2(0, -jump_impulse))
		jumping = true
	elif event.is_action_released("jump"):
		jumping = false
