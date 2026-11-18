"""从同名 ODB 导出固有频率，时间单位为秒时频率单位为 Hz。"""

import math
import sys
sys.dont_write_bytecode = True

from odbAccess import openOdb
from extraction_io import get_mode_frames, read_paths, write_numeric_rows


def export_natural_frequencies(input_file_path, data_folder):
    """按模态编号读取 EIGFREQ 历史输出。"""
    odb = openOdb(path=str(input_file_path.with_suffix(".odb")), readOnly=True)
    try:
        step = odb.steps["ModalAnalysis"]
        frames = get_mode_frames(step)
        frequencies_by_mode = dict(step.historyRegions["Assembly ASSEMBLY"].historyOutputs["EIGFREQ"].data)
        frequencies = [frequencies_by_mode[frame.mode] for frame in frames]
        if not all(math.isfinite(value) and value >= 0 for value in frequencies):
            raise ValueError("Non-finite or negative natural frequencies were found.")
        write_numeric_rows(data_folder / "NaturalFrequencies.txt", ((value,) for value in frequencies))
    finally:
        odb.close()


if __name__ == "__main__":
    export_natural_frequencies(*read_paths())
