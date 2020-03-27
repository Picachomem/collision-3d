extends KinematicBody

#var residual_velocity = Vector3()
#var velocity = Vector3()
#var unrotated_velocity = Vector3()
#var input_velocity = Vector3()
#
#var speed = 16
#var speed_build = 0
#var deccel = 16
#var acceleration = 0.4
#
#var MOUSE_SENSITIVITY = 0.06
#var camera_angle = 0
#
#onready var camera = self.get_child(1)
#
#func _ready():
#	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
#	return
#
#
#func get_input():
#	# Detect up/down/left/right keystate and only move when pressed.
#	input_velocity = Vector3()
#	if Input.is_action_pressed('right'):
#		input_velocity.z -= 1
#	if Input.is_action_pressed('left'):
#		input_velocity.z += 1
#	if Input.is_action_pressed('down'):
#		input_velocity.x += 1
#	if Input.is_action_pressed('up'):
#		input_velocity.x -= 1
#
#
##	if (input_velocity.length() == 0):
##	speed_build -= (acceleration * 1.6)
##	speed_build = max(0, speed_build)
##
##	velocity = velocity.normalized() * speed_build
#
#	deccel -= acceleration * 1.6
#	deccel = max(0, deccel)
#
#	residual_velocity = velocity.normalized() * deccel
#
##	else:
#	if (input_velocity.length() != 0):
#		speed_build += acceleration
#		speed_build = min(speed, speed_build)
#
#		velocity = (input_velocity.normalized() + residual_velocity) * speed_build
#
#		if (unrotated_velocity.angle_to(velocity) >= (PI/2 - 1)):
#			speed_build = acceleration
#			velocity = (input_velocity.normalized() + residual_velocity) * speed_build
#
#		unrotated_velocity = velocity
#		velocity = velocity.rotated(Vector3(0,1,0), rotation.y)
#
##		velocity += residual_velocity
##		velocity /= 2
#
#func _physics_process(delta):
#
#	get_input()
##	velocity =
#	move_and_collide(velocity * delta)
#
#
#func _input(event):
#	if !(event is InputEventMouseMotion):
#		return
#
#	rotation_degrees.y -= MOUSE_SENSITIVITY * event.relative.x
#
#	var change = -event.relative.y * MOUSE_SENSITIVITY
#	if (camera_angle + change < 90 and camera_angle + change > -90):
#		camera.rotation_degrees.x -= MOUSE_SENSITIVITY * event.relative.y
#		camera_angle += change

var velocity = Vector3()
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

#	if (input_velocity_x.rotated(Vector3(0,1,0), rotation.y).angle_to(Vector3(velocity.x,0,0)) > 0.6):
#		residual.x = velocity.x
#		print("aaa")
#	if (input_velocity_z.rotated(Vector3(0,1,0), rotation.y).angle_to(Vector3(0,0,velocity.z)) > 0.6):
#		residual.z = velocity.z
#		print("aaa")
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
	move_and_collide(velocity * delta)


func _input(event):
	if !(event is InputEventMouseMotion):
		return

	rotation_degrees.y -= MOUSE_SENSITIVITY * event.relative.x

	var change = -event.relative.y * MOUSE_SENSITIVITY
	if (camera_angle + change < 90 and camera_angle + change > -90):
		camera.rotation_degrees.x -= MOUSE_SENSITIVITY * event.relative.y
		camera_angle += change


