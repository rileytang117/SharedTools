"""从 INP 导出自由度映射 DofMap.txt。"""

import sys
sys.dont_write_bytecode = True

from extraction_io import read_paths, write_numeric_rows
from input_constraints import get_free_dof_map, read_input_model, uniform_structural_dofs


def export_dof_map(input_file_path, data_folder):
    """按节点编号和自由度编号排序，为自由自由度分配连续矩阵行号。"""
    model = read_input_model(input_file_path)
    active_dofs = uniform_structural_dofs(model)
    free, _ = get_free_dof_map(model, ((node, dof) for node in model["nodes"] for dof in active_dofs))
    rows = ((row, node, dof) for row, (node, dof) in enumerate(free, 1))
    write_numeric_rows(data_folder / "DofMap.txt", rows, integer=True)


if __name__ == "__main__":
    export_dof_map(*read_paths())
