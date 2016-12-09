extends Control

func _ready():
	pass

func _on_quit_button_pressed():
	get_node("/root/main/SamplePlayerMenu").play("menu_1")
	get_tree().quit()

#	Cuando pulsamos el boton -> PLAY instanciamos la escena principal
#	que es "game" y la attachamos a la escena MAIN
func _on_start_button_pressed():
	get_node("/root/main/SamplePlayerMenu").play("menu_1")
	var scene_game = load("res://scenes/game.tscn")
	var game = scene_game.instance()
	get_node("/root/main").add_child(game)
	get_node("/root/main/StreamPlayer").stop()
	


func _on_start_button_mouse_enter():
	get_node("/root/main/SamplePlayerMenu").play("menu_hover_1")


func _on_quit_button_mouse_enter():
	get_node("/root/main/SamplePlayerMenu").play("menu_hover_1")
