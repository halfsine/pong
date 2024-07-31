extends ColorRect

func _on_enabled_toggled(toggled_on):
	visible = toggled_on

func _on_vignette_value_changed(value):
	material.set_shader_parameter("vignette_intensity", value)


func _on_chromatic_abberation_value_changed(value):
	material.set_shader_parameter("abberation", value)
