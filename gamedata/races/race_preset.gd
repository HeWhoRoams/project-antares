class_name RacePreset
extends Resource

# Race Preset Resource
# Defines the bonuses, abilities, and characteristics of different space-faring races

enum RaceType {
	SYNARI,     # Bioluminescent knowledge seekers
	VEKTRIL,    # Hive-minded industrialists
	URSOIDS,    # Rhino-like warriors
	ZHERIN,     # Serpentine colonizers
	FELYARI,    # Canid fleet hunters
	AVARII,     # Butterfly-winged pilots
	LITHARI,    # Rock-skinned titans
	UMBRANS,    # Shadowy spies
	CONCORDIANS,# Adaptable diplomats
	SERAPHID,   # Psychic mystics
	PELAGIANS,  # Jellyfish-like aquatics
}

# Basic race information
@export var race_type: RaceType = RaceType.HUMAN
@export var display_name: String = "Human"
@export var description: String = "Versatile and adaptable, humans excel at colonization and diplomacy."
@export var plural_name: String = "Humans"

# Visual representation
@export var primary_color: Color = Color.WHITE
@export var secondary_color: Color = Color.GRAY

# Starting bonuses
@export var starting_population: int = 1
@export var starting_credits: int = 250
@export var starting_research: int = 50

# Economic modifiers (multipliers)
@export var food_production_modifier: float = 1.0
@export var production_modifier: float = 1.0
@export var research_modifier: float = 1.0
@export var credit_income_modifier: float = 1.0

# Population and growth
@export var population_growth_modifier: float = 1.0
@export var max_population_modifier: float = 1.0
@export var morale_modifier: int = 0  # Flat morale bonus/penalty

# Combat modifiers
@export var ship_attack_modifier: float = 1.0
@export var ship_defense_modifier: float = 1.0
@export var ground_combat_modifier: float = 1.0

# Special abilities and traits
@export var traits: Array[String] = []  # List of special trait IDs

# Planet preferences (bonuses on certain planet types)
@export var terran_bonus: float = 1.0
@export var desert_bonus: float = 1.0
@export var ice_bonus: float = 1.0
@export var gas_giant_bonus: float = 1.0

# Technology preferences (research speed modifiers)
@export var construction_tech_modifier: float = 1.0
@export var force_fields_tech_modifier: float = 1.0
@export var computers_tech_modifier: float = 1.0

# Special race abilities
@export var has_telepathic_combat: bool = false
@export var has_cloaking_ability: bool = false
@export var has_regeneration: bool = false
@export var has_engineering_bonus: bool = false
@export var has_espionage_bonus: bool = false

# AI personality tendencies (0-100, higher = more likely)
@export var ai_aggression: int = 50
@export var ai_expansionism: int = 50
@export var ai_technological_focus: int = 50
@export var ai_defensiveness: int = 50

func _init():
	# Set default traits based on race type
	match race_type:
		RaceType.SYNARI:
			_setup_synari()
		RaceType.VEKTRIL:
			_setup_vektril()
		RaceType.URSOIDS:
			_setup_ursoids()
		RaceType.ZHERIN:
			_setup_zherin()
		RaceType.FELYARI:
			_setup_felyari()
		RaceType.AVARII:
			_setup_avarii()
		RaceType.LITHARI:
			_setup_lithari()
		RaceType.UMBRANS:
			_setup_umbrans()
		RaceType.CONCORDIANS:
			_setup_concordians()
		RaceType.SERAPHID:
			_setup_seraphid()
		RaceType.PELAGIANS:
			_setup_pelagians()

func _setup_synari():
	display_name = "Synari"
	description = "Tall, bioluminescent beings with crystalline head crests. Masters of knowledge, obsessed with understanding the universe."
	plural_name = "Synari"
	primary_color = Color(0.4, 0.8, 1.0)  # Cyan
	secondary_color = Color(0.2, 0.6, 0.8)  # Blue
	research_modifier = 2.0
	food_production_modifier = 0.5
	traits = ["creative", "knowledge_ seekers"]
	ai_aggression = 30
	ai_expansionism = 40
	ai_technological_focus = 90
	ai_defensiveness = 40

func _setup_vektril():
	display_name = "Vektril"
	description = "Pill bug-like exoskeletal hive beings with iridescent shells. Hive-minded industrialists with endless labor capacity."
	plural_name = "Vektril"
	primary_color = Color(0.6, 0.8, 0.4)  # Light green
	secondary_color = Color(0.4, 0.6, 0.2)  # Green
	production_modifier = 2.0
	population_growth_modifier = 1.5
	research_modifier = 0.0  # -1 in the spec, but using 0.0 for multiplier
	traits = ["hive_mind", "industrial", "endless_labor"]
	ai_aggression = 40
	ai_expansionism = 80
	ai_technological_focus = 20
	ai_defensiveness = 60

