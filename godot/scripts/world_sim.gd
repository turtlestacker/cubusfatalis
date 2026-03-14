extends RefCounted
class_name WorldSim

const STARTER_SHAPES := {
	"Line": [Vector3i(0,0,0),Vector3i(1,0,0),Vector3i(2,0,0),Vector3i(-1,0,0),Vector3i(-2,0,0)],
	"Hook": [Vector3i(0,0,0),Vector3i(1,0,0),Vector3i(2,0,0),Vector3i(2,1,0),Vector3i(2,2,0)],
	"Plate": [Vector3i(0,0,0),Vector3i(1,0,0),Vector3i(0,1,0),Vector3i(1,1,0),Vector3i(0,2,0),Vector3i(1,2,0)],
	"Corner": [Vector3i(0,0,0),Vector3i(1,0,0),Vector3i(0,1,0),Vector3i(0,0,1),Vector3i(1,0,1)]
}
const NPMC_SHAPES := [[Vector3i(0,0,0)], [Vector3i(0,0,0),Vector3i(1,0,0)], [Vector3i(0,0,0),Vector3i(0,1,0)]]

var arena_half := 20.0
var entities: Array = []
var elapsed := 0.0
var last_attrition := 0.0
var tick_count := 0
var rng := RandomNumberGenerator.new()

func _init() -> void:
	rng.seed = 7

func spawn_player(starter := "Corner") -> void:
	entities.clear()
	var p := {
		"name": "Player",
		"is_player": true,
		"voxels": STARTER_SHAPES[starter].duplicate(),
		"pos": Vector3.ZERO,
		"vel": Vector3.ZERO,
		"note": int(rng.randi() % 12),
		"recent": [],
		"resolved_key": "",
		"score": 0.0,
	}
	var init_res := Harmonics.can_add([], p["note"], "")
	p["recent"] = init_res["recent"]
	p["resolved_key"] = init_res["key"]
	entities.append(p)

func player() -> Dictionary:
	for e in entities:
		if e["is_player"]:
			return e
	return {}

func move_player_discrete(step: Vector3i) -> void:
	var p: Dictionary = player()
	if p.is_empty():
		return
	var next: Vector3 = Vector3(p["pos"]) + Vector3(step.x, step.y, step.z)
	next.x = clamp(next.x, -arena_half, arena_half)
	next.y = clamp(next.y, -arena_half, arena_half)
	next.z = clamp(next.z, -arena_half, arena_half)
	p["pos"] = next

func boost_player() -> void:
	var p: Dictionary = player()
	if p.is_empty():
		return
	var legal: Array = VoxelShape.legal_removals(p["voxels"])
	if not legal.is_empty():
		p["voxels"].erase(legal[0])

func fill_npmcs(target := 18) -> void:
	var npmc_count := 0
	for e in entities:
		if not e["is_player"]:
			npmc_count += 1
	for i in range(target - npmc_count):
		var note := (tick_count + i) % 12
		entities.append({
			"name": "NPMC-%d" % entities.size(),
			"is_player": false,
			"voxels": NPMC_SHAPES[int(rng.randi() % NPMC_SHAPES.size())].duplicate(),
			"pos": Vector3(round(rng.randf_range(-16,16)), round(rng.randf_range(-16,16)), round(rng.randf_range(-16,16))),
			"vel": Vector3(rng.randf_range(-1,1), rng.randf_range(-1,1), rng.randf_range(-1,1)),
			"note": note,
		})

func attrition_interval(volume: int) -> float:
	return 24.0 / sqrt(max(1.0, float(volume)))

func tick(dt: float) -> void:
	tick_count += 1
	elapsed += dt
	fill_npmcs()
	for e in entities:
		if e["is_player"]:
			continue
		e["pos"] += e["vel"] * dt
		e["vel"] *= 0.995
		e["pos"].x = clamp(e["pos"].x, -arena_half, arena_half)
		e["pos"].y = clamp(e["pos"].y, -arena_half, arena_half)
		e["pos"].z = clamp(e["pos"].z, -arena_half, arena_half)
		e["pos"] = Vector3(round(e["pos"].x), round(e["pos"].y), round(e["pos"].z))
	var p := player()
	if p.is_empty():
		return
	var eaten: Array = []
	for e in entities:
		if e == p:
			continue
		if p["voxels"].size() <= e["voxels"].size():
			continue
		if p["pos"].distance_to(e["pos"]) > 1.8:
			continue
		var c := Harmonics.can_add(p["recent"], e["note"], p["resolved_key"])
		if not c["ok"]:
			continue
		for v in e["voxels"]:
			p["voxels"].append(v + Vector3i(int(e["pos"].x - p["pos"].x), int(e["pos"].y - p["pos"].y), int(e["pos"].z - p["pos"].z)))
		if not VoxelShape.is_shape_connected(p["voxels"]):
			continue
		p["recent"] = c["recent"]
		p["resolved_key"] = c["key"]
		p["score"] += 0.25 * e["voxels"].size()
		eaten.append(e)
	for e in eaten:
		entities.erase(e)
	if elapsed - last_attrition >= attrition_interval(p["voxels"].size()):
		last_attrition = elapsed
		var legal := VoxelShape.legal_removals(p["voxels"])
		if legal.is_empty() or p["voxels"].size() < 3:
			push_error("Metabolism collapse")
		else:
			p["voxels"].erase(legal[0])
