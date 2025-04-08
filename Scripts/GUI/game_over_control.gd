extends Control


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


func _on_gameover(win: bool):
	$PanelContainer/VBoxContainer/TitleLabel.text = "game over" if !win else "congratulations"
	var text_label : Label = $PanelContainer/VBoxContainer/TextLabel
	text_label.text = text_label.text.to_lower() % [ _mine_left, _mine_max, _beacon_launched, _moves ]
	visible = true
