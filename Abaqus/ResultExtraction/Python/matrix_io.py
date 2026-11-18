"""按自由度映射导出对称矩阵，输入采用 MATRIX INPUT 格式。"""

import math
from pathlib import Path


def _read_matrix_entries(file_path, constrained_dofs):
    entries = {}
    with Path(file_path).open('r', encoding='ascii') as stream:
        for line_number, line in enumerate(stream, 1):
            line = line.strip()
            if not line or line.startswith(('**', '#')):
                continue
            fields = [item.strip() for item in line.split(',')]
            if len(fields) != 5:
                raise ValueError('{}:{}: Expected five MATRIX INPUT fields. Export with FORMAT=MATRIX INPUT.'.format(file_path, line_number))
            row_node, row_dof, column_node, column_dof = map(int, fields[:4])
            value = float(fields[4].upper().replace('D', 'E'))
            if not math.isfinite(value):
                raise ValueError('Non-finite matrix entry at line {}.'.format(line_number))
            if (row_node, row_dof) in constrained_dofs or (column_node, column_dof) in constrained_dofs:
                continue
            key = ((row_node, row_dof), (column_node, column_dof))
            accumulated = entries.get(key, 0.0) + value
            if not math.isfinite(accumulated):
                raise ValueError('Accumulated matrix entry overflow at line {}.'.format(line_number))
            entries[key] = accumulated
    return entries


def _symmetric_entries(entries, row_numbers):
    result = {}
    for (row_dof, column_dof), value in entries.items():
        if value == 0:
            continue
        i, j = row_numbers[row_dof], row_numbers[column_dof]
        transpose = entries.get((column_dof, row_dof))
        if i != j and transpose is not None and not math.isclose(value, transpose, rel_tol=1e-10, abs_tol=0.0):
            raise ValueError('Opposite matrix entries are inconsistent. This exporter requires a symmetric matrix.')
        result[i, j] = value
        result[j, i] = value
    return result


def export_structural_matrix(input_file_path, data_folder, matrix_type, dof_map, constrained):
    identifiers = {
        'mass': ('_MASS1.mtx', 'MassMatrix.txt'),
        'stiffness': ('_STIF1.mtx', 'LinearStiffnessMatrix.txt'),
    }
    source_suffix, output_name = identifiers[matrix_type]
    input_path = Path(input_file_path).resolve()
    matrix_path = input_path.with_name(input_path.stem + source_suffix)
    output_path = Path(data_folder).resolve()

    raw_entries = _read_matrix_entries(matrix_path, constrained)
    row_numbers = {(node, dof): row for row, node, dof in dof_map}
    entries = _symmetric_entries(raw_entries, row_numbers)
    size = len(dof_map)
    entries.setdefault((size, size), 0.0)

    output_path.mkdir(parents=True, exist_ok=True)
    with (output_path / output_name).open('w', encoding='ascii', newline='\n') as stream:
        for (row, column), value in sorted(entries.items()):
            stream.write('{}\t{}\t{:.17e}\n'.format(row, column, value))

    matrix_name = 'Mass' if matrix_type == 'mass' else 'Linear stiffness'
    print('{} matrix exported: {} x {}; {} nonzero entries.'.format(matrix_name, size, size, sum(value != 0 for value in entries.values())))
    print('Constrained DOFs removed: {}.'.format(len(constrained)))
    print('Source matrix: {}'.format(matrix_path))
    print('Output file: {}'.format(output_path / output_name))
    return size
