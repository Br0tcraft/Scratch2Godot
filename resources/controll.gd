class_name op extends Node

# --- Hilfsfunktionen ---

# Prüft, ob value NaN ist (NaN ist das einzige, das sich selbst nicht gleicht)
static func _is_nan(value: float) -> bool:
	return value != value

# Prüft, ob value unendlich ist
static func _is_infinity(value: float) -> bool:
	return value == INF or value == -INF

# Addition: x + y
# Regeln:
# - NaN + NaN = 0
# - NaN + x = x
# - x + NaN = x
static func add(num1, num2):
	var a = float(num1)
	var b = float(num2)
	if _is_nan(a) and _is_nan(b):
		return 0
	if _is_nan(a):
		return b
	if _is_nan(b):
		return a
	return a + b

# Subtraktion: x - y
# Regeln:
# - NaN - NaN = 0
# - NaN - x = -x
# - x - NaN = x
# - Infinity - Infinity = NaN
# - Infinity - x = Infinity (Vorzeichen beibehalten)
# - x - Infinity = -Infinity, x - (-Infinity) = Infinity
static func sub(num1, num2):
	var a = float(num1)
	var b = float(num2)
	if _is_nan(a) and _is_nan(b):
		return 0
	if _is_nan(a):
		return -b
	if _is_nan(b):
		return a
	if _is_infinity(a) and _is_infinity(b):
		return NAN
	if _is_infinity(a):
		return a
	if _is_infinity(b):
		return -INF if b > 0 else INF
	return a - b

# Division: x / y
# Regeln:
# - x / 0 = Infinity (je nach Vorzeichen von x)
# - x / Infinity = 0
# - Infinity / Infinity = NaN
# - Infinity / x = Infinity (Vorzeichen beibehalten)
# - x / NaN: +y / NaN = Infinity, -y / NaN = -Infinity; NaN / NaN = 0, NaN / x = 0
static func div(num1, num2):
	var a = float(num1)
	var b = float(num2)
	if _is_nan(b):
		if _is_nan(a):
			return 0
		return INF if a >= 0 else -INF
	if _is_nan(a):
		return 0
	if _is_infinity(a) and _is_infinity(b):
		return NAN
	if _is_infinity(a):
		return a
	if _is_infinity(b):
		return 0
	if b == 0:
		return INF if a >= 0 else -INF
	return a / b

# Multiplikation: x * y
# Regeln:
# - x * NaN = 0
# - NaN * NaN = 0
static func mul(num1, num2):
	var a = float(num1)
	var b = float(num2)
	if _is_nan(a) or _is_nan(b):
		return 0
	return a * b

static func rand(from, to):
	# Konvertiere Eingaben zu Float, falls möglich, sonst 0
	var f_from = float(from) if str(from).is_valid_float() else 0
	var f_to   = float(to) if str(to).is_valid_float() else 0
	
	# Falls einer der Werte unendlich ist, gib diesen zurück (Vorzeichen beibehalten)
	if _is_infinity(f_from):
		return f_from
	if _is_infinity(f_to):
		return f_to
	
	# Wenn beide ganzzahlig erscheinen, nutze randi_range
	if str(from).is_valid_int() and str(to).is_valid_int():
		return randi_range(int(from), int(to))
	elif str(from).is_valid_float() or str(to).is_valid_float():
		return randf_range(f_from, f_to)
	return 0

# --- Vergleichsoperationen ---

static func greater(num1, num2):
	var a = float(num1) if str(num1).is_valid_float() else 0
	var b = float(num2) if str(num2).is_valid_float() else 0
	# Falls einer der Werte NaN ist, liefert der Vergleich false
	if _is_nan(a) or _is_nan(b):
		return false
	return a > b

static func less(num1, num2):
	var a = float(num1) if str(num1).is_valid_float() else 0
	var b = float(num2) if str(num2).is_valid_float() else 0
	if _is_nan(a) or _is_nan(b):
		return false
	return a < b

static func equal(num1, num2):
	return str(num1).to_lower() == str(num2).to_lower()

# --- Boolesche Operationen ---

static func to_boolean(value) -> bool:
	if str(value).is_valid_float():
		var num_val = float(value)
		if _is_nan(num_val):
			return false
		return num_val != 0
	if value is bool:
		return value
	return not str(value).is_empty()  # Nur leere Strings gelten als false

static func and_(bool1, bool2) -> bool:
	return to_boolean(bool1) and to_boolean(bool2)
	
static func or_(bool1, bool2):
	return to_boolean(bool1) or to_boolean(bool2)

static func not_(bool1):
	return !to_boolean(bool1)

# --- String-Operationen ---

static func join(str1, str2):
	return str(str1) + str(str2)
	
