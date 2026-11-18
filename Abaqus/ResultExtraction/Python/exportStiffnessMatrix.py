"""从同作业的 _STIF1.mtx 文件导出线性刚度矩阵。"""

import sys
sys.dont_write_bytecode = True

from extraction_io import read_dof_data, read_paths
from matrix_io import export_structural_matrix


def export_stiffness_matrix(input_file_path, data_folder, dof_map, constrained):
    """按 DofMap 重排线性刚度矩阵并去除约束自由度。"""
    export_structural_matrix(input_file_path, data_folder, "stiffness", dof_map, constrained)


if __name__ == "__main__":
    input_file_path, data_folder = read_paths()
    dof_map, constrained = read_dof_data()
    export_stiffness_matrix(input_file_path, data_folder, dof_map, constrained)
