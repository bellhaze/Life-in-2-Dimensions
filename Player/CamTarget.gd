extends Node3D


func _ready() -> void:
	var angle_2d := 0.0
	var angle_3d := -TAU/60
	Dimension.dimension_shifted.connect(func(new_dimension):
		var tween := create_tween()
		var start_angle = angle_2d if new_dimension == "3D" else angle_3d
		var end_angle = angle_2d if new_dimension == "2D" else angle_3d
		tween.tween_method(rotate_cam, start_angle, end_angle, Dimension.SHIFT_DURATION)
		)


func rotate_cam(angle) -> void:
	rotation.x = angle
