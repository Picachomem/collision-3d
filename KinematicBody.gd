extends KinematicBody

var Projectile = preload("res://Projectile.tscn")

var canjump = false
var aux

var space
var look_dir = Vector3()
var ray_cast_down = Vector3()
var result = false

var prev_transform = Vector3()
var velocity = Vector3()
var vertical_velocity = Vector3(0, -40, 0)
var residual = Vector3()
var velocity_x = Vector3()
var velocity_z = Vector3()
var unrotated_velocity = Vector3()
var input_velocity_x = Vector3()
var input_velocity_z = Vector3()

var speed = 8
var accel_inc_x = 0
var accel_inc_z = 0
var acceleration = 0.4

var MOUSE_SENSITIVITY = 0.06
var camera_angle = 0

onready var camera = self.get_child(1)
onready var scene = self.get_parent()


func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	return


func get_input():
	input_velocity_x = Vector3()
	input_velocity_z = Vector3()
	if Input.is_action_pressed('right'):
		input_velocity_z.z -= 1
	if Input.is_action_pressed('left'):
		input_velocity_z.z += 1
	if Input.is_action_pressed('down'):
		input_velocity_x.x += 1
	if Input.is_action_pressed('up'):
		input_velocity_x.x -= 1

	if (input_velocity_x.length() == 0):
		accel_inc_x -= acceleration
		accel_inc_x = max(accel_inc_x, 0)
		velocity_x = velocity_x.normalized() * accel_inc_x
	if (input_velocity_z.length() == 0):
		accel_inc_z -= acceleration
		accel_inc_z = max(accel_inc_z, 0)
		velocity_z = velocity_z.normalized() * accel_inc_z

	if (input_velocity_x.rotated(Vector3(0,1,0), rotation.y).angle_to(velocity) >= PI/2):
		accel_inc_x = acceleration
	if (input_velocity_z.rotated(Vector3(0,1,0), rotation.y).angle_to(velocity) >= PI/2):
		accel_inc_z = acceleration

	if (input_velocity_x.length() > 0):
		accel_inc_x += acceleration
		accel_inc_x = min(accel_inc_x, speed)
		velocity_x = input_velocity_x * accel_inc_x
	if (input_velocity_z.length() > 0):
		accel_inc_z += acceleration
		accel_inc_z = min(accel_inc_z, speed)
		velocity_z = input_velocity_z * accel_inc_z

	if ((input_velocity_x + input_velocity_z).rotated(Vector3(0,1,0), rotation.y).angle_to(velocity) > PI/4):
		residual = velocity * 0.96
		
	velocity = velocity_x + velocity_z #+ residual
	velocity = velocity.rotated(Vector3(0,1,0), rotation.y)
	velocity += residual

	residual /= 2
	if (residual.length() < 0.4):
		residual = Vector3()
	
	if (velocity.length() > speed):
		velocity = velocity.normalized() * speed


func _physics_process(delta):

	get_input()
#	move_and_slide(velocity)
	move_and_collide(velocity * delta)
	move_and_collide(vertical_velocity * delta)
	
	canjump = false
	
	if (is_on_floor()):
		print("floor")
	
	if (pow(pow(prev_transform.y - global_transform.origin.y,2), 0.5) <= 0.000003):
		canjump = true
		if (vertical_velocity.y <=0):
			vertical_velocity = Vector3(0,0,0)

	space = get_world().direct_space_state
	ray_cast_down = global_transform.origin
	ray_cast_down.y -= 1.4
	result = space.intersect_ray(global_transform.origin, ray_cast_down, [self])
	
	if (result.size() == 0):
		vertical_velocity.y -= 1.4
		vertical_velocity.y = max(vertical_velocity.y, -50)

	else:
		vertical_velocity = Vector3(0,0,0)
		
	prev_transform = global_transform.origin


func _input(event):
	if (!(event is InputEventMouseMotion) and !(Input.is_action_just_pressed("ui_accept"))
	and !(Input.is_action_just_pressed("l_click"))):
		return
		
	if (Input.is_action_pressed("l_click")):
		var a = Projectile.instance()
		scene.add_child(a)
		look_dir = (camera.get_child(0).global_transform.origin - camera.global_transform.origin).normalized()
		aux = camera.global_transform.origin
		aux.y -= 0.2
		a.global_transform.origin = aux
		a.vel = look_dir * 70
#		a.rotation_degrees.y = camera.rotation_degrees.y
#		a.rotation_degrees.x = rotation_degrees.x
#		a.rotation_degrees.z = rotation_degrees.z
#		print(a.rotation_degrees)
#		aux = camera.global_transform
#		aux.origin += Vector3(-10, 0, 0).rotated(Vector3(0,1,0), self.rotation.y)
#		a.global_transform = aux
#		a.vel = aux.origin - camera.global_transform.origin
#		print (a.vel)

	if (event is InputEventMouseMotion):
		rotation_degrees.y -= MOUSE_SENSITIVITY * event.relative.x
	
		var change = -event.relative.y * MOUSE_SENSITIVITY
		if (camera_angle + change < 90 and camera_angle + change > -90):
			camera.rotation_degrees.x -= MOUSE_SENSITIVITY * event.relative.y
			camera_angle += change

	if (Input.is_action_just_pressed("ui_accept")) and canjump:
		vertical_velocity += Vector3(0,24,0)
