"""从 INP 导出约束自由度 ConstrainedDofs.txt。"""

import sys
sys.dont_write_bytecode = True

from extraction_io import read_paths, write_numeric_rows
from input_constraints import read_input_model, uniform_structural_dofs


def export_constrained_dofs(input_file_path, data_folder):
    """提取实际激活且受到零位移或零转角约束的自由度。"""
    model = read_input_model(input_file_path)
    active_dofs = uniform_structural_dofs(model)
    constrained = [(node, dof) for node in sorted(model["nodes"]) for dof in active_dofs if (model["instance"], node, dof) in model["constrained_dofs"]]
    write_numeric_rows(data_folder / "ConstrainedDofs.txt", constrained, integer=True)


if __name__ == "__main__":
    export_constrained_dofs(*read_paths())
