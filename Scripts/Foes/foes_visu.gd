extends MultiMeshInstance3D


@export var cube_count = 100
@export var cluster_radius = 5.0

func generate_instances():
	var random = RandomNumberGenerator.new()
	random.randomize()
	
	for i in range(cube_count):
		var position = Transform3D()
		position = position.translated(Vector3(randfn(0.0,0.2) * cluster_radius, randfn(0.0,0.2) * cluster_radius, randfn(0.0,0.2) * cluster_radius))
		multimesh.set_instance_transform(i, position)

func _ready():
	generate_instances()
	
