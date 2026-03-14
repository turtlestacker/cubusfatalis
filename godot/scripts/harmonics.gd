extends RefCounted
class_name Harmonics

const NOTES := ["C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B"]
const MAJOR_STEPS := [0, 2, 4, 5, 7, 9, 11]
const MINOR_STEPS := [0, 2, 3, 5, 7, 8, 10]
const CIRCLE_FIFTHS := ["C", "G", "D", "A", "E", "B", "F#", "C#", "G#", "D#", "A#", "F"]

static func build_keys() -> Array:
	var keys: Array = []
	for i in range(NOTES.size()):
		var major: Dictionary = {}
		for step in MAJOR_STEPS:
			major[(i + step) % 12] = true
		keys.append({"name": "%s major" % NOTES[i], "set": major})
	for i in range(NOTES.size()):
		var minor: Dictionary = {}
		for step in MINOR_STEPS:
			minor[(i + step) % 12] = true
		keys.append({"name": "%s minor" % NOTES[i], "set": minor})
	return keys

static func resolve_key(active_notes: Array, prev_key: String) -> String:
	var keys: Array = build_keys()
	var candidates: Array = []
	for k in keys:
		var ok: bool = true
		for n in active_notes:
			if not k["set"].has(n):
				ok = false
				break
		if ok:
			var tonic: String = k["name"].split(" ")[0]
			candidates.append({"name": k["name"], "tonic_present": active_notes.has(NOTES.find(tonic))})
	if candidates.is_empty():
		return ""
	for c in candidates:
		if c["name"] == prev_key:
			return prev_key
	candidates = candidates.filter(func(c: Dictionary) -> bool: return bool(c["tonic_present"]))
	if candidates.is_empty():
		candidates = []
		for k in keys:
			var ok2: bool = true
			for n2 in active_notes:
				if not k["set"].has(n2):
					ok2 = false
					break
			if ok2:
				candidates.append({"name": k["name"], "tonic_present": false})
	if prev_key != "":
		var prev_tonic: String = prev_key.split(" ")[0]
		if CIRCLE_FIFTHS.has(prev_tonic):
			var p_idx: int = CIRCLE_FIFTHS.find(prev_tonic)
			candidates.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
				var ta: String = a["name"].split(" ")[0]
				var tb: String = b["name"].split(" ")[0]
				var da: int = abs(CIRCLE_FIFTHS.find(ta) - p_idx)
				var db: int = abs(CIRCLE_FIFTHS.find(tb) - p_idx)
				return mini(da, 12 - da) < mini(db, 12 - db)
			)
	return str(candidates[0]["name"])

static func can_add(recent_unique: Array, note_idx: int, prev_key: String) -> Dictionary:
	var tmp: Array = recent_unique.duplicate()
	if tmp.has(note_idx):
		tmp.erase(note_idx)
	tmp.append(note_idx)
	if tmp.size() > 4:
		tmp = tmp.slice(tmp.size() - 4, tmp.size())
	var key: String = resolve_key(tmp, prev_key)
	return {"ok": key != "", "key": key, "recent": tmp}
