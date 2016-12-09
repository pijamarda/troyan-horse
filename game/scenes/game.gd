extends Node2D

#	CONSTANTES
var TOP_POSITION_Y = 144
var MID_POSITION_Y = 288
var BOT_POSITION_Y = 480
var PAUSE_TIME = 1
var WAIT_INPUT = true
var time_wait = 0.5
var HORSE_SPEED_BASE = 3

# VARIABLES

var screen_size
#	La velocidad del caballo ira aumentando segun capturemos ordenadores
var horse_speed = HORSE_SPEED_BASE
var horse_direction = Vector2(horse_speed,0)
#	horse_state indica hacia donde ha elegido el usuario moverse
#	y donde esta el caballo actualmente
#	-1	quiere decir arriba
#	0	es el centro
#	1	es abajo
var horse_state = 0 # -1 means top, 0 mid, 1 bottom

#	Cuando el caballo esta cambiando de posicion esta variable pasa a
#	ser TRUE y no se admiten cambios de direccion
var horse_moving = false

#	Al prinipio tenemos 3 computadoras, segun vamos capturando
#	vamos cambiando la variable
var computers_remaining = 3

#	Cuanto tiempo esperamos despues de capturar el ordenador
var time_left = PAUSE_TIME

#	Utilizamos esta variable para saber si cuando el caballo se esta
#	moviendo, es en direccion arriba o abajo
var bajando = false

var playCapture = true

#
var nivel = 1

func _ready():

	# Voy a borrar del todo el MENU PRINCIPAL puesto que hay un BUG
	# que permite activarlo aun cuando el juego esta funcionando
	get_node("/root/main/menu").queue_free()
	#	Quizas nos sea util en el futuro saber el tamaño de la pantalla
	screen_size = get_viewport_rect().size
	#set_process_input(true)
	set_fixed_process(true)
	#	Instanciamos el primer nivel del juego
	var scene_map = load("res://scenes/levels/level_1_1.tscn")
	var map = scene_map.instance()
	#	y lo attachamos al nodo "GAME"
	get_node(".").add_child(map)
	#	Instanciamos el caballo que vamos a manejar
	#	y lo attachamos a la escena MAP
	var horse_scene = load("res://scenes/horse.tscn")
	var horse = horse_scene.instance()
	get_node("map").add_child(horse)
	#	Instanciamos el popup_menu de la pausa
	#	y lo attachamos a la escena GAME
	var popup_menu_scene = load("res://scenes/popup_menu.tscn")
	var popup_menu = popup_menu_scene.instance()
	get_node(".").add_child(popup_menu)
	
func _input(event):
	
	#	En vez de tener que pulsar arriba o abajo de la mitad de la pantalla.
	#	vamos a cambiarlo para que sea pulsando encima o debajo del caballo
	var temp_horse_pos = get_node("/root/main/game/map/horse/kinematic_horse").get_global_pos()
	#	Hemos definido la accion horse_up en el INPUT del proyecto
	if (not horse_moving):
		if((event.is_action("horse_up") and event.is_pressed() and !event.is_echo()) or (event.type == InputEvent.MOUSE_BUTTON and event.pos.y < temp_horse_pos.y)):
			#	Primero vamos a comprobar si el caballo no esta en una transicion de movimiento
			#if (not horse_moving):
				get_node("SamplePlayer").play("change_lane_1")
				#	Si no se esta moviendo vamos a ver en cual de los cables se encuentra
				if (horse_state == 0):	# esta en el medio
					#	Si esta en el medio se puede mover hacia arriba
					horse_direction = Vector2(horse_speed,-horse_speed)
					horse_state = -1
					horse_moving = true
				elif (horse_state == 1):	# Esta abajo
					#	Entonces se puede mover hacia el medio
					horse_direction = Vector2(horse_speed,-horse_speed)
					horse_state = 0
					horse_moving = true
					#	Como se mueve hacia el medio, hay que notificar en que direccion
					#	esto lo hacemos con la variable "bajando" indicando que esta subiendo
					bajando = false
		#	TODO: Hay que ajustar la zona de pulsacion del caballo, es posible que la posicion devuelta
		#	sea la esuina superior izquierda
		elif(event.is_action("horse_down") and event.is_pressed() and !event.is_echo() or (event.type == InputEvent.MOUSE_BUTTON and event.pos.y > temp_horse_pos.y)):
			#if (not horse_moving):
				get_node("SamplePlayer").play("change_lane_1")
				if (horse_state == -1):
					horse_direction = Vector2(horse_speed,horse_speed)
					horse_state = 0
					horse_moving = true
					bajando = true
				elif (horse_state == 0):
					horse_state = 1
					horse_direction = Vector2(horse_speed,horse_speed)
					horse_moving = true
	
		#	Menu popup de Pausa
	if(event.is_action("escape") and event.is_pressed() and !event.is_echo()):
		
		# como el caballo esta en el centro vamos a colocar el 
		temp_horse_pos.x = temp_horse_pos.x - 100
		temp_horse_pos.y = temp_horse_pos.y - 100
		get_node("/root/main/game/popupmenu").set_global_pos(temp_horse_pos)
		print("pulso escape")
		get_tree().set_pause(true)
		get_node("/root/main/game/popupmenu").show()

