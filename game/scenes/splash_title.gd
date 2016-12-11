extends Node2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"
var time = 5

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	set_process(true)
	pass

func _process(delta):
	time = time - delta	
	if time < 0:
		get_node("/root/main").run()