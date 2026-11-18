"""读取单实例结构模型的节点、单元类型和零位移约束，支持节点集及 INCLUDE。"""

import csv
from pathlib import Path


_TYPES = {
    "ENCASTRE": (1, 2, 3, 4, 5, 6),
    "PINNED": (1, 2, 3),
    "XSYMM": (1, 5, 6),
    "YSYMM": (2, 4, 6),
    "ZSYMM": (3, 4, 5),
    "XASYMM": (2, 3, 4),
    "YASYMM": (1, 3, 5),
    "ZASYMM": (1, 2, 6),
}


def _fields(line):
    return [item.strip().strip('"') for item in next(csv.reader([line], skipinitialspace=True))]


def _file_lines(file_path, parents=(), root_folder=None):
    path = Path(file_path).resolve()
    if root_folder is None:
        root_folder = path.parent
    if path in parents:
        raise ValueError("Circular INCLUDE: {}".format(path))
    raw = path.read_bytes()
    try:
        text = raw.decode("utf-8-sig")
    except UnicodeDecodeError:
        text = raw.decode("gb18030")
    for line in text.splitlines():
        line = line.strip()
        if not line or line.startswith("**"):
            continue
        if line.startswith("*") and _fields(line)[0].upper() == "*INCLUDE":
            options = dict(item.split("=", 1) for item in _fields(line)[1:] if "=" in item)
            options = {key.strip().upper(): value.strip().strip('"') for key, value in options.items()}
            if "INPUT" not in options:
                raise ValueError("INCLUDE requires an INPUT file path.")
            yield from _file_lines(root_folder / options["INPUT"], parents + (path,), root_folder)
        else:
            yield line


def _blocks(file_path):
    key, options, lines = None, {}, []
    for line in _file_lines(file_path):
        if line.startswith("*"):
            if key is not None:
                yield key, options, lines
            fields = _fields(line[1:])
            key = " ".join(fields[0].upper().split())
            options = {}
            for item in fields[1:]:
                if not item:
                    continue
                name, separator, value = item.partition("=")
                options[name.strip().upper()] = value.strip() if separator else None
            lines = []
        elif key is not None:
            lines.append(line)
    if key is not None:
        yield key, options, lines


