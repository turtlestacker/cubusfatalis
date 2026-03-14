extends Node3D

var sim: WorldSim = WorldSim.new()
var meshes: Dictionary = {}

@onready var hud: Label = $CanvasLayer/HUD
@onready var cam: Camera3D = $Camera3D
@onready var x_view: SubViewport = $CanvasLayer/AxisViews/XPanel/VBox/XView/SubViewport
@onready var y_view: SubViewport = $CanvasLayer/AxisViews/XPanel2/VBox/YView/SubViewport
@onready var z_view: SubViewport = $CanvasLayer/AxisViews/XPanel3/VBox/ZView/SubViewport

func _ready() -> void:
	sim.spawn_player("Corner")
	sim.fill_npmcs()
	_setup_axis_cameras()
	_render_all()

func _process(delta: float) -> void:
	sim.tick(delta)
	_render_all()
	_update_hud()
	var p: Dictionary = sim.player()
	if not p.is_empty():
		cam.global_position = p["pos"] + Vector3(0, 16, 22)
		cam.look_at(p["pos"], Vector3.UP)

func _unhandled_input(event: InputEvent) -> void:
	if not (event is InputEventKey):
		return
	var key_event: InputEventKey = event
	if not key_event.pressed or key_event.echo:
		return
	if key_event.keycode == KEY_A:
		sim.move_player_discrete(Vector3i(-1, 0, 0))
	elif key_event.keycode == KEY_D:
		sim.move_player_discrete(Vector3i(1, 0, 0))
	elif key_event.keycode == KEY_R:
		sim.move_player_discrete(Vector3i(0, 1, 0))
	elif key_event.keycode == KEY_F:
		sim.move_player_discrete(Vector3i(0, -1, 0))
	elif key_event.keycode == KEY_W:
		sim.move_player_discrete(Vector3i(0, 0, 1))
	elif key_event.keycode == KEY_S:
		sim.move_player_discrete(Vector3i(0, 0, -1))
	elif key_event.keycode == KEY_B:
		sim.boost_player()

func _setup_axis_cameras() -> void:
	var x_cam := Camera3D.new()
	x_cam.projection = Camera3D.PROJECTION_ORTHOGONAL
	x_cam.size = 35.0
	x_cam.position = Vector3(60, 0, 0)
	x_cam.look_at(Vector3.ZERO, Vector3.UP)
	x_view.add_child(x_cam)
	x_cam.current = true
	x_view.world_3d = get_viewport().world_3d

	var y_cam := Camera3D.new()
	y_cam.projection = Camera3D.PROJECTION_ORTHOGONAL
	y_cam.size = 35.0
	y_cam.position = Vector3(0, 60, 0)
	y_cam.look_at(Vector3.ZERO, Vector3.BACK)
	y_view.add_child(y_cam)
	y_cam.current = true
	y_view.world_3d = get_viewport().world_3d

	var z_cam := Camera3D.new()
	z_cam.projection = Camera3D.PROJECTION_ORTHOGONAL
	z_cam.size = 35.0
	z_cam.position = Vector3(0, 0, 60)
	z_cam.look_at(Vector3.ZERO, Vector3.UP)
	z_view.add_child(z_cam)
	z_cam.current = true
	z_view.world_3d = get_viewport().world_3d

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
	hud.text = "CubusFatalis 4-View Demo\nDiscrete Grid Steps: A/D (X), R/F (Y), W/S (Z), B boost\nPos %s  Vol %d  Score %.2f  Time %.1f\nKey %s Recent %s\nNearby:\n%s" % [
		str(p["pos"]),
		p["voxels"].size(),
		p["score"],
		sim.elapsed,
		p["resolved_key"],
		str(p["recent"].map(func(i: int) -> String: return Harmonics.NOTES[i])),
		"\n".join(near.slice(0, 6))
	]

func _entity_exists(name: String) -> bool:
	for e in sim.entities:
		if e["name"] == name:
			return true
	return false
