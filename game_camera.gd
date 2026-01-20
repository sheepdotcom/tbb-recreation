extends Camera3D

func _process(delta: float):
	var direction = Vector3.ZERO
	
	# TODO: speed multipliers from ctrl or shift
	var speed = 1
	
	if Input.is_action_pressed("move_left"):
		direction.x -= 1
	if Input.is_action_pressed("move_right"):
		direction.x += 1
	
	# probably not needed but whatever who knows what if more than just moving along the x-axis?
	if direction != Vector3.ZERO:
		direction = direction.normalized()
	
	position += direction * speed * delta
