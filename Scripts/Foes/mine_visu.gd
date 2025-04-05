extends MultiMeshInstance3D


@export var cube_count = 100
@export var cluster_radius = 5.0

func generate_instances():
	var instances = []
	var random = RandomNumberGenerator.new()
	random.randomize()
	
	for i in range(cube_count):
		var position = Transform3D()
		var position_old = position
		position = position.translated(Vector3(randfn(0.0,0.2) * cluster_radius, randfn(0.0,0.2) * cluster_radius, randfn(0.0,0.2) * cluster_radius))
		print(position_old.origin - position.origin)
		multimesh.set_instance_transform(i, position)

func _ready():
	generate_instances()
	
