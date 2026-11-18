function plotCurves2d(curves, settings)
% 新建图窗并绘制多条二维曲线，统一设置图窗、坐标轴、文字和图例
% curves 为结构体数组，每个元素包含：
%   XVector、YVector      曲线的横纵坐标数据
%   LegendLabel           图例文字，未提供或为空时不加入图例
%   其余曲线样式字段与 setCurveStyle 相同，直接放在各个 curve 中
%
% settings 可包含以下字段：
%   UseDefaultSettings    是否启用默认预设，默认 false；用户提供的非空字段优先
%   FigureSize            图窗尺寸 [宽度, 高度]，单位为厘米，默认保持 MATLAB 的初始尺寸
%   FigureColor           图窗背景色，默认保持原设置
%   AxesColor             坐标区背景色，默认保持原设置
%   AxesStyle             坐标轴外观设置，对应 setAxesStyle
%   AxesTicks             坐标范围、刻度及数字格式设置，对应 setAxesTicks
%   GridStyle             网格设置，对应 setGridStyle
%   XLabel、YLabel        横纵坐标轴标签，默认不显示
%   Title                 图标题，默认不显示
%   TickFont              刻度字体设置，对应 setFontStyle
%   XLabelFont、YLabelFont 横纵坐标轴标签的字体设置，对应 setFontStyle
%   TitleFont             图标题的字体设置，对应 setFontStyle
%   LegendStyle           图例布局和外观设置，对应 setLegendStyle
%   LegendFont            图例字体设置，对应 setFontStyle

if getFieldValue(settings, 'UseDefaultSettings', false)
    settings = applyDefaultSettings(settings, getDefaultPlotSettings());
end

%% 创建图窗和坐标轴
figureHandle = figure;
axesHandle = axes('Parent', figureHandle);

figureSize = getFieldValue(settings, 'FigureSize');

if ~isempty(figureSize)
    setFigureSize(figureSize(1), figureSize(2));
end

%% 绘制曲线
numCurves = numel(curves);
curveHandles = gobjects(numCurves, 1);
legendLabels = cell(numCurves, 1);

hold(axesHandle, 'on');

for curveIndex = 1:numCurves
    curve = curves(curveIndex);
    curveHandles(curveIndex) = plot(axesHandle, curve.XVector, curve.YVector);
    setCurveStyle(curveHandles(curveIndex), curve);
    legendLabels{curveIndex} = getFieldValue(curve, 'LegendLabel', '');
end

hold(axesHandle, 'off');

%% 设置背景、坐标轴和网格
figureColor = getFieldValue(settings, 'FigureColor', figureHandle.Color);
axesColor = getFieldValue(settings, 'AxesColor', axesHandle.Color);

setBackgroundColor(figureColor, axesColor);
setAxesStyle(getFieldValue(settings, 'AxesStyle', struct()));
setAxesTicks(getFieldValue(settings, 'AxesTicks', struct()));
setGridStyle(getFieldValue(settings, 'GridStyle', struct()));

%% 设置标签、标题和字体
xlabel(axesHandle, getFieldValue(settings, 'XLabel', ''));
ylabel(axesHandle, getFieldValue(settings, 'YLabel', ''));
title(axesHandle, getFieldValue(settings, 'Title', ''));

setFontStyle(axesHandle, getFieldValue(settings, 'TickFont', struct()));
setFontStyle(axesHandle.XLabel, getFieldValue(settings, 'XLabelFont', struct()));
setFontStyle(axesHandle.YLabel, getFieldValue(settings, 'YLabelFont', struct()));
setFontStyle(axesHandle.Title, getFieldValue(settings, 'TitleFont', struct()));

%% 创建图例并设置字体
hasLegendLabel = ~cellfun(@isempty, legendLabels);

if any(hasLegendLabel)
    setLegendStyle(curveHandles(hasLegendLabel), legendLabels(hasLegendLabel), getFieldValue(settings, 'LegendStyle', struct()));
    setFontStyle(axesHandle.Legend, getFieldValue(settings, 'LegendFont', struct()));
end

end



function settings = applyDefaultSettings(settings, defaultSettings)
% 补全未提供或为空的设置字段，保留用户提供的非空设置
% 嵌套结构体按子字段逐项处理，用户额外提供的字段保持不变

fieldNames = fieldnames(defaultSettings);

for fieldIndex = 1:numel(fieldNames)
    fieldName = fieldNames{fieldIndex};
    defaultValue = defaultSettings.(fieldName);
    fieldValue = getFieldValue(settings, fieldName, defaultValue);

    if isstruct(defaultValue) && isstruct(fieldValue)
        fieldValue = applyDefaultSettings(fieldValue, defaultValue);
    end

    settings.(fieldName) = fieldValue;
end

end

function defaultSettings = getDefaultPlotSettings()
% 返回二维绘图的默认设置
% 字段含义与 plotCurves2d 及对应的小函数一致
% 坐标范围、标签和标题由每次绘图指定，未指定时使用现有小函数的默认行为

defaultSettings = struct();

%% 图窗尺寸和背景
defaultSettings.FigureSize = [24, 10];
defaultSettings.FigureColor = 'white';
defaultSettings.AxesColor = 'white';


%% 坐标轴外观
defaultSettings.AxesStyle.LineWidth = 0.8;
defaultSettings.AxesStyle.XColor = 'black';
defaultSettings.AxesStyle.YColor = 'black';
defaultSettings.AxesStyle.TickDir = 'in';
defaultSettings.AxesStyle.XMinorTick = 'off';
defaultSettings.AxesStyle.YMinorTick = 'off';
defaultSettings.AxesStyle.Box = 'on';
defaultSettings.AxesStyle.Layer = 'bottom';


%% 坐标范围、刻度和数字格式
defaultSettings.AxesTicks.XNumTicks = 6;
defaultSettings.AxesTicks.YNumTicks = 5;
defaultSettings.AxesTicks.XPaddingRatio = 0;
defaultSettings.AxesTicks.YPaddingRatio = 0.05;
defaultSettings.AxesTicks.XScientificNotation = 'auto';
defaultSettings.AxesTicks.YScientificNotation = 'auto';


%% 网格
defaultSettings.GridStyle.XGrid = 'on';
defaultSettings.GridStyle.YGrid = 'on';
defaultSettings.GridStyle.GridLineStyle = '-.';
defaultSettings.GridStyle.GridLineWidth = 0.5;
defaultSettings.GridStyle.GridColor = [0.65, 0.65, 0.65];
defaultSettings.GridStyle.GridAlpha = 0.5;
defaultSettings.GridStyle.XMinorGrid = 'off';
defaultSettings.GridStyle.YMinorGrid = 'off';


%% 字体
defaultSettings.TickFont = struct('FontSize', 22, 'Interpreter', 'latex');
defaultSettings.XLabelFont = struct('FontSize', 24, 'Interpreter', 'latex');
defaultSettings.YLabelFont = struct('FontSize', 24, 'Interpreter', 'latex');
defaultSettings.TitleFont = struct('FontSize', 24, 'Interpreter', 'latex');
defaultSettings.LegendFont = struct('FontSize', 24, 'Interpreter', 'latex');


%% 图例
defaultSettings.LegendStyle.Location = 'best';
defaultSettings.LegendStyle.Orientation = 'horizontal';
defaultSettings.LegendStyle.NumColumns = 3;
defaultSettings.LegendStyle.Box = 'off';
defaultSettings.LegendStyle.IconColumnWidth = 20;

end