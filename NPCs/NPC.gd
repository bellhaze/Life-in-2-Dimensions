extends Area3D

@onready var head = $Head
@onready var body = $Body
@onready var timer = $GreetingTimer
@onready var audio = $AudioStreamPlayer3D

@export var facing_left = true
@export var is_ghost = false
var greeted = false
var stretching = false
var head_pos =0.0
signal npc_greeted

func _ready():
	if is_ghost:
		scale.y = 0.01
		visible = false
	head_pos = head.position.y
		
func _process(delta):
	if is_ghost:
		if stretching and Dimension.shifting:
			if Dimension.d == "2D":
				visible = true
				if scale.y < 1.0:
					scale.y += 0.05
				else:
					scale.y = 1.0
					stretching = false
			elif Dimension.d == "3D":
				if scale.y > 0.01:
					scale.y -= 0.06
				else:
					scale.y = 0.01
					visible = false
					stretching = false
		if Input.is_action_just_pressed("Mode Shift"):
			stretching = true
		
	if body.animation == "idle":
		head.position.y = head_pos + body.frame * 0.05
			

func _on_body_entered(player):
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
		player.greet()
		greeted = true
		emit_signal("npc_greeted")
		timer.start()
		
		
func flip_sprite():
	scale.x = -scale.x
	facing_left = !facing_left

func _on_greeting_timer_timeout():
	head.play("happy")
	body.play("idle")
