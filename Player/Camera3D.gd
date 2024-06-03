extends Camera3D

# Width, in metres, of the visible portion of the level left and right of the
# player whether in 2D or 3D
@export var view_width := 15.0
@export_range(1.0, 179.0) var fov_2d := 1.0
@export_range(1.0, 179.0) var fov_3d := 75.0

@onready var zoom_in: AudioStreamPlayer = $ZoomIn
@onready var zoom_out: AudioStreamPlayer = $ZoomOut
@onready var shift_timer: Timer = $ShiftTimer

var tween : Tween = null


func _ready() -> void:
	shift_timer.wait_time = Dimension.SHIFT_DURATION
	Dimension.dimension_shifted.connect(shift_mode)


func _process(delta) -> void:
	if shift_timer.is_stopped() and Input.is_action_just_pressed("Mode Shift"):
		Dimension.d = "2D" if Dimension.d == "3D" else "3D"
		shift_timer.start()


func shift_mode(new_dimension) -> void:
	tween = create_tween().set_parallel()
	var target_fov = fov_2d if new_dimension == "2D" else fov_3d
	tween.tween_property(self, "fov", target_fov, shift_timer.wait_time)
	tween.tween_method(dolly, fov, target_fov, shift_timer.wait_time)
	
	if new_dimension == "3D":
		zoom_out.play()
	else:
		zoom_in.play()


func dolly(current_fov) -> void:
	position.z = view_width / (2 * tan(deg_to_rad(current_fov)/2))
