extends Node

func _ready():
	
	#	Funcion principal de entrada al programa
	#	desde esta funcion llamamos al menu principal
	var splash_scene = load("res://scenes/splash_title.tscn")
	var splash_title = splash_scene.instance()
	get_node(".").add_child(splash_title)
	
func run():
	var splash_node = get_node("splash_title")
	splash_node.queue_free()
	var menu_scene = load("res://scenes/menu_control.tscn")
	var menu = menu_scene.instance()
	get_node(".").add_child(menu)