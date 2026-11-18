"""从同作业的 _MASS1.mtx 文件导出质量矩阵。"""

import sys
sys.dont_write_bytecode = True

from extraction_io import read_dof_data, read_paths
from matrix_io import export_structural_matrix


def export_mass_matrix(input_file_path, data_folder, dof_map, constrained):
    """按 DofMap 重排质量矩阵并去除约束自由度。"""
    export_structural_matrix(input_file_path, data_folder, "mass", dof_map, constrained)


if __name__ == "__main__":
    input_file_path, data_folder = read_paths()
    dof_map, constrained = read_dof_data()
    export_mass_matrix(input_file_path, data_folder, dof_map, constrained)
