import sys, os
sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), '..')))
from utils.block_parser import repeat_content


def make_var_block(opcode, listname=None, index=None, item=None):
    b = {"opcode": opcode, "fields": {}, "inputs": {}, "next": None}
    if listname:
        b["fields"]["LIST"] = [listname]
    if index:
        b["inputs"]["INDEX"] = [1, [1, str(index)]]
    if item:
        b["inputs"]["ITEM"] = [1, [1, str(item)]]
    return b


def test_data_itemoflist_reporter():
    b = make_var_block("data_itemoflist", listname="L", index=2)
    # repeat_content expects a parent block wrapper for value structure, emulate it
    parent = {"opcode": "reporter_holder", "inputs": {"VALUE": [1, [1, 2]]}, "fields": {}}
    # Use repeat_content by passing in the inner block as if it referenced it; here we just check the string
    # Simulate a block environment where the reporter is directly passed
    blocks = {0: b}
    # since repeat_content expects an opcode in block, give it
    res = repeat_content({"v": b}, b, "INDEX")  # this is to execute path
    assert res is not None


def test_data_lengthoflist():
    b = make_var_block("data_lengthoflist", listname="L")
    res = repeat_content({"v": b}, b, "INDEX")
    assert res is not None
