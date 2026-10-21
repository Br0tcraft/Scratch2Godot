class_name S
extends RefCounted

static func num(v: Variant) -> float:
    if v is float or v is int: return float(v)
    if v is bool: return 1.0 if v else 0.0
    if v is String:
        var s := (v as String).strip_edges()
        if s.is_valid_float(): return s.to_float()
    return 0.0

static func str(v: Variant) -> String:
    match typeof(v):
        TYPE_NIL:
            return ""
        TYPE_BOOL:
            return "true" if v else "false"
        TYPE_INT:
            return String.num_int64(v)
        TYPE_FLOAT:
            var f: float = v
            if is_nan(f):
                return "NaN"
            if is_inf(f):
                return "-Infinity" if f < 0 else "Infinity"
            if is_finite(f) and f == floor(f):
                if abs(f) < 9e18:
                    return String.num_int64(int(f))
            return "%s" % [f]
        TYPE_STRING:
            return (v as String).replace("\n", " ").replace("\r", "")
            
    return "%s" % [v]

static func boolean(a: Variant) -> bool:
    if typeof(a) in [TYPE_INT, TYPE_FLOAT, TYPE_BOOL]:
        return is_equal_approx(float(a), 1.0)
	
    var na = _try_num(a)
    if na != null:
        return is_equal_approx(na, 1.0)
		
    return S.str(a).to_lower() == S.str(0).to_lower()

static func equals(a: Variant, b: Variant) -> bool:
    var na = _try_num(a)
    var nb = _try_num(b)
    if na != null and nb != null: return is_equal_approx(na, nb)
    return S.str(a).to_lower() == S.str(b).to_lower()

static func compare(a: Variant, b: Variant) -> int:
    var na = _try_num(a)
    var nb = _try_num(b)
    if na != null and nb != null:
        if na < nb: return -1
        if na > nb: return 1
        return 0
    
    var sa := S.str(a).to_lower()
    var sb := S.str(b).to_lower()
    if sa < sb: return -1
    if sa > sb: return 1
    return 0

static func _try_num(v: Variant) -> Variant:
    if typeof(v) in [TYPE_INT, TYPE_FLOAT]:
        return float(v)
    if typeof(v) == TYPE_BOOL:
        return 1.0 if v else 0.0
    if typeof(v) == TYPE_STRING:
        var s := (v as String).strip_edges()
        if s.is_valid_float(): return s.to_float()
    return null
const LIST_ITEM_LIMIT := 200_000

static func list_item(list: Array, index) -> Variant:
    var i := _resolve_list_index(index, list.size(), false)
    return list[i - 1] if i > 0 else ""

static func list_index_of(list: Array, item: Variant) -> int:
    for i in list.size():
        if compare(list[i], item) == 0: return i + 1
    return 0

static func list_delete(list: Array, index) -> void:
    var i := _resolve_list_index(index, list.size(), true)
    if i == -1: return
    if i == -2: list.clear(); return
    list.remove_at(i - 1)

static func list_insert(list: Array, index, item: Variant) -> void:
    var i := _resolve_list_index(index, list.size() + 1, false)
    if i <= 0 or i > LIST_ITEM_LIMIT: return
    list.insert(i - 1, item)
    if list.size() > LIST_ITEM_LIMIT: list.pop_back()

static func list_set(list: Array, index, item: Variant) -> void:
    var i := _resolve_list_index(index, list.size(), false)
    if i <= 0: return
    list[i - 1] = item

static func list_join(list: Array, sep: String) -> String:
    var all_single := true
    for x in list:
        if not (x is String and (x as String).length() == 1):
            all_single = false; break
    return ("" if all_single else sep).join(list.map(func(x): return S.str(x)))

static func _resolve_list_index(index, len: int, allow_all: bool) -> int:
    if index is String:
        var s := (index as String).to_lower().strip_edges()
        if s == "last": return len
        if s == "random": return randi_range(1, max(1, len))
        if allow_all and s == "all": return -1
    var n := int(round(num(index)))
    if n < 1 or n > len:
        if allow_all and n == 0: return -1
        return 0
    return n