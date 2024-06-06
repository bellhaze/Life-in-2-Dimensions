extends CharacterBody3D

@onready var sprites: Node3D = $Sprites
@onready var head: AnimatedSprite3D = $Sprites/Head
@onready var body: AnimatedSprite3D = $Sprites/Body
@onready var greeting_timer: Timer = $GreetingTimer
@onready var jump_sound: AudioStreamPlayer = $Jump

@export var facing_left = false

const SPEED := 8.0
const JUMP_VELOCITY := 15.0

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")


func _ready() -> void:
	body.animation_changed.connect(_on_animation_changed)
	body.frame_changed.connect(_on_frame_changed)


func _physics_process(delta: float) -> void:
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
		if 0.25 > position.z and position.z > -0.25:
			position.z = 0.0
			velocity.z = 0.0
		else:
			velocity.z = -position.z * delta * SPEED * 60.0
		var input_dir = Input.get_axis("Left", "Right")
		var direction = (transform.basis * Vector3(input_dir, 0, 0)).normalized()
		velocity.x = direction.x * SPEED
	
	elif Dimension.d == "3D":
		var input_dir = Input.get_vector("Left", "Right", "Up", "Down")
		var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED

	move_and_slide()
	# invisible barrier at front of level
	position.z = minf(position.z, 19.0)


func _process(delta: float) -> void:
	# handle sprite flipping
	if velocity.x > 0 and facing_left:
		flip_sprite()
	elif velocity.x < 0 and not facing_left:
		flip_sprite()
	
	# handle animations
	if greeting_timer.is_stopped():
		if is_on_floor():
			head.play("idle")
			if velocity == Vector3.ZERO:
				body.play("idle")
			else:
				body.play("walk")
		if velocity.y < 0:
			body.play("fall")


#region handle head position and angle
func _on_animation_changed() -> void:
	if body.animation == "fall":
		head.position.x = 0.4
		head.rotation.z = deg_to_rad(-15)
	elif body.animation == "walk":
		head.position.x = -0.03
		head.rotation.z = 0
	else:
		head.position.x = 0.1
		head.rotation.z = 0


func _on_frame_changed() -> void:
	if body.animation != "walk":
		return
	head.position.x = -0.03 + body.frame * 0.05
	head.rotation.z = 0
#endregion


func flip_sprite() -> void:
	sprites.scale.x = -sprites.scale.x
	facing_left = !facing_left


# called from NPC.gd when player enters the Area3D
func greet() -> void:
	body.play("greet")
	head.play("greet")
	greeting_timer.start()
