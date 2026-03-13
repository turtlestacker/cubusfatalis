extends Node3D

var sim: WorldSim = WorldSim.new()
var meshes: Dictionary = {}
@onready var hud: Label = $CanvasLayer/HUD
@onready var cam: Camera3D = $Camera3D

func _ready() -> void:
	sim.spawn_player("Corner")
	sim.fill_npmcs()
	_render_all()

func _process(delta: float) -> void:
	_handle_input(delta)
	sim.tick(delta)
	_render_all()
	_update_hud()
	var p: Dictionary = sim.player()
	if not p.is_empty():
		cam.global_position = p["pos"] + Vector3(0, 16, 22)
		cam.look_at(p["pos"], Vector3.UP)

func _handle_input(delta: float) -> void:
	var p: Dictionary = sim.player()
	if p.is_empty():
		return
	var speed: float = maxf(1.0, 4.0 - 0.05 * float(p["voxels"].size()))
	var dir := Vector3.ZERO
	if Input.is_key_pressed(KEY_W): dir.z += 1
	if Input.is_key_pressed(KEY_S): dir.z -= 1
	if Input.is_key_pressed(KEY_A): dir.x -= 1
	if Input.is_key_pressed(KEY_D): dir.x += 1
	if Input.is_key_pressed(KEY_R): dir.y += 1
	if Input.is_key_pressed(KEY_F): dir.y -= 1
	if dir != Vector3.ZERO:
		p["vel"] += dir.normalized() * speed * delta * 12.0
	if Input.is_key_pressed(KEY_B):
		var legal: Array = VoxelShape.legal_removals(p["voxels"])
		if not legal.is_empty():
			p["voxels"].erase(legal[0])
			p["vel"] *= 1.04

func _render_all() -> void:
	for k in meshes.keys():
		if not _entity_exists(k):
			meshes[k].queue_free()
			meshes.erase(k)
	for e in sim.entities:
		if not meshes.has(e["name"]):
			var n := Node3D.new()
			n.name = e["name"]
			add_child(n)
			meshes[e["name"]] = n
		var root: Node3D = meshes[e["name"]]
		for c in root.get_children():
			c.queue_free()
		for v in e["voxels"]:
			var mi := MeshInstance3D.new()
			mi.mesh = BoxMesh.new()
			mi.position = e["pos"] + Vector3(v.x, v.y, v.z)
			var mat := StandardMaterial3D.new()
			if e["is_player"]:
				mat.albedo_color = Color(0.25, 0.85, 1.0)
			else:
				var p: Dictionary = sim.player()
				var edible: bool = (not p.is_empty()) and p["voxels"].size() > e["voxels"].size() and bool(Harmonics.can_add(p["recent"], e["note"], p["resolved_key"])["ok"])
				mat.albedo_color = Color(0.9, 0.25, 0.2) if not edible else Color(0.2, 1.0, 0.35)
				mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
				mat.albedo_color.a = 0.35 if not edible else 1.0
			mi.material_override = mat
			root.add_child(mi)

func _update_hud() -> void:
	var p: Dictionary = sim.player()
	if p.is_empty():
		hud.text = "Player dead"
		return
	var near: Array = []
	for e in sim.entities:
		if e["is_player"]:
			continue
		if e["pos"].distance_to(p["pos"]) < 8.0:
			var c: Dictionary = Harmonics.can_add(p["recent"], e["note"], p["resolved_key"])
			var edible: bool = p["voxels"].size() > e["voxels"].size() and bool(c["ok"])
			near.append("%s v%d %s key:%s" % [e["name"], e["voxels"].size(), "EDIBLE" if edible else "WASHED", c["key"]])
	near.sort()
	hud.text = "CubusFatalis Godot Demo\nWASD/RF move, B boost\nTime %.1f Vol %d Score %.2f\nKey %s Recent %s\nNearby:\n%s" % [
		sim.elapsed,
		p["voxels"].size(),
		p["score"],
		p["resolved_key"],
		str(p["recent"].map(func(i: int) -> String: return Harmonics.NOTES[i])),
		"\n".join(near.slice(0, 8))
	]

func _entity_exists(name: String) -> bool:
	for e in sim.entities:
		if e["name"] == name:
			return true
	return false
