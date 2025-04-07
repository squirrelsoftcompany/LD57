extends CSGCombiner3D

@export var cavern_nb : int = 1 ## minimum 4
@export var cavern_points_nb : int = 2 ## minimum 2
@export var cavern_width : float = 0
@export var cavity_nb : int = 0
@export var cavity_max_size : float ## minimum cavern_size
@export var world_size : float = 100

var caverns : Array[Path3D]
var cavities : Array[CSGSphere3D]
var shadow : CSGCombiner3D

func _ready():
	cavity_max_size = cavity_max_size if cavity_max_size < cavern_width else cavern_width
	cavern_nb = cavern_nb if cavern_nb > 1 else 1
	cavern_points_nb = cavern_points_nb if cavern_points_nb > 2 else 2
	shadow = CSGCombiner3D.new()
	shadow.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_SHADOWS_ONLY
	add_sibling.call_deferred(shadow)
	generate_world()

func generate_world():
	var cavern_nodes : Array[Vector3] = generate_nodes()
	var rock : CSGBox3D = CSGBox3D.new()
	rock.size = Vector3(world_size*1.2,world_size*1.2,world_size*1.2)
	add_child(rock)
	shadow.add_child(rock.duplicate())
	var networked_nodes : Array[Vector3]
	for i in cavern_nb :
		var cavern_path = Path3D.new()
		cavern_path.curve = Curve3D.new()
		var second_node : Vector3
		var cavern_plan : Array[Vector3] 
		
		#selecting a node
		if i==0 :
			networked_nodes.append(cavern_nodes.pop_front())
			networked_nodes.append(cavern_nodes.pop_front())
			cavern_plan.append(networked_nodes[0])
			second_node = networked_nodes[1]
		elif cavern_nodes.size() > 0:
			second_node = networked_nodes.pick_random()
			networked_nodes.append(cavern_nodes.pop_front())
			cavern_plan.append(networked_nodes.back())
		else:
			second_node = networked_nodes.pop_front()
			cavern_plan.append(networked_nodes.pick_random())
			networked_nodes.append(second_node)

		var j : int = 0
		
		#filling between nodes
		while cavern_plan[j].distance_to(second_node) > (world_size/cavern_points_nb)*1.2:
			var dir : Vector3 = (second_node-cavern_plan[j]).normalized()*Vector3(randf_range(0.9,1.1),randf_range(0.9,1.1),randf_range(0.9,1.1))
			var dist : float = world_size/cavern_points_nb * randf_range(0.8,1.2)
			var point : Vector3 = cavern_plan[j]+(dir*dist)
			cavern_plan.append(point)
			j += 1
		cavern_plan.append(second_node)
		j += 2
		j = cavern_points_nb-j
		
		#grow cavern from one end then the other 
		@warning_ignore("integer_division")
		for k in j/2:
			var dir : Vector3 = ((cavern_plan.back()-cavern_plan[cavern_plan.size()-2])*Vector3(randf_range(0.5,2),randf_range(0.5,2),randf_range(0.5,2))).normalized()
			var dist : float = world_size/cavern_points_nb * randf_range(0.8,1.2)
			var point : Vector3 = cavern_plan.back()+(dir*dist)
			cavern_plan.append(point)
		@warning_ignore("integer_division")
		for k in j/2:
			var dir : Vector3 = ((cavern_plan[0]-cavern_plan[1])*Vector3(randf_range(0.5,2),randf_range(0.5,2),randf_range(0.5,2))).normalized()
			var dist : float = world_size/cavern_points_nb * randf_range(0.8,1.2)
			var point : Vector3 = cavern_plan[0]+(dir*dist)
			cavern_plan.push_front(point)
		
		for point in cavern_plan:
			cavern_path.curve.add_point(point)
		
		$Paths.add_child(cavern_path)
		var cavern : CSGPolygon3D = CSGPolygon3D.new()
		caverns.append(cavern_path)
		add_child(cavern)
		cavern.polygon = generate_cross_section(cavern_width*randf_range(0.8,1.2))
		cavern.mode = CSGPolygon3D.MODE_PATH
		cavern.path_node = cavern_path.get_path()
		cavern.operation = CSGShape3D.OPERATION_SUBTRACTION
		shadow.add_child(cavern.duplicate())
	generate_cavities()

func generate_nodes() -> Array[Vector3] :
	var cavern_nodes : Array[Vector3]
	var min_range : Vector3 = Vector3(-1,-1,-1)
	var max_range : Vector3 = Vector3(1,1,1)
	for i in cavern_nb -1:
		var point : Vector3 = Vector3(
			randf_range(min_range.x,max_range.x),
			randf_range(min_range.y,max_range.y),
			randf_range(min_range.z,max_range.z)
			).normalized()
		
		min_range -= point/cavern_nb
		max_range -= point/cavern_nb
		point = point * randf_range(world_size/8,world_size/4)
		cavern_nodes.append(point)
		#to show nodes positions
		#$debug.position = point
		#add_child($debug.duplicate())
	return cavern_nodes

func generate_cross_section(width : float) -> PackedVector2Array:
	@warning_ignore("narrowing_conversion")
	var nb_vertex : int = sqrt(width * PI)*2
	var cross_section : PackedVector2Array
	for i in nb_vertex:
		cross_section.append(Vector2(cos(i*(2*PI/nb_vertex)),sin(i*(2*PI/nb_vertex)))*(width/randf_range(1.8,2.2)))
	return cross_section

func generate_cavities():
	for i in cavity_nb:
		var cavity : CSGSphere3D = CSGSphere3D.new()
		cavity.radius = randf_range(cavern_width,cavity_max_size)
		@warning_ignore("narrowing_conversion")
		cavity.radial_segments = sqrt(cavity.radius * PI)
		@warning_ignore("narrowing_conversion")
		cavity.rings = sqrt(cavity.radius * PI)*2
		cavity.operation = CSGShape3D.OPERATION_SUBTRACTION
		var pos : int = randi_range(1,cavern_points_nb-2)
		cavity.position = caverns.pick_random().curve.get_point_position(pos)
		cavity.position += Vector3(randf_range(-cavity.radius,cavity.radius),randf_range(-cavity.radius,cavity.radius),randf_range(-cavity.radius,cavity.radius))
		cavity.scale = Vector3(randf_range(0.9,1.1),randf_range(0.6,1),randf_range(0.9,1.1))
		add_child(cavity)
		shadow.add_child(cavity.duplicate())
		cavities.append(cavity)
