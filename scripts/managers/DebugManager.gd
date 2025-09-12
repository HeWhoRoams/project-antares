# /scripts/managers/DebugManager.gd
extends Node

## --- DEFENSIVE CODE FLAG ---
## Set this to 'true' in the Project Settings to enable extra validation checks.
## These checks can help find bugs but may have a minor performance cost.
## We'll default it to 'true' while we're still in development.
@export var is_debug_mode_enabled: bool = true
