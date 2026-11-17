function setFontStyle(targetHandle, settings)
% 设置指定对象的字体和文字解释器
% targetHandle 可为单个坐标轴、坐标轴标签、标题或图例句柄
% settings 可包含以下字段，未提供或为空时保持原设置：
%   FontName       字体名称，例如 'Times New Roman'
%   FontSize       字号，采用目标对象当前的字号单位，默认是 point（pt）
%   FontWeight     字体粗细：'normal' 或 'bold'
%   FontAngle      字体倾斜：'normal' 或 'italic'
%   Interpreter    文字解释器：'tex'、'latex' 或 'none'
%
% 坐标轴使用 TickLabelInterpreter，其余对象使用 Interpreter。
% 使用 'latex' 时，FontName、FontWeight 和 FontAngle 不影响实际显示。
% 设置坐标轴字号可能联动尚未独立设置字号的标签、标题和图例。

propertyNames = {'FontName', 'FontSize', 'FontWeight', 'FontAngle'};

for propertyIndex = 1:numel(propertyNames)
    propertyName = propertyNames{propertyIndex};
    propertyValue = getFieldValue(settings, propertyName);

    if ~isempty(propertyValue)
        targetHandle.(propertyName) = propertyValue;
    end
end

interpreter = getFieldValue(settings, 'Interpreter');

if ~isempty(interpreter)
    if isprop(targetHandle, 'TickLabelInterpreter')
        targetHandle.TickLabelInterpreter = interpreter;
    else
        targetHandle.Interpreter = interpreter;
    end
end

end