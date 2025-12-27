# ============================================================
#  Scratch2Godot - Operation Helper Library
#  ------------------------------------------------------------
#  This module provides helper functions for arithmetic, logical,
#  string, and math operations in Godot, designed to replicate
#  the behavior of Scratch as closely as possible.
#
#  Included functionality:
#    - Arithmetic with NaN / Infinity protection
#    - Trigonometry (degrees-based)
#    - Type conversions (e.g., numbers to booleans)
#    - Comparison and random number functions
#
#
#  Author: Br0tcraft
#  Part of: Scratch2Godot
#  License: MIT
#
# Copyright (c) 2025 Br0tcraft
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# provided to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.
#
# License for games using this extension:
# - You are free to share and remix the game created with this extension.
# - Attribution must be given if the source code is shared.
# - If you distribute the source code, it must include proper credit to the 
#   original creators and translation contributors. (I would recommend to
#   just leave this note in this file)
# ===============================================================================

class_name op extends Node

# ========================================================
# ===                HELPER FUNCTIONS                  ===
# ========================================================

# Check if a float value is NaN (NaN != NaN)
static func _is_nan(value: float) -> bool:
	return value != value

# Check if a float value is infinity (+∞ or -∞)
static func _is_infinity(value: float) -> bool:
	return value == INF or value == -INF


# ========================================================
# ===              BASIC ARITHMETIC OPS                ===
# ========================================================

# Safe Addition: Handles NaN inputs
static func add(num1, num2):
	var a = float(num1)
	var b = float(num2)
	if _is_nan(a) and _is_nan(b): return 0
	if _is_nan(a): return b
	if _is_nan(b): return a
	return a + b

# Safe Subtraction with Infinity/NaN logic
static func sub(num1, num2):
	var a = float(num1)
	var b = float(num2)
	if _is_nan(a) and _is_nan(b): return 0
	if _is_nan(a): return -b
	if _is_nan(b): return a
	if _is_infinity(a) and _is_infinity(b): return NAN
	if _is_infinity(a): return a
	if _is_infinity(b): return -INF if b > 0 else INF
	return a - b

# Safe Division with 0, Infinity and NaN handling
static func div(num1, num2):
	var a = float(num1)
	var b = float(num2)
	if _is_nan(b): return 0 if _is_nan(a) else INF if a >= 0 else -INF
	if _is_nan(a): return 0
	if _is_infinity(a) and _is_infinity(b): return NAN
	if _is_infinity(a): return a
	if _is_infinity(b): return 0
	if b == 0: return INF if a >= 0 else -INF
	return a / b

# Safe Multiplication with NaN logic
static func mul(num1, num2):
	var a = float(num1)
	var b = float(num2)
	if _is_nan(a) or _is_nan(b): return 0
	return a * b


# ========================================================
# ===               RANDOM NUMBER OPS                  ===
# ========================================================

static func rand(from, to):
	var f_from = float(from) if str(from).is_valid_float() else float(0)
	var f_to   = float(to) if str(to).is_valid_float() else float(0)
	
	if _is_infinity(f_from): return f_from
	if _is_infinity(f_to): return f_to
	
	if str(from).is_valid_int() and str(to).is_valid_int():
		return randi_range(int(from), int(to))
	elif str(from).is_valid_float() or str(to).is_valid_float():
		return randf_range(f_from, f_to)
	return 0


# ========================================================
# ===               COMPARISON OPS                     ===
# ========================================================

static func greater(num1, num2):
	var a = float(num1) if str(num1).is_valid_float() else float(0)
	var b = float(num2) if str(num2).is_valid_float() else float(0)
	if _is_nan(a) or _is_nan(b): return false
	return a > b

static func less(num1, num2):
	var a = float(num1) if str(num1).is_valid_float() else float(0)
	var b = float(num2) if str(num2).is_valid_float() else float(0)
	if _is_nan(a) or _is_nan(b): return false
	return a < b

static func equal(num1, num2):
	return str(num1).to_lower() == str(num2).to_lower()


# ========================================================
# ===              BOOLEAN OPERATIONS                  ===
# ========================================================

static func to_boolean(value) -> bool:
	if str(value).is_valid_float():
		var num_val = float(value)
		return false if _is_nan(num_val) else num_val != 0
	if value is bool:
		return value
	return not str(value).is_empty()

static func and_(bool1, bool2) -> bool:
	return to_boolean(bool1) and to_boolean(bool2)

