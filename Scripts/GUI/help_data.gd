extends Resource
class_name HelpData

@export var title:= ""
@export var action_name : StringName
@export_multiline var text:= ""
@export var icon:Texture2D
@export var help_image:Texture2D

func _init(_title:= "", _action_name:= &"", _text:= "", _icon :Texture2D= null, _help_image :Texture2D= null):
	title = _title
	action_name = _action_name
	text = _text
	icon = _icon
	help_image = _help_image
