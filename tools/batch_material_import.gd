@tool
extends EditorScript

const MATERIAL_PATH := "res://models/material.tres"
const MATERIAL_UID  := "uid://dvmng8wny5x0y" # ← use the real one Godot generated

func _run():
	var files := _collect_import_files("res://")

	for path in files:
		_apply_external_material(path)

	print("Updated %d .import files" % files.size())


func _apply_external_material(import_path: String) -> void:
	var cfg := ConfigFile.new()
	var err := cfg.load(import_path)
	if err != OK:
		push_warning("Failed to load: %s" % import_path)
		return

	var subresources := {
		"materials": {
			"texture": {
				"use_external/enabled": true,
				"use_external/fallback_path": MATERIAL_PATH,
				"use_external/path": MATERIAL_UID
			}
		}
	}

	cfg.set_value("params", "_subresources", subresources)
	cfg.save(import_path)


func _collect_import_files(dir_path: String) -> Array[String]:
	var result: Array[String] = []
	var dir := DirAccess.open(dir_path)
	if dir == null:
		return result

	dir.list_dir_begin()
	while true:
		var f := dir.get_next()
		if f == "":
			break
		if f.begins_with("."):
			continue

		var full := dir_path + "/" + f

		if dir.current_is_dir():
			result.append_array(_collect_import_files(full))
		else:
			if f.ends_with(".gltf.import"):
				result.append(full)

	dir.list_dir_end()
	return result
