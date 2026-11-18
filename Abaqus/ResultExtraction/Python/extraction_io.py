"""共享命令行解析、自由度数据读取、数值写出和 ODB 节点结果读取。"""

import argparse
import json
import math
import sys
from pathlib import Path


def read_paths():
    """读取输入文件路径和结果保存目录。"""
    parser = argparse.ArgumentParser()
    parser.add_argument("input_file", help="Abaqus INP file path.")
    parser.add_argument("data_folder", help="Output data folder.")
    args = parser.parse_args()
    return Path(args.input_file).resolve(), Path(args.data_folder).resolve()


def read_dof_data():
    """读取 MATLAB 通过标准输入传入的自由度映射和约束自由度。"""
    metadata = json.load(sys.stdin)
    values = list(map(int, metadata["DofMap"]))
    dof_map = [tuple(values[index:index + 3]) for index in range(0, len(values), 3)]
    values = list(map(int, metadata["ConstrainedDofs"]))
    constrained = {tuple(values[index:index + 2]) for index in range(0, len(values), 2)}
    return dof_map, constrained


def write_numeric_rows(file_path, rows, integer=False):
    """写出无表头、制表符分隔的数值文件。"""
    file_path = Path(file_path)
    file_path.parent.mkdir(parents=True, exist_ok=True)
    with file_path.open("w", encoding="ascii", newline="\n") as stream:
        for row in rows:
            text = "\t".join(str(int(value)) if integer else "{:.17e}".format(value) for value in row)
            stream.write(text + "\n")


def get_single_instance(odb):
    """取得唯一实例，避免不同实例中的同号节点发生混淆。"""
    instances = list(odb.rootAssembly.instances.values())
    if len(instances) != 1:
        raise ValueError("Exactly one ODB instance is required by the current DOF map.")
    return instances[0]


def get_mode_frames(step):
    """按模态编号取得实模态结果帧。"""
    frames = sorted((frame for frame in step.frames if frame.mode > 0), key=lambda frame: frame.mode)
    if not frames or [frame.mode for frame in frames] != list(range(1, len(frames) + 1)):
        raise ValueError("Expected real modes numbered consecutively from 1.")
    return frames


def read_nodal_displacements(frame, instance, dof_map):
    """按 DofMap 排列节点位移和转角。"""
    from abaqusConstants import DOUBLE_PRECISION, SCALAR

    bases = (("U", 0), ("UT", 0), ("UR", 3))

    component_dofs = {base + str(index): index + offset for base, offset in bases for index in range(1, 4)}
    field_names = tuple(base for base, _ in bases) + tuple(component_dofs)
    entries = {}
    found_field = False

    for field_name in field_names:
        if field_name not in frame.fieldOutputs:
            continue
        found_field = True
        field = frame.fieldOutputs[field_name].getSubset(region=instance)
        labels = field.componentLabels or (field_name,)

        for value in field.values:
            components = value.dataDouble if value.precision == DOUBLE_PRECISION else value.data
            if field.type == SCALAR:
                components = (components,)
            for label, component in zip(labels, components):
                entries[value.nodeLabel, component_dofs[label]] = component

    if not found_field:
        raise ValueError("Nodal displacement output is missing. Request U and UR.")

    vector = [0.0] * len(dof_map)
    for matrix_row, node_label, dof_number in dof_map:
        key = (node_label, dof_number)
        vector[matrix_row - 1] = entries[key]

    if not all(math.isfinite(value) for value in vector):
        raise ValueError("Non-finite nodal displacement output was found.")
    return vector
