# /ui/components/system_summary_tooltip.gd
extends PanelContainer

@onready var system_name_label: Label = %SystemNameLabel
@onready var celestial_bodies_label: Label = %CelestialBodiesLabel
@onready var inhabited_label: Label = %InhabitedLabel

func update_data(system_data: StarSystem) -> void:
	system_name_label.text = system_data.display_name
	
	var body_count = system_data.celestial_bodies.size()
	celestial_bodies_label.text = "Celestial Bodies: %s" % body_count
	
	# We'll add logic for inhabited status later. For now, it's a placeholder.
	inhabited_label.text = "Inhabited: None"
