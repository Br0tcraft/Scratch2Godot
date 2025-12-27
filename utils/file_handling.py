import subprocess
from PIL import Image
import numpy as np
try:
    import cv2
except Exception:
    cv2 = None
def resize_png_half(original_path: str, resized_path: str) -> None:
    try:
        with Image.open(original_path) as img:
            new_size = (img.width // 2, img.height // 2)
            resized_img = img.resize(new_size, Image.ANTIALIAS)
            resized_img.save(resized_path, "PNG")
    except Exception as e:
        print("resize_png_half: ", e)

def jpg_to_png(jpg_path: str, png_path: str) -> None:
    with Image.open(jpg_path) as im:
        im.save(png_path, "PNG")
        
def svg_to_png(svg_path: str, png_path: str, fonts: dict) -> None:
    def replace_font_names_in_svg():
        try:
            with open(svg_path, 'r') as file:
                data = file.read()
                for font in fonts:
                    data = data.replace(font, fonts[font])
            with open(svg_path, 'w') as file:
                file.write(data)
        except FileNotFoundError:
            print("File not found")
        except Exception as e:
            print("replace_font_names_in_svg: ", e)

    def convert_svg_to_png():
        try:
            subprocess.run(["magick", "-background", "none", svg_path, png_path], check=True)
        except Exception as e:
            logger.warning("Could not convert SVG to PNG with ImageMagick: %s; falling back to placeholder PNG", e)
            empty_png(png_path)

    def empty_png(png_path: str):
        try:
            with Image.new('RGB', (480, 360), color='white') as image:
                image.save(png_path, "PNG")
        except Exception as e:
            print("empty_png: ", e)

    replace_font_names_in_svg()
    convert_svg_to_png()

import logging
logger = logging.getLogger(__name__)

def collision_shape2d(png_path: str) -> str:
    if cv2 is None:
        logger.warning("cv2 (OpenCV) not available; using default collision polygon for %s", png_path)
        return "PackedVector2Array()\nposition = Vector2(0, 0)"
    try:
        img = Image.open(png_path).convert("L")
        img_array = np.array(img)
        _, binary = cv2.threshold(img_array, 1, 255, cv2.THRESH_BINARY)
        contours, _ = cv2.findContours(binary, cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_SIMPLE)
        if not contours:
            return "PackedVector2Array()\nposition = Vector2(0, 0)"
        contour = max(contours, key=cv2.contourArea)
        hull = cv2.convexHull(contour)  # <--- Wichtig!
        points = [(int(pt[0][0]), int(pt[0][1])) for pt in hull]
        godot_polygon = ", ".join([f"{x}, {y}" for x, y in points])
        return f"PackedVector2Array({godot_polygon})\nposition = Vector2({img.size[0] // -2}, {img.size[1] // -2})"
    except Exception as e:
        logger.exception("Error creating collision polygon for %s: %s", png_path, e)
        return "PackedVector2Array()\nposition = Vector2(0, 0)"
    
def import_file(name: str, uid: str) -> str:
    '''This is uninteresting, it makes just an .import file for every costume with stuff i don't understand (This is copy paste)'''
    random_uid = f"uid://{uid}"
    random_id =  f"id_{uid}"
    vram = '''{
"vram_texture": false
}'''
    text = f"""[remap]
importer="texture"
type="CompressedTexture2D"
uid="{random_uid}"
path="res://.godot/imported/{name}-{random_id}.ctex"
metadata={vram}
[deps]
source_file="res://{name}"
dest_files=["res://.godot/imported/{name}-{random_id}.ctex"]
[params]
compress/mode=0
compress/high_quality=false
compress/lossy_quality=0.7
compress/hdr_compression=1
compress/normal_map=0
compress/channel_pack=0
mipmaps/generate=false
mipmaps/limit=-1
roughness/mode=0
roughness/src_normal=""
process/fix_alpha_border=true
process/premult_alpha=false
process/normal_map_invert_y=false
process/hdr_as_srgb=false
process/hdr_clamp_exposure=false
process/size_limit=0
detect_3d/compress_to=1"""
    return text