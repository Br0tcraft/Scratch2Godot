import sys, os
sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), '..')))
from utils.block_parser import create_gd_script
import shutil


def test_script_header_contains_clone_flags(tmp_path):
    blocks = {
        "start": {"opcode": "event_whenflagclicked", "next": None}
    }
    path = str(tmp_path) + os.sep
    # create script
    create_gd_script(blocks, "start", path, "testname", "Sprite")
    content = open(f"{path}testname.gd","r",encoding="utf-8").read()
    assert "__is_clone" in content
    assert "__clone_id" in content
    shutil.rmtree(path, ignore_errors=True
)