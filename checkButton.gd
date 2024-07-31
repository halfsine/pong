extends CheckButton

@export var window : Control                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                  

func _on_toggled(toggled_on):
	window.visible = toggled_on
