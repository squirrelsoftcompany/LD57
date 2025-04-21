extends Control


@onready var _reload_button = $PanelContainer/VBoxContainer/HBoxContainer/Button


var _beacon_launched :int= 0
var _moves : int = 0
var _mine_left : int = 0
var _mine_max : int = 0


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_mine_max = ProjectSettings.get_setting("Game/Global/MaxMines", 10)
	GlobalEventHolder.gameover.connect(_on_gameover, CONNECT_DEFERRED)
	GlobalEventHolder.ask_beacon_finish.connect(func(): _beacon_launched+=1)
	GlobalEventHolder.player_finish_moving.connect(func(_x, _y): _moves+=1)
	GlobalEventHolder.mine_state_changed_really.connect(func(val, _maximum): _mine_left = val)
	GlobalEventHolder.mine_state_changed_really.connect(func(_val, maximum): _mine_max = maximum)
	_reload_button.connect("pressed", _on_reload_button_pressed)


func _on_gameover(win: bool):
	$PanelContainer/VBoxContainer/TitleLabel.text = "Game over" if !win else "Congratulations"
	var text_label : Label = $PanelContainer/VBoxContainer/TextLabel
	var text_label2 : Label = $PanelContainer/VBoxContainer/TextLabel2
	if win :
		text_label.text = "You did it! you found and marked all the mines !"
	else :
		text_label.text = text_label.text.to_lower() % [ _mine_left, _mine_max]
	text_label2.text = text_label2.text.to_lower() % [ _beacon_launched, _moves]
	visible = true


func _on_reload_button_pressed():
	GlobalEventHolder.reload_game.emit()
	get_tree().reload_current_scene.call_deferred()
