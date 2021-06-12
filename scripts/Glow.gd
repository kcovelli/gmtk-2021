extends Node

export(int) var shape # EmissionShape enum
export(Vector2) var extents # If given a box shape
export(float) var radius # If given a sphere shape

func _ready():
	var material = $Particles2D.process_material
	material.emission_shape = shape
	material.emission_box_extents = Vector3(extents.x, extents.y, 1)
	material.emission_sphere_radius = radius