func _fixed_process(delta):
	if WAIT_INPUT:
		if time_wait > 0:
			time_wait = time_wait - delta
		else:
			WAIT_INPUT = false
			set_process_input(true)
	if get_node("map/horse/kinematic_horse").is_colliding():
		var collision_object = get_node("map/horse/kinematic_horse").get_collider()
		var collision_name = collision_object.get_name()
		if (collision_name == "firewall" or collision_name == "infected" or collision_name == "cable"):
			get_node("SamplePlayer").play("death_fw_sound_1")
			print("Mueres")
			get_node("map/horse").free()
			var scene = load("res://scenes/horse.tscn")
			var horse = scene.instance()
			get_node("map").add_child(horse)
			horse_state = 0
			horse_moving = false
			horse_direction = Vector2(horse_speed,0)
		elif (collision_name == "computer"):
			if playCapture:
				playCapture = false
				get_node("SamplePlayer").play("capture_sound_1")
			if (time_left < 0 ):
				computers_remaining = computers_remaining - 1
				horse_speed = horse_speed + 1
				var pos_collider = collision_object.get_global_pos()
				print(pos_collider)
				collision_object.get_parent().free()
				var infected_res = load("res://scenes/infected.tscn")
				var infected = infected_res.instance()
				infected.set_global_pos(pos_collider)
				get_node("map").add_child(infected)
				get_node("map/horse").free()
				var scene = load("res://scenes/horse.tscn")
				var horse = scene.instance()
				get_node("map").add_child(horse)
				horse_state = 0
				horse_moving = false
				horse_direction = Vector2(horse_speed,0)
				time_left = PAUSE_TIME
				playCapture = true
			else:
				#print(time_left)
				time_left = time_left - delta
			
	else:
		if (horse_moving):
			var temp = get_node("map/horse/kinematic_horse").get_global_pos().y
			if horse_state == -1:
				if temp > TOP_POSITION_Y:
					pass
				else:
					horse_moving = false
					horse_direction = Vector2(horse_speed,0)
			elif (horse_state == 0):
				if bajando:
					if temp < MID_POSITION_Y:
						pass
					else:
						horse_moving = false
						horse_direction = Vector2(horse_speed,0)
				else:
					if temp > MID_POSITION_Y:
						pass
					else:
						horse_moving = false
						horse_direction = Vector2(horse_speed,0)
			elif horse_state == 1:
				if temp < BOT_POSITION_Y:
					pass
					
				else:
					horse_moving = false
					horse_direction = Vector2(horse_speed,0)
		
		#TODO
		get_node("map/horse/kinematic_horse").move(horse_direction)
	if (computers_remaining == 0):
		if nivel == 2:
			get_tree().set_pause(true)
			get_node("map/horse").free()
			get_node("map").free()
			var scene_end = load("res://scenes/end.tscn")
			var end = scene_end.instance()
			get_node("/root/main").add_child(end)
		else:
			computers_remaining = 3
			nivel = nivel + 1
			get_node("map/horse").free()
			get_node("map").free()
			var scene_map = load("res://scenes/levels/level_1_2.tscn")
			var map = scene_map.instance()
			get_node(".").add_child(map)
			var scene = load("res://scenes/horse.tscn")
			var horse = scene.instance()
			get_node("map").add_child(horse)
			horse_speed = HORSE_SPEED_BASE
			horse_direction = Vector2(horse_speed,0)