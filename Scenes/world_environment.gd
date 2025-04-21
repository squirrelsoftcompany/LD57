extends WorldEnvironment

func _ready():
	GlobalEventHolder.connect("gameover",_light)
	GlobalEventHolder.connect("reload_game",_dark)

func _light(_x):
	environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR

func _dark():
	environment.ambient_light_source = Environment.AMBIENT_SOURCE_DISABLED
