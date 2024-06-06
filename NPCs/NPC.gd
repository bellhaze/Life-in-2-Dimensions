extends Area3D

@onready var head: AnimatedSprite3D = $Head
@onready var body: AnimatedSprite3D = $Body
@onready var timer: Timer = $GreetingTimer
@onready var audio: AudioStreamPlayer = $AudioStreamPlayer3D

# Set per NPC in the level. Since the spritesheets are inconsistent in the 
# facing direction, we can't rely on the sign of scale.x
@export var facing_left = true
@export var is_ghost = false
var ghost_stretch_duration = 1.0
var greeted = false
# Is set in _ready() to store the default position of the head (varies by
# sprite) to allow for head bob calculations
var head_pos =0.0

func _ready() -> void:
	if is_ghost:
		scale.y = 0.01
		Dimension.dimension_shifted.connect(stretch_ghost)
	
	head_pos = head.position.y
	body.frame_changed.connect(func():
		if body.animation == "idle":
			head.position.y = head_pos + body.frame * 0.05
		)


func _on_body_entered(player) -> void:
	if player.name != "Player":
		return
	#flip sprite if player is not in the facing direction
	if player.position.x > position.x and facing_left:
		flip_sprite()
	if player.position.x < position.x and not facing_left:
		flip_sprite()
	
	if not greeted:
		head.play("greet")
		body.play("greet")
		audio.play()
		player.greet()	# ⚠ assumes greet function exists on "Player"
		greeted = true
		timer.start()


func flip_sprite() -> void:
	scale.x = -scale.x
	facing_left = !facing_left


func _on_greeting_timer_timeout() -> void:
	head.play("happy")
	body.play("idle")


func stretch_ghost(new_dimension) -> void:
	var tween := create_tween()
	var scale_target := 0.001 if new_dimension == "2D" else 1.0
	tween.tween_property(self, "scale:y", scale_target, Dimension.SHIFT_DURATION)
