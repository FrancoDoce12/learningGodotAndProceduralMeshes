extends Spatial




# var isMouseOnPlanet: bool = false
signal planet_selected(childNode)

func _on_Area_input_event(camera:Node, event:InputEvent, position:Vector3, normal:Vector3, shape_idx:int):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT:
			var childNode = get_child(0)
			outlinePlanet()
			print("golaa")
			emit_signal("planet_selected", childNode)



	
func outlinePlanet() -> void:
	
	pass


