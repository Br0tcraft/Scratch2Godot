import os

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
    "space": "Key.SPACE",
    "left arrow": "Key.LEFT",
    "right arrow": "Key.RIGHT",
    "up arrow": "Key.UP",
    "down arrow": "Key.DOWN",
    "enter": "Key.ENTER",
    "backspace": "Key.BACKSPACE",
    "delete": "Key.DELETE",
    "escape": "Key.ESCAPE",
    "shift": "Key.SHIFT",
    "control": "Key.CTRL",
    "caps lock": "Key.CAPSLOCK",
    "page up": "Key.PAGEUP",
    "page down": "Key.PAGEDOWN",
    "home": "Key.HOME",
    "end": "Key.END",
    "insert": "Key.INSERT",
    "scroll lock": "Key.SCROLLLOCK",
    ".": "Key.PERIOD",
    ",": "Key.COMMA"
}

def convert_key(scratch_key):
    scratch_key = scratch_key.lower()

    if scratch_key in scratch_to_godot_keys:
        return scratch_to_godot_keys[scratch_key]
    elif len(scratch_key) == 1:
        if scratch_key.isalpha():
            return f"Key.{scratch_key.upper()}"
        elif scratch_key.isdigit():
            return f"Key.{scratch_key}"
        elif scratch_key in "+-*/":
            special_chars = {
                "+": "PLUS",
                "-": "MINUS",
                "*": "ASTERISK",
                "/": "SLASH"
            }
            return f"Key.{special_chars[scratch_key]}"
    return "Key.UNKNOWN"

    
    
if __name__ == "__main__":
    # Test the function
    print(convert_key("space"))  # Output: KEY_SPACE
    print(convert_key("a"))      # Output: KEY_A
    print(convert_key("1"))      # Output: KEY_1
    print(convert_key("unknown")) # Output: KEY_UNKNOWN
