function setGridStyle(settings)
% 设置当前坐标区的主网格和次网格
% settings 可包含以下字段，未提供或为空的字段不主动赋值：
%   XGrid               经过 x 主刻度的竖直网格线开关：'on' 或 'off'
%   YGrid               经过 y 主刻度的水平网格线开关：'on' 或 'off'
%   GridLineStyle       主网格线型：'-'、'--'、':'、'-.' 或 'none'
%   GridLineWidth       主网格线宽，单位为磅
%   GridColor           主网格颜色
%   GridAlpha           主网格透明度，0 完全透明，1 完全不透明
%   XMinorGrid          经过 x 次刻度的竖直网格线开关：'on' 或 'off'
%   YMinorGrid          经过 y 次刻度的水平网格线开关：'on' 或 'off'
%   MinorGridLineStyle  次网格线型：'-'、'--'、':'、'-.' 或 'none'
%   MinorGridLineWidth  次网格线宽，单位为磅
%   MinorGridColor      次网格颜色
%   MinorGridAlpha      次网格透明度，0 完全透明，1 完全不透明

axesHandle = gca;

propertyNames = {'XGrid', 'YGrid', ...
                 'GridLineStyle', 'GridLineWidth', 'GridColor', 'GridAlpha', ...
                 'XMinorGrid', 'YMinorGrid', ...
                 'MinorGridLineStyle', 'MinorGridLineWidth', 'MinorGridColor', 'MinorGridAlpha'};

for propertyIndex = 1:numel(propertyNames)
    propertyName = propertyNames{propertyIndex};

    if isfield(settings, propertyName) && ~isempty(settings.(propertyName))
        axesHandle.(propertyName) = settings.(propertyName);
    end
end

end