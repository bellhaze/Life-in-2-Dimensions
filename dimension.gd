extends Node

signal dimension_shifted
const SHIFT_DURATION := 0.3
@export_enum("2D", "3D") var d : String = "2D" :
	set(new_dimension):
		d = new_dimension
		dimension_shifted.emit(new_dimension)