func _setup_ursoids():
	display_name = "Ursoids"
	description = "Massive rhino-like humanoids with plated hides. Proud warriors who dominate in ground combat."
	plural_name = "Ursoids"
	primary_color = Color(0.6, 0.4, 0.2)  # Brown
	secondary_color = Color(0.4, 0.2, 0.1)  # Dark brown
	ground_combat_modifier = 1.25  # +25% ground combat
	research_modifier = 0.0  # -1 in the spec
	traits = ["proud", "warriors", "ground_combat"]
	ai_aggression = 60
	ai_expansionism = 40
	ai_technological_focus = 20
	ai_defensiveness = 80

func _setup_zherin():
	display_name = "Zherin"
	description = "Serpentine reptilians with layered scales and hypnotic eyes. Rapid breeders and aggressive colonizers."
	plural_name = "Zherin"
	primary_color = Color(0.8, 0.6, 0.2)  # Orange
	secondary_color = Color(0.6, 0.4, 0.1)  # Dark orange
	population_growth_modifier = 1.5
	ground_combat_modifier = 1.2  # +20% ground combat
	research_modifier = 0.0  # -1 in the spec
	traits = ["rapid_breeders", "aggressive", "colonizers"]
	ai_aggression = 70
	ai_expansionism = 90
	ai_technological_focus = 20
	ai_defensiveness = 40

func _setup_felyari():
	display_name = "Felyari"
	description = "Canid predators with sharp fangs and hunter's instincts. Fearless fleet hunters, excelling in ambushes."
	plural_name = "Felyari"
	primary_color = Color(0.8, 0.4, 0.1)  # Orange
	secondary_color = Color(0.6, 0.2, 0.0)  # Red-orange
	ship_attack_modifier = 1.5  # +50% ship attack
	ship_defense_modifier = 0.8  # -20% ship defense
	traits = ["fearless", "fleet_hunters", "ambush"]
	ai_aggression = 80
	ai_expansionism = 60
	ai_technological_focus = 30
	ai_defensiveness = 30

func _setup_avarii():
	display_name = "Avarii"
	description = "Graceful butterfly-winged humanoids with delicate frames. Natural pilots with unmatched maneuvering skill."
	plural_name = "Avarii"
	primary_color = Color(0.8, 0.6, 0.9)  # Light purple
	secondary_color = Color(0.6, 0.4, 0.7)  # Purple
	ship_defense_modifier = 1.25  # +25% ship defense
	ground_combat_modifier = 0.9  # -10% ground combat
	traits = ["natural_pilots", "maneuvering", "delicate"]
	ai_aggression = 50
	ai_expansionism = 50
	ai_technological_focus = 60
	ai_defensiveness = 60

func _setup_lithari():
	display_name = "Lithari"
	description = "Rock-skinned titans, slow but unyielding. Stone-born beings, able to thrive anywhere but slow to expand."
	plural_name = "Lithari"
	primary_color = Color(0.5, 0.5, 0.5)  # Gray
	secondary_color = Color(0.3, 0.3, 0.3)  # Dark gray
	population_growth_modifier = 0.5
	traits = ["lithovore", "colonize_all", "slow_expansion"]
	ai_aggression = 40
	ai_expansionism = 30
	ai_technological_focus = 40
	ai_defensiveness = 90

func _setup_umbrans():
	display_name = "Umbrans"
	description = "Shadowy silhouettes with shifting forms. Masters of secrecy, feared spies and saboteurs."
	plural_name = "Umbrans"
	primary_color = Color(0.2, 0.2, 0.2)  # Dark gray
	secondary_color = Color(0.1, 0.1, 0.1)  # Black
	has_espionage_bonus = true
	credit_income_modifier = 0.9  # -10% diplomacy (penalty)
	food_production_modifier = 0.5
	traits = ["masters_secrecy", "spies", "saboteurs"]
	ai_aggression = 60
	ai_expansionism = 50
	ai_technological_focus = 70
	ai_defensiveness = 40

func _setup_concordians():
	display_name = "Concordians"
	description = "Adaptable humanoids with diverse features and unifying symbols. Traders and diplomats who thrive on unity."
	plural_name = "Concordians"
	primary_color = Color(0.7, 0.7, 0.9)  # Light blue
	secondary_color = Color(0.5, 0.5, 0.7)  # Blue
	credit_income_modifier = 1.5  # +50% diplomacy
	# bc_per_pop: 0.5 - this would need to be implemented in colony calculation
	traits = ["adaptable", "traders", "diplomats"]
	ai_aggression = 30
	ai_expansionism = 70
	ai_technological_focus = 50
	ai_defensiveness = 50

func _setup_seraphid():
	display_name = "Seraphid"
	description = "Elegant, butterfly-winged mystics with psychic eyes. Psychic manipulators, feared in diplomacy and espionage."
	plural_name = "Seraphid"
	primary_color = Color(0.9, 0.7, 0.9)  # Light pink
	secondary_color = Color(0.7, 0.5, 0.7)  # Pink
	has_espionage_bonus = true
	has_telepathic_combat = true
	ship_defense_modifier = 0.8  # -20% ship defense
	traits = ["psychic", "manipulators", "mystics"]
	ai_aggression = 50
	ai_expansionism = 60
	ai_technological_focus = 80
	ai_defensiveness = 40

