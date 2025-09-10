# /gamedata/dialogue/dialog_phrase.gd
class_name DialogPhrase
extends Resource

enum AttributeBand { NONE, EXTREME_LOW, LOW, MID, HIGH, EXTREME_HIGH }

@export_multiline var text: String # e.g., "Your actions displease us. War may be inevitable."
@export var context: StringName # e.g., "threat_mild", "greeting_friendly", "deal_accept"

@export_group("Attribute Mapping")
@export var required_attribute: StringName = &"eloquence" # The attribute this phrase relates to.
@export var required_band: AttributeBand = AttributeBand.MID # The score range this phrase is for.