static func or_(bool1, bool2):
	return to_boolean(bool1) or to_boolean(bool2)

static func not_(bool1):
	return !to_boolean(bool1)


# ========================================================
# ===              STRING OPERATIONS                   ===
# ========================================================

static func join(str1, str2):
	return str(str1) + str(str2)

static func letter_of(num1, str1):
	var index = int(num1)
	var s = str(str1)
	if index < 0 or index >= s.length(): return ""
	return s[index]

static func lenght(str1):
	return str(str1).length()

static func contains(text, letter):
	return str(letter).to_lower() in str(text).to_lower()


# ========================================================
# ===        SAFE ARITHMETIC FUNCTIONS                 ===
# ========================================================

static func mod(num1, num2):
	var a = float(num1)
	var b = float(num2)
	if _is_infinity(a): return NAN
	if _is_infinity(b): return a
	if b == 0: return NAN
	return fmod(a, b)

static func round_(num1):
	if str(num1).is_valid_float():
		var a = float(num1)
		return a if _is_infinity(a) or _is_nan(a) else round(a)
	return 0

static func abs_of(num1):
	return abs(float(num1)) if str(num1).is_valid_float() else float(0)

static func floor_of(num1):
	if str(num1).is_valid_float():
		var a = float(num1)
		return a if _is_infinity(a) or _is_nan(a) else floor(a)
	return 0

static func ceilling_of(num1):
	if str(num1).is_valid_float():
		var a = float(num1)
		return a if _is_infinity(a) or _is_nan(a) else ceil(a)
	return 0

static func sqrt_of(num1):
	if str(num1).is_valid_float():
		var a = float(num1)
		if a < 0: return NAN
		if _is_infinity(a) or _is_nan(a): return a
		return sqrt(a)
	return 0


# ========================================================
# ===         TRIGONOMETRIC FUNCTIONS (DEG)           ===
# ========================================================

static func sin_of(num1):
	if str(num1).is_valid_float():
		var a = float(num1)
		return NAN if _is_infinity(a) or _is_nan(a) else sin(deg_to_rad(a))
	return 0

static func cos_of(num1):
	if str(num1).is_valid_float():
		var a = float(num1)
		return NAN if _is_infinity(a) or _is_nan(a) else cos(deg_to_rad(a))
	return 0

static func tan_of(num1):
	if str(num1).is_valid_float():
		var a = float(num1)
		return NAN if _is_infinity(a) or _is_nan(a) else tan(deg_to_rad(a))
	return 0

static func asin_of(num1):
	if str(num1).is_valid_float():
		var a = float(num1)
		if a < -1 or a > 1 or _is_infinity(a) or _is_nan(a): return NAN
		return rad_to_deg(asin(a))
	return 0

static func acos_of(num1):
	if str(num1).is_valid_float():
		var a = float(num1)
		if a < -1 or a > 1 or _is_infinity(a) or _is_nan(a): return NAN
		return rad_to_deg(acos(a))
	return 0

static func atan_of(num1):
	if str(num1).is_valid_float():
		var a = float(num1)
		if _is_infinity(a): return 90 if a > 0 else -90
		if _is_nan(a): return NAN
		return rad_to_deg(atan(a))
	return 0


# ========================================================
# ===         LOGARITHMIC & EXPONENTIAL FUNCS         ===
# ========================================================

static func ln_of(num1):
	if str(num1).is_valid_float():
		var a = float(num1)
		if a <= 0 or _is_infinity(a) or _is_nan(a): return NAN
		return log(a)
	return 0

static func log_of(num1):
	if str(num1).is_valid_float():
		var a = float(num1)
		if a <= 0 or _is_infinity(a) or _is_nan(a): return NAN
		return log(a) / log(10)
	return 0

static func e_to_the_(num1):
	if str(num1).is_valid_float():
		var a = float(num1)
		if _is_infinity(a): return INF
		if _is_nan(a): return 0
		return exp(a)
	return 0

static func ten_to_the_(num1):
	if str(num1).is_valid_float():
		var a = float(num1)
		if _is_infinity(a): return INF
		if _is_nan(a): return 0
		return pow(10, a)
	return 0


# ========================================================
# ===                 ANGLE UTILITIES                 ===
# ========================================================

# Normalizes angle to [-180, 180)
static func rotate(angle):
	angle = fmod(angle + 180, 360)
	if angle < 0: angle += 360
	return angle - 180