static func letter_of(num1, str1):
	var index = int(num1)
	var s = str(str1)
	if index < 0 or index >= s.length():
		return ""
	return s[index]
	
static func lenght(str1):
	return str(str1).length()

static func contains(text, letter):
	return str(letter).to_lower() in str(text).to_lower()

# --- Arithmetische Operationen mit Sicherheitsprüfungen ---

static func mod(num1, num2):
	var a = float(num1)
	var b = float(num2)
	if _is_infinity(a) and _is_infinity(b):
		return NAN  # ∞ % ∞ = NaN
	if _is_infinity(a):
		return NAN  # ∞ % x = NaN
	if _is_infinity(b):
		return a    # x % ∞ = x
	if b == 0:
		return NAN  # Division durch 0
	return fmod(a, b)

static func round_(num1):
	if str(num1).is_valid_float():
		var a = float(num1)
		if _is_infinity(a) or _is_nan(a):
			return a
		return round(a)
	return 0

static func abs_of(num1):
	if str(num1).is_valid_float():
		return abs(float(num1))
	return 0
	
static func floor_of(num1):
	if str(num1).is_valid_float():
		var a = float(num1)
		if _is_infinity(a) or _is_nan(a):
			return a
		return floor(a)
	return 0
	
static func ceilling_of(num1):
	if str(num1).is_valid_float():
		var a = float(num1)
		if _is_infinity(a) or _is_nan(a):
			return a
		return ceil(a)
	return 0
	
static func sqrt_of(num1):
	if str(num1).is_valid_float():
		var a = float(num1)
		# Negative Werte führen zu NaN
		if a < 0:
			return NAN
		if _is_infinity(a) or _is_nan(a):
			return a
		return sqrt(a)
	return 0

# --- Trigonometrische Funktionen mit Sicherheitsprüfungen ---
# Alle Winkelwerte werden in Grad angegeben, da Scratch hier so arbeitet.

static func sin_of(num1):
	if str(num1).is_valid_float():
		var a = float(num1)
		# Werte außerhalb eines sinnvollen Bereichs liefern NaN
		if _is_infinity(a) or _is_nan(a):
			return NAN
		return sin(deg_to_rad(a))
	return 0
	
static func cos_of(num1):
	if str(num1).is_valid_float():
		var a = float(num1)
		if _is_infinity(a) or _is_nan(a):
			return NAN
		return cos(deg_to_rad(a))
	return 0
	
static func tan_of(num1):
	if str(num1).is_valid_float():
		var a = float(num1)
		if _is_infinity(a) or _is_nan(a):
			return NAN
		return tan(deg_to_rad(a))
	return 0
	
static func asin_of(num1):
	if str(num1).is_valid_float():
		var a = float(num1)
		# asin ist nur für Werte zwischen -1 und 1 definiert
		if a < -1 or a > 1 or _is_infinity(a) or _is_nan(a):
			return NAN
		return rad_to_deg(asin(a))
	return 0
	
static func acos_of(num1):
	if str(num1).is_valid_float():
		var a = float(num1)
		# acos ist nur für Werte zwischen -1 und 1 definiert
		if a < -1 or a > 1 or _is_infinity(a) or _is_nan(a):
			return NAN
		return rad_to_deg(acos(a))
	return 0
	
static func atan_of(num1):
	if str(num1).is_valid_float():
		var a = float(num1)
		# Bei unendlichen Werten: arctan(∞)=90°, arctan(-∞)=-90°
		if _is_infinity(a):
			return 90 if a > 0 else -90
		if _is_nan(a):
			return NAN
		return rad_to_deg(atan(a))
	return 0

static func ln_of(num1):
	if str(num1).is_valid_float():
		var a = float(num1)
		# ln ist nur für positive Zahlen definiert
		if a <= 0 or _is_infinity(a) or _is_nan(a):
			return NAN
		return log(a)
	return 0
	
static func log_of(num1):
	if str(num1).is_valid_float():
		var a = float(num1)
		if a <= 0 or _is_infinity(a) or _is_nan(a):
			return NAN
		return log(a) / log(10)
	return 0
	
static func e_to_the_(num1):
	if str(num1).is_valid_float():
		var a = float(num1)
		if _is_infinity(a):
			return INF
		if _is_nan(a):
			return 0
		return exp(a)
	return 0
	
static func ten_to_the_(num1):
	if str(num1).is_valid_float():
		var a = float(num1)
		if _is_infinity(a):
			return INF
		if _is_nan(a):
			return 0
		return pow(10, a)
	return 0

static func rotate(angle):
	angle = fmod(angle + 180, 360)
	if angle < 0:
		angle += 360
	return angle - 180
