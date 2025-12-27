import sys, os
sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), '..')))
import pytest
from utils.block_parser import convert_blocks, repeat_content


def make_block(opcode, fields=None, inputs=None, next=None):
    return {
        "opcode": opcode,
        "fields": fields or {},
        "inputs": inputs or {},
        "next": next
    }


def test_add_to_list_generates_append():
    blocks = {
        "b1": make_block("data_addtolist", fields={"LIST":["mylist"]}, inputs={"ITEM": [1, [1, "hello"]]}, next=None)
    }
    code = convert_blocks(blocks, blocks["b1"], "\nfunc _test():\n", "test", 1)
    assert "mylist" in code
    assert ".append(" in code


def test_delete_of_list_generates_remove():
    blocks = {
        "b1": make_block("data_deleteoflist", fields={"LIST":["mylist"]}, inputs={"INDEX": [1, [1, "1"]]}, next=None)
    }
    code = convert_blocks(blocks, blocks["b1"], "\nfunc _test():\n", "test", 1)
    assert "remove_at" in code or "erase" in code


def test_replace_item_of_list_generates_assignment():
    blocks = {
        "b1": make_block("data_replaceitemoflist", fields={"LIST":["mylist"]}, inputs={"INDEX": [1, [1, "2"]], "ITEM": [1, [1, "new"]]}, next=None)
    }
    code = convert_blocks(blocks, blocks["b1"], "\nfunc _test():\n", "test", 1)
    assert "main.mylist" in code and "=" in code


def test_set_list_item_generates_append_or_assign():
    blocks = {
        "b1": make_block("data_setlistitem", fields={"LIST":["mylist"]}, inputs={"INDEX": [1, [1, "100"]], "ITEM": [1, [1, "x"]]}, next=None)
    }
    code = convert_blocks(blocks, blocks["b1"], "\nfunc _test():\n", "test", 1)
    assert "append(" in code or "[__pos]" in code


def test_create_clone_uses_instantiate_or_duplicate_and_sets_flags():
    blocks = {
        "b1": make_block("control_create_clone_of", inputs={"CLONE_OPTION": [1, [1, "mySprite"]]}, next=None)
    }
    code = convert_blocks(blocks, blocks["b1"], "\nfunc _test():\n", "test", 1)
    assert "instantiate" in code or "duplicate" in code
    assert "__is_clone" in code and "__clone_id" in code
