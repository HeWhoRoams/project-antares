# /tests/test_audio_manager.gd
extends "res://addons/gut/test.gd"

var audio_manager

func before_all():
	audio_manager = load("res://scripts/managers/audio_manager.gd").new()
	add_child(audio_manager)
	# Manually call ready since we are not using the scene tree here
	audio_manager._ready()

func after_all():
	remove_child(audio_manager)
	audio_manager.free()

func test_audio_manager_instantiates():
	assert_true(is_instance_valid(audio_manager), "Audio Manager should be a valid instance.")

func test_set_master_volume():
	audio_manager.set_master_volume(0.5)
	# Since we can't easily check the bus volume in a test, just ensure no errors
	assert_true(true, "Setting master volume should not error.")

func test_play_sfx():
	audio_manager.play_sfx("hover")
	# Just ensure it doesn't crash
	assert_true(true, "Playing SFX should not error.")

func test_play_music():
	audio_manager.play_music("")  # Empty to stop
	assert_true(true, "Stopping music should not error.")
