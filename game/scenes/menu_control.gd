extends Control

func _ready():
	pass

func _on_quit_button_pressed():
	get_tree().quit()

#	Cuando pulsamos el boton -> PLAY instanciamos la escena principal
#	que es "game" y la attachamos a la escena MAIN
func _on_start_button_pressed():
	var scene_game = load("res://scenes/game.tscn")
	var game = scene_game.instance()
	get_node("/root/main").add_child(game)
	
