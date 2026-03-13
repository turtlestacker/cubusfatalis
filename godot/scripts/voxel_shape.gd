extends RefCounted
class_name VoxelShape

const N := [Vector3i(1,0,0), Vector3i(-1,0,0), Vector3i(0,1,0), Vector3i(0,-1,0), Vector3i(0,0,1), Vector3i(0,0,-1)]

static func to_set(voxels: Array) -> Dictionary:
	var d := {}
	for v in voxels:
		d[v] = true
	return d

static func is_connected(voxels: Array) -> bool:
	if voxels.is_empty():
		return false
	var set := to_set(voxels)
	var q: Array = [voxels[0]]
	var seen := {voxels[0]: true}
	while not q.is_empty():
		var v: Vector3i = q.pop_front()
		for d in N:
			var n: Vector3i = v + d
			if set.has(n) and not seen.has(n):
				seen[n] = true
				q.append(n)
	return seen.size() == set.size()

static func surface_voxels(voxels: Array) -> Array:
	var out: Array = []
	var set := to_set(voxels)
	for v in voxels:
		for d in N:
			if not set.has(v + d):
				out.append(v)
				break
	return out

static func legal_removals(voxels: Array) -> Array:
	var legal: Array = []
	for c in surface_voxels(voxels):
		var t := voxels.duplicate()
		t.erase(c)
		if not t.is_empty() and is_connected(t):
			legal.append(c)
	return legal
