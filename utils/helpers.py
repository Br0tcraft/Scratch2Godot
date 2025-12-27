import os
import logging


def init_logging(debug: bool=False) -> None:
    """Initialize module-level logging configuration.
    Call this once at program startup. When debug is True, set level to DEBUG.
    """
    level = logging.DEBUG if debug else logging.INFO
    logging.basicConfig(level=level, format='%(levelname)s: %(message)s')
    logging.getLogger("PIL").setLevel(logging.WARNING)
    logging.debug(f"Logging initialized (debug={debug})")

def create_folders(temp_dir: str) -> None:
    '''
    Create the temp_dir folder and the folders for the Godot-game inside of the temp_dir folder:
    /Godotgame
    /Godotgame/sprites
    /Godotgame/costumes
    /Godotgame/scripts
    /Godotgame/.godot
    /Godotgame/.godot/imported
    '''
    temp_dir = str(temp_dir)
    os.makedirs(temp_dir, exist_ok=True)
    os.makedirs(temp_dir + "/Godotgame", exist_ok=True)
    os.makedirs(temp_dir + "/Godotgame/sprites", exist_ok=True)
    os.makedirs(temp_dir + "/Godotgame/costumes", exist_ok=True)
    os.makedirs(temp_dir + "/Godotgame/scripts", exist_ok=True)
    os.makedirs(temp_dir + "/Godotgame/.godot", exist_ok=True)
    os.makedirs(temp_dir + "/Godotgame/.godot/imported", exist_ok=True)
    os.makedirs(temp_dir + "/Godotgame/assets", exist_ok=True)

def get_loop_varname(depth: int) -> str:
    base = "ijklmnopqrstuvwxyz"
    length = len(base)

    if depth <= length:
        return base[depth - 1]

    name = ""
    while depth >= 0:
        name = base[(depth % length) - 1] + name
        depth = (depth // length) - 1
    return name


scratch_to_godot_keys = {
    # Special keys
    "space": "KEY_SPACE",
    "left arrow": "KEY_LEFT",
    "right arrow": "KEY_RIGHT",
    "up arrow": "KEY_UP",
    "down arrow": "KEY_DOWN",
    "enter": "KEY_ENTER",
    "backspace": "KEY_BACKSPACE",
    "delete": "KEY_DELETE",
    "escape": "KEY_ESCAPE",
    "shift": "KEY_SHIFT",
    "control": "KEY_CTRL",
    "caps lock": "KEY_CAPSLOCK",
    "page up": "KEY_PAGEUP",
    "page down": "KEY_PAGEDOWN",
    "home": "KEY_HOME",
    "end": "KEY_END",
    "insert": "KEY_INSERT",
    "scroll lock": "KEY_SCROLLLOCK",
    ".": "KEY_PERIOD",
    ",": "KEY_COMMA",
    "+": "PLUS",
    "-": "MINUS",
    "*": "ASTERISK",
    "/": "SLASH"
}

def convert_key(scratch_key):
    scratch_key = scratch_key.lower()

    if scratch_key in scratch_to_godot_keys:
        return scratch_to_godot_keys[scratch_key]
    elif len(scratch_key) == 1:
        if scratch_key.isalpha():
            return f"KEY_{scratch_key.upper()}"
        elif scratch_key.isdigit():
            return f"KEY_{scratch_key}"
    return "Key.UNKNOWN"

    
def normalize_to_latin_godot_style(text: str) -> str:
    # Deutsche Sonderzeichen
    replacements = {
        'Ä': 'AE', 'ä': 'ae',
        'Ö': 'OE', 'ö': 'oe',
        'Ü': 'UE', 'ü': 'ue',
        'ß': 'ss'
    }

    for original, replacement in replacements.items():
        text = text.replace(original, replacement)

    # Manuell definierte diakritische Zeichen
    basic_replacements = {
        'é': 'e', 'è': 'e', 'ê': 'e', 'ë': 'e',
        'á': 'a', 'à': 'a', 'â': 'a',
        'ú': 'u', 'ù': 'u', 'û': 'u',
        'í': 'i', 'ì': 'i', 'î': 'i', 'ï': 'i',
        'ó': 'o', 'ò': 'o', 'ô': 'o',
        'ñ': 'n', 'ç': 'c'
    }

    for original, replacement in basic_replacements.items():
        text = text.replace(original, replacement)

    # Zeichenweise umwandeln
    result = ""
    for c in text:
        if c.isascii() and c.isalnum():
            result += c
        else:
            result += f"_U{ord(c)}_"

    return result

    
if __name__ == "__main__":
   print(normalize_to_latin_godot_style("Birne & Äpfel – 北京 😊"))