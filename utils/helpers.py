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