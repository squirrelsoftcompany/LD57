extends MultiMeshInstance3D


@export var cube_count := 100
@export var cluster_radius := 5.0
@export var is_mine : bool = false

func generate_instances():
	var random = RandomNumberGenerator.new()
	random.randomize()
	
	for i in range(cube_count):
		var new_position = Transform3D()
		new_position = new_position.translated(Vector3(randfn(0.0,0.2) * cluster_radius, randfn(0.0,0.2) * cluster_radius, randfn(0.0,0.2) * cluster_radius))
		multimesh.set_instance_transform(i, new_position)
	if is_mine:
		get_child(0).multimesh = multimesh

func _ready():
	generate_instances()
	