func _setup_pelagians():
	display_name = "Pelagians"
	description = "Jellyfish-like ethereals with translucent forms. Aquatic wanderers, swift in space but slow to expand."
	plural_name = "Pelagians"
	primary_color = Color(0.4, 0.8, 0.8)  # Cyan
	secondary_color = Color(0.2, 0.6, 0.6)  # Teal
	population_growth_modifier = 0.5
	# ship_speed: 2 - this would need to be implemented in fleet movement
	traits = ["aquatic", "wanderers", "swift_space"]
	ai_aggression = 40
	ai_expansionism = 30
	ai_technological_focus = 60
	ai_defensiveness = 70

# Utility functions
func get_trait_description(trait: String) -> String:
	match trait:
		"adaptable": return "Can colonize any planet type effectively"
		"industrial": return "+25% production output"
		"pollution_immune": return "Immune to pollution effects"
		"slow_growth": return "-25% population growth"
		"aggressive": return "+20% ship attack"
		"military_focus": return "Superior military technology"
		"hive_mind": return "Coordinated tactics"
		"brilliant": return "+40% research output"
		"research_focus": return "Exceptional scientific capabilities"
		"fragile": return "-10% ship defense"
		"defensive": return "+30% ship defense"
		"aquatic": return "Bonus on aquatic planets"
		"strong_defenses": return "+20% ground combat"
		"stealthy": return "Cloaking technology available"
		"traders": return "+20% credit income"
		"espionage": return "Enhanced espionage capabilities"
		"robotic": return "No maintenance costs"
		"maintenance_free": return "Ships require no crew"
		"engineers": return "Reduced construction time"
		"prolific": return "+50% population growth"
		"expansionist": return "Rapid colonization"
		"population_boom": return "+20% maximum population"
		"lucky": return "Beneficial random events"
		"fortunate": return "Positive random occurrences"
		"random_events": return "Increased event frequency"
		"strong": return "+30% ground combat"
		"warriors": return "+40% ship attack"
		"brutish": return "-30% research output"
		"ancient": return "Ancient technology and knowledge"
		"powerful": return "Overwhelming military might"
		"overwhelming": return "Massive combat bonuses"
		"underground": return "Bonus on barren planets"
		"miners": return "+20% production"
		"resource_focus": return "Enhanced resource extraction"
		"crystalline": return "+40% ship defense"
		"energy_weapons": return "Advanced energy technology"
		"durable": return "Structural integrity bonuses"
		"psychic": return "+20% research"
		"telepathic": return "Telepathic combat abilities"
		"mind_control": return "Psychic warfare capabilities"
		"artistic": return "+30% credit income"
		"cultural": return "+10 base morale"
		"diplomatic": return "Enhanced diplomatic relations"
		"tough": return "+20% ship defense"
		"durable": return "+30% ground combat"
		"defensive": return "Superior defensive capabilities"
		"beast": return "+20% ship attack"
		"warriors": return "+20% ground combat"
		"aggressive": return "Aggressive expansion tendencies"
		"insectoid": return "+30% population growth"
		"hive_mind": return "+10% maximum population"
		"coordinated": return "Synchronized tactics"
		"reptilian": return "Enhanced stealth capabilities"
		"stealthy": return "Espionage advantages"
		"infiltrators": return "+10% ship attack"
		"explorers": return "+10% food production"
		"colonizers": return "+10% population growth"
		"adaptive": return "Flexible colonization"
		"custom": return "Player-configurable bonuses"
		"configurable": return "Customizable race traits"
		"evil": return "Destructive tendencies"
		"destructive": return "Overwhelming destructive power"
		_:
			return "Unknown trait: " + trait

func get_ai_personality() -> AIManager.AIPersonality:
	# Determine AI personality based on race characteristics
	var aggression = ai_aggression
	var expansion = ai_expansionism
	var tech = ai_technological_focus
	var defense = ai_defensiveness

	if aggression >= 70:
		return AIManager.AIPersonality.AGGRESSIVE
	elif expansion >= 70:
		return AIManager.AIPersonality.EXPANSIONIST
	elif tech >= 70:
		return AIManager.AIPersonality.TECHNOLOGICAL
	elif defense >= 70:
		return AIManager.AIPersonality.DEFENSIVE
	else:
		return AIManager.AIPersonality.BALANCED

# Static factory methods for creating race presets
static func create_human() -> RacePreset:
	var race = RacePreset.new()
	race.race_type = RaceType.HUMAN
	race._setup_human()
	return race

static func create_silicoid() -> RacePreset:
	var race = RacePreset.new()
	race.race_type = RaceType.SILICOID
	race._setup_silicoid()
	return race

static func create_mantis() -> RacePreset:
	var race = RacePreset.new()
	race.race_type = RaceType.MANTIS
	race._setup_mantis()
	return race

static func create_klackon() -> RacePreset:
	var race = RacePreset.new()
	race.race_type = RaceType.KLACKON
	race._setup_klackon()
	return race

static func get_all_races() -> Array[RacePreset]:
	return [
		create_human(),
		create_silicoid(),
		create_mantis(),
		create_klackon(),
		# Add other races as needed
	]
