function setAxesStyle(settings)
% 设置当前坐标轴的外观
% settings 可包含以下字段，未提供或为空的字段保留当前属性值：
%   LineWidth      坐标轴边框及刻度线的线宽，单位为磅
%   XColor         横轴轴线、刻度数字及标签的颜色
%   YColor         纵轴轴线、刻度数字及标签的颜色
%   TickDir        刻度线方向：'in'、'out'、'both' 或 'none'
%   TickLength     刻度线相对长度 [二维, 三维]，以最长可见轴线为基准
%   XMinorTick     横轴次刻度线开关：'on' 或 'off'
%   YMinorTick     纵轴次刻度线开关：'on' 或 'off'
%   Box            完整边框开关：'on' 或 'off'
%   XAxisLocation  横轴位置：'bottom'、'top' 或 'origin'（y = 0）
%   YAxisLocation  纵轴位置：'left'、'right' 或 'origin'（x = 0）
%   Layer          刻度线与网格位于数据图形下方 'bottom' 或上方 'top'

axesHandle = gca;

propertyNames = {'LineWidth', 'XColor', 'YColor', ...
                 'TickDir', 'TickLength', 'XMinorTick', 'YMinorTick', ...
                 'Box', 'XAxisLocation', 'YAxisLocation', 'Layer'};

for propertyIndex = 1:numel(propertyNames)
    propertyName = propertyNames{propertyIndex};

    if isfield(settings, propertyName) && ~isempty(settings.(propertyName))
        axesHandle.(propertyName) = settings.(propertyName);
    end
end

end