def read_input_model(input_file_path):
    """读取节点坐标、约束自由度和单元类型，名称统一转换为大写。"""
    nodes, sets, instances = {}, {}, {}
    element_types = {}
    boundary_blocks = []
    scope = ("MODEL", "")
    assembly = False
    steps = []
    in_step = False
    frequency_step = False

    unsupported = {
        "TRANSFORM", "MPC", "EQUATION", "COUPLING", "TIE", "RIGID BODY",
        "NGEN", "NFILL", "NCOPY", "NMAP", "SYSTEM",
    }

    def add_set(name, current_scope, items):
        sets.setdefault((current_scope, name.upper()), []).extend(items)

    for key, options, lines in _blocks(input_file_path):
        if key in unsupported:
            raise ValueError("*{} requires additional mesh/constraint handling and is not supported yet.".format(key))
        if key == "PART":
            scope = ("PART", options["NAME"].upper())
        elif key == "END PART":
            scope = ("MODEL", "")
        elif key == "ASSEMBLY":
            assembly = True
            scope = ("ASSEMBLY", "")
        elif key == "END ASSEMBLY":
            scope = ("MODEL", "")
        elif key == "INSTANCE":
            name = options["NAME"].upper()
            instances[name] = options.get("PART", "").upper()
            scope = ("INSTANCE", name)
            if lines:
                raise ValueError("Translated/rotated instances are not supported by the current node and coordinate mapping.")
        elif key == "END INSTANCE":
            scope = ("ASSEMBLY", "")
        elif key == "NODE":
            labels = []
            for line in lines:
                fields = _fields(line)
                label = int(fields[0])
                coords = [float(value.replace("D", "E")) for value in fields[1:] if value]
                if not 1 <= len(coords) <= 3 or label <= 0:
                    raise ValueError("Invalid structural NODE definition.")
                nodes.setdefault(scope, {})[label] = tuple((coords + [0.0, 0.0])[:3])
                labels.append(str(label))
            if "NSET" in options:
                add_set(options["NSET"], scope, [(scope, label) for label in labels])
        elif key == "ELEMENT":
            element_types.setdefault(scope, set()).add(options["TYPE"].upper())
        elif key == "NSET":
            if "ELSET" in options or "SURFACE" in options:
                raise ValueError("NSET defined through ELSET/SURFACE is not supported yet; export explicit node lists.")
            item_scope = ("INSTANCE", options["INSTANCE"].upper()) if "INSTANCE" in options else scope
            items = []
            for line in lines:
                fields = [value for value in _fields(line) if value]
                if "GENERATE" in options:
                    if len(fields) not in (2, 3):
                        raise ValueError("NSET, GENERATE requires first node, last node, and optional increment.")
                    first, last = int(fields[0]), int(fields[1])
                    increment = int(fields[2]) if len(fields) == 3 else 1
                    if increment <= 0 or last < first or (last - first) % increment:
                        raise ValueError("Invalid NSET, GENERATE range.")
                    fields = [str(value) for value in range(first, last + 1, increment)]
                items.extend((item_scope, value.upper()) for value in fields)
            add_set(options["NSET"], scope, items)
        elif key == "STEP":
            steps.append(options.get("NAME", "STEP-{}".format(len(steps) + 1)))
            in_step = True
        elif key == "END STEP":
            in_step = False
        elif key == "FREQUENCY":
            frequency_step = in_step
        elif key == "NODE FILE" and options.get("GLOBAL", "YES").upper() != "YES":
            raise ValueError("Modal NODE FILE output must use GLOBAL=YES.")
        elif key == "BOUNDARY":
            allowed = {"OP", "TYPE"}
            if set(options) - allowed or options.get("TYPE", "DISPLACEMENT").upper() != "DISPLACEMENT":
                raise ValueError("Only direct zero displacement/rotation BOUNDARY definitions are supported.")
            operation = options.get("OP", "MOD").upper()
            if operation not in ("MOD", "NEW"):
                raise ValueError("Unsupported BOUNDARY operation: {}.".format(operation))
            boundary_blocks.append((in_step, operation, lines))

    if len(steps) > 1:
        raise ValueError("Boundary-condition histories spanning multiple steps are not supported yet.")
    if len(instances) > 1:
        raise ValueError("Multiple instances require an explicit global-node mapping; this version supports one instance.")
    if instances:
        instance, part = next(iter(instances.items()))
        mesh = dict(nodes.get(("PART", part), {}))
        mesh.update(nodes.get(("INSTANCE", instance), {}))
        if nodes.get(("MODEL", "")) or nodes.get(("ASSEMBLY", "")):
            raise ValueError("Assembly/model nodes mixed with an instance require an explicit global-node mapping.")
    else:
        instance, part = "", ""
        mesh = nodes.get(("MODEL", ""), {})
    if not mesh:
        raise ValueError("No explicit mesh nodes were found for the instance.")

    def resolve(token, item_scope, trail=()):
        token = token.upper()
        if item_scope[0] == "INSTANCE" and item_scope[1] not in instances:
            raise ValueError("Unknown instance in node/set reference: {}.".format(item_scope[1]))
        if "." in token:
            prefix, remainder = token.split(".", 1)
            if prefix not in instances:
                raise ValueError("Unknown instance in node/set reference: {}.".format(token))
            return resolve(remainder, ("INSTANCE", prefix), trail)
        if token.isdigit():
            label = int(token)
            if item_scope[0] not in ("PART", "INSTANCE") and assembly:
                raise ValueError("Unqualified assembly node labels require explicit instance qualification.")
            if label not in mesh:
                raise ValueError("Boundary node {} was not found in the mesh.".format(label))
            return {(instance, label)}

        candidates = [(item_scope, token)]
        if item_scope[0] == "INSTANCE":
            candidates.append((("PART", instances[item_scope[1]]), token))
        set_key = next((candidate for candidate in candidates if candidate in sets), None)
        if set_key is None:
            raise ValueError("Node set not found in its scope: {}.".format(token))
        if set_key in trail:
            raise ValueError("Circular node-set reference: {}.".format(token))
        result = set()
        for reference_scope, reference in sets[set_key]:
            result.update(resolve(reference, reference_scope, trail + (set_key,)))
        return result

    fixed = set()
    # 分析步使用 OP=NEW 时，舍弃继承自初始阶段的约束。
    step_operations = {operation for in_step, operation, _ in boundary_blocks if in_step}
    if len(step_operations) > 1:
        raise ValueError("All BOUNDARY options in a step must use the same OP value.")
    for is_history, operation, lines in boundary_blocks:
        if not is_history and "NEW" in step_operations:
            continue
        for line in lines:
            fields = _fields(line)
            if len(fields) < 2:
                raise ValueError("Invalid BOUNDARY data line: {}.".format(line))
            region, description = fields[0], fields[1].upper()
            if description in _TYPES:
                dofs = _TYPES[description]
            else:
                first = int(description)
                last = int(fields[2]) if len(fields) > 2 and fields[2] else first
                value = float(fields[3].replace("D", "E")) if len(fields) > 3 and fields[3] else 0.0
                if not 1 <= first <= last <= 6 or value != 0:
                    raise ValueError("Only zero-valued structural BOUNDARY DOFs 1 through 6 are supported.")
                dofs = range(first, last + 1)
            boundary_scope = ("ASSEMBLY", "") if assembly else ("MODEL", "")
            for node_instance, label in resolve(region, boundary_scope):
                fixed.update((node_instance, label, dof) for dof in dofs)

    return {
        "instance": instance,
        "nodes": mesh,
        "constrained_dofs": fixed,
        "step_name": steps[0] if steps else "Initial",
        "frequency_step": frequency_step,
        "element_types": set().union(
            element_types.get(("PART", part), set()),
            element_types.get(("INSTANCE", instance), set()),
            element_types.get(("MODEL", ""), set()),
        ),
    }


def uniform_structural_dofs(model):
    """根据单元类型确定节点自由度，要求所有单元使用相同的自由度布局。"""
    groups = {
        (1, 2, 6): {"B21", "B22", "B23", "B21H", "B22H", "B23H", "PIPE21", "PIPE22"},
        (1, 2, 3, 4, 5, 6): {"B31", "B32", "B33", "B31H", "B32H", "B33H", "PIPE31", "PIPE32",
                              "S3", "S3R", "S4", "S4R", "S4RS", "S4RSW", "S8R"},
        (1, 2): {"T2D2", "T2D3", "CPS3", "CPS4", "CPS4R", "CPS6", "CPS8", "CPS8R",
                 "CPE3", "CPE4", "CPE4R", "CPE6", "CPE8", "CPE8R", "CAX3", "CAX4", "CAX4R", "CAX6", "CAX8", "CAX8R"},
        (1, 2, 3): {"T3D2", "T3D3", "C3D4", "C3D6", "C3D8", "C3D8R", "C3D8I", "C3D10",
                    "C3D10M", "C3D15", "C3D20", "C3D20R", "M3D3", "M3D4", "M3D4R", "M3D6", "M3D8", "M3D8R"},
    }
    layouts = set()
    for element_type in model["element_types"]:
        layout = next((dofs for dofs, types in groups.items() if element_type in types), None)
        if layout is None:
            raise ValueError("Element type {} needs an explicit DOF mapping; it is not supported yet.".format(element_type))
        layouts.add(layout)
    if len(layouts) != 1:
        raise ValueError("A uniform supported structural DOF layout is required for matrix export.")
    return next(iter(layouts))


def get_free_dof_map(model, node_dofs):
    """按节点编号和自由度编号排列自由自由度与约束自由度。"""
    free, constrained = [], []
    for node, dof in sorted(set(node_dofs)):
        if node not in model["nodes"] or dof not in range(1, 7):
            raise ValueError("Invalid physical node/DOF identity: ({}, {}).".format(node, dof))
        target = constrained if (model["instance"], node, dof) in model["constrained_dofs"] else free
        target.append((node, dof))
    if not free:
        raise ValueError("No free structural DOFs remain after applying boundary conditions.")
    return free, constrained
