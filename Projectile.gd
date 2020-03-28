extends KinematicBody

var vel
var did
var result = null

func _physics_process(delta):
	result = null
	if (vel.length() > 0):
		did = move_and_collide(delta * vel)
		if (did):
			queue_free()

