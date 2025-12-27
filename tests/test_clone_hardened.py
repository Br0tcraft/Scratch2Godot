import sys, os
sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), '..')))
from utils.block_parser import convert_blocks


def make_block(opcode, fields=None, inputs=None, next=None):
    return {
        "opcode": opcode,
        "fields": fields or {},
        "inputs": inputs or {},
        "next": next
    }


def test_clone_copies_groups_and_children_and_flags():
    blocks = {
        "b1": make_block("control_create_clone_of", inputs={"CLONE_OPTION": [1, [1, "mySprite"]]}, next=None)
    }
    code = convert_blocks(blocks, blocks["b1"], "\nfunc _test():\n", "test", 1)
    assert "add_to_group" in code
    assert "get_children" in code
    assert "__is_clone" in code and "__clone_id" in code
