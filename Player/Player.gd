extends CharacterBody3D

@onready var sprites = $Sprites
@onready var head = $Sprites/Head
@onready var body = $Sprites/Body
@onready var timer = $GreetingTimer
@onready var jump_sound = $Jump

@export var facing_left = false
var is_greeting = false

const SPEED = 8.0
const JUMP_VELOCITY = 15.0

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")


func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta
		
	# Handle Jump.
	if Input.is_action_just_pressed("Jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		head.play("jump")
		body.play("jump")
		jump_sound.play()
	if not is_on_floor():
		if Input.is_action_pressed("Jump"):
			velocity.y -= 0.5
		else:
			velocity.y -= 1.0

	# Get the input direction and handle the movement/deceleration.
	if Dimension.d == "2D":
		velocity.z = 0
		if position.z > 0.25:
			velocity.z -= position.z * 25
		elif position.z < -0.25:
			velocity.z -= position.z * 25
		if position.z > -0.25 and position.z < 0.25:
			position.z = 0.0
		var input_dir = Input.get_axis("Left", "Right")
		var direction = (transform.basis * Vector3(input_dir, 0, 0)).normalized()
		if direction:
			velocity.x = direction.x * SPEED
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)
	elif Dimension.d == "3D":
		var input_dir = Input.get_vector("Left", "Right", "Up", "Down")
		var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
		if direction:
			velocity.x = direction.x * SPEED
			velocity.z = direction.z * SPEED
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)
			velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()
	# invisible barrier at front of level
	position.z = minf(position.z, 19.0)
	
	# handle sprite flipping
	if velocity.x > 0 and facing_left:
		flip_sprite()
	elif velocity.x < 0 and not facing_left:
		flip_sprite()
	
	# handle animations
	if not is_greeting:
		if is_on_floor():
			head.play("idle")
			if velocity == Vector3.ZERO:
				body.play("idle")
			else:
				body.play("walk")
		if velocity.y < 0:
			body.play("fall")
		
	# handle head position and angle
	if body.animation == "fall":
		head.position.x = 0.4
		head.rotation.z = deg_to_rad(-15)
	elif body.animation == "walk":
		head.position.x = -0.03 + body.frame * 0.05
		head.rotation.z = 0
	else:
		head.position.x = 0.1
		head.rotation.z = 0
		
func flip_sprite():
	sprites.scale.x = -sprites.scale.x
	facing_left = !facing_left
	
func greet():
	body.play("greet")
	head.play("greet")
	is_greeting = true
	timer.start()

func _on_greeting_timer_timeout():
	is_greeting = false
