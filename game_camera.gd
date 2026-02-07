extends Camera3D

var speed := 16.0

func _process(delta: float):
	var direction = Vector3.ZERO
	
	var speed_mult := 1.0
	
	if Input.is_action_pressed("move_left"):
		direction.x -= 1.0
	if Input.is_action_pressed("move_right"):
		direction.x += 1.0
	
	if Input.is_action_pressed("camera_speed_up"):
		speed_mult *= 2.0
	if Input.is_action_pressed("camera_speed_down"):
		speed_mult *= 0.5
	
	# probably not needed but whatever who knows what if more than just moving along the x-axis?
	if direction != Vector3.ZERO:
		direction = direction.normalized()
	
	position += direction * speed * speed_mult * delta
