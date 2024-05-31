extends Camera3D

@export var view_width = 15.0
@export_range(1.0, 179.0) var fov_2d = 1.0
@export_range(1.0, 179.0) var fov_3d = 75.0
@export var shifting_speed = 3.0

@onready var zoom_in = $ZoomIn
@onready var zoom_out = $ZoomOut


var cam_dist = 859

func _process(delta):
	if Input.is_action_just_pressed("Mode Shift") and not Dimension.shifting:
		Dimension.shifting = true
		if Dimension.d == "2D":
			zoom_in.play()
		elif Dimension.d == "3D":
			zoom_out.play()
	if Dimension.shifting:
		shift_mode(delta)
		
func shift_mode(delta):
	if Dimension.d == "3D":
		if fov > fov_2d:
			fov = clampf(fov - (fov_3d - fov_2d) * delta * shifting_speed, fov_2d, fov_3d)
			cam_dist = view_width / (2 * tan(deg_to_rad(fov)/2))
			position.z = cam_dist
			get_node("../").rotate_cam(0.5/(fov_3d - fov_2d))
		else:
#			projection = Camera3D.PROJECTION_ORTHOGONAL
			Dimension.shifting = false
			Dimension.d = "2D"
			return
			
	elif Dimension.d == "2D":
#		projection = Camera3D.PROJECTION_PERSPECTIVE
		if fov < fov_3d:
			fov = clampf(fov + (fov_3d - fov_2d) * delta * shifting_speed, fov_2d, fov_3d)
			cam_dist = view_width / (2 * tan(deg_to_rad(fov)/2))
			position.z = cam_dist
			get_node("../").rotate_cam(-0.5/(fov_3d - fov_2d))
		else:
			Dimension.shifting = false
			Dimension.d = "3D"
			return
#	print("cam_dist = " , cam_dist)
#	print("camera position.z = " , position.z)
	


