"""从同名 ODB 的 ModalAnalysis 分析步导出实模态矩阵。"""

import sys
sys.dont_write_bytecode = True

from odbAccess import openOdb
from extraction_io import get_mode_frames, get_single_instance, read_dof_data, read_nodal_displacements, read_paths, write_numeric_rows


def export_modal_matrix(input_file_path, data_folder, dof_map, constrained):
    """导出自由度为行、模态为列的模态矩阵，保留 Abaqus 中的归一化方式。"""
    odb = openOdb(path=str(input_file_path.with_suffix(".odb")), readOnly=True)
    try:
        instance = get_single_instance(odb)
        expected_nodes = {node for _, node, _ in dof_map} | {node for node, _ in constrained}
        if {node.label for node in instance.nodes} != expected_nodes:
            raise ValueError("ODB node labels do not match the supplied DOF data.")
        frames = get_mode_frames(odb.steps["ModalAnalysis"])
        modal_vectors = [read_nodal_displacements(frame, instance, dof_map) for frame in frames]
        write_numeric_rows(data_folder / "ModeShapeMatrix.txt", zip(*modal_vectors))
    finally:
        odb.close()


if __name__ == "__main__":
    input_file_path, data_folder = read_paths()
    dof_map, constrained = read_dof_data()
    export_modal_matrix(input_file_path, data_folder, dof_map, constrained)
