import os
import sys
sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), '..')))
from main import Convert_game, settings


def test_sample_conversion():
    src = "temp/ScratchProject.sb3"
    out = Convert_game(src, {**settings, "debug": True})
    assert out and os.path.exists(out)
    print("Conversion created:", out)
