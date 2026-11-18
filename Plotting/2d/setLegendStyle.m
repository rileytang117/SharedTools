function setLegendStyle(curveHandles, legendLabels, settings)
% 创建当前坐标轴的图例并设置布局和外观
% curveHandles 为需要显示图例的曲线句柄，legendLabels 为按相同顺序排列的图例文字
% settings 可包含以下字段，未提供或为空时不修改对应属性：
%   Location           图例位置，例如 'best'、'northwest'、'northeast'、'southoutside'
%   Orientation        排列方向：'vertical' 按列排列，'horizontal' 按行排列
%   NumColumns         图例列数
%   Direction          条目顺序：'normal' 或 'reverse'
%   Box                是否显示图例框：'on' 或 'off'
%   Color              图例背景色，可以使用颜色名称、RGB 三元组或 'none'
%   EdgeColor          图例边框颜色
%   LineWidth          图例边框线宽，单位为 point（pt）
%   IconColumnWidth    图例中曲线示意图标所占区域的宽度，单位为 point（pt）
%   Title              图例标题文字

axesHandle = gca;
legendHandle = legend(axesHandle, curveHandles, legendLabels);

titleText = getFieldValue(settings, 'Title');

if ~isempty(titleText)
    legendHandle.Title.String = titleText;
end

propertyNames = {'Orientation', 'NumColumns', 'Direction', 'Box', 'Color', 'EdgeColor', 'LineWidth', 'IconColumnWidth', 'Location'};

for propertyIndex = 1:numel(propertyNames)
    propertyName = propertyNames{propertyIndex};
    propertyValue = getFieldValue(settings, propertyName);

    if ~isempty(propertyValue)
        legendHandle.(propertyName) = propertyValue;
    end
end

end