@tool
extends HBoxContainer
class_name HelpPage


@export var title:= "" : set = set_title
@export var action_name : StringName : set = set_action_name
@export_multiline var text:= "" : set = set_text
@export var icon:Texture2D : set = set_icon
@export var help_image:Texture2D : set = set_help_image


func set_title(value):
	title = value
	compute_title()
func set_action_name(value):
	action_name = value
	compute_title()
func set_text(value):
	text = value
	if get_node_or_null("DescriptionContainer/Text"):
		$DescriptionContainer/Text.text = text
func set_icon(value):
	icon = value
	if get_node_or_null("DescriptionContainer/TitleContainer/Icon"):
		$DescriptionContainer/TitleContainer/Icon.texture = icon
func set_help_image(value):
	help_image = value
	if get_node_or_null("HelpImage"):
		$HelpImage.texture = help_image


func _ready() -> void:
	compute_title()


func set_help_data(data: HelpData):
	title = data.title
	action_name = data.action_name
	text = data.text
	icon = data.icon
	help_image = data.help_image
	pass


func compute_title():
	if !get_node_or_null("DescriptionContainer/TitleContainer/Title"):
		return
	
	var real_title = title
	var inputEvents := InputMap.action_get_events(action_name)
	if !inputEvents.is_empty():
		real_title += " (" + inputEvents[0].as_text() + ")"
	$DescriptionContainer/TitleContainer/Title.text = real_title
