extends AnimatedSprite2D

var broadcast := ""
var broadcastlist := {}

func normalize_to_latin(text: String) -> String:
	var replacements = {
		"Ä": "AE", "ä": "ae",
		"Ö": "OE", "ö": "oe",
		"Ü": "UE", "ü": "ue",
		"ß": "ss"
	}

	for original in replacements.keys():
		text = text.replace(original, replacements[original])

	var basic_replacements = {
		"é": "e", "è": "e", "ê": "e", "ë": "e",
		"á": "a", "à": "a", "â": "a", "ä": "ae",
		"ú": "u", "ù": "u", "û": "u", "ü": "ue",
		"í": "i", "ì": "i", "î": "i", "ï": "i",
		"ó": "o", "ò": "o", "ô": "o", "ö": "oe",
		"ñ": "n", "ç": "c"
	}
	for original in replacements.keys():
		text = text.replace(original, replacements[original])
	for original in basic_replacements.keys():
		text = text.replace(original, basic_replacements[original])
	var result := ""
	for i in text.length():
		var c := text.substr(i, 1)
		var code := c.unicode_at(0)
		if (code >= 48 and code <= 57) or (code >= 65 and code <= 90) or (code >= 97 and code <= 122):
			result += c
		else:
			result += "_U%d_" % code
	return result