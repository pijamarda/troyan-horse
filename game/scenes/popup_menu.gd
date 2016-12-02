extends PopupMenu

func _ready():
	pass

func _on_popupmenu_item_pressed( ID ):
	if ( ID == 0 ):
		get_tree().set_pause(false)
		get_node(".").hide()
	else:
		get_tree().quit()
	
