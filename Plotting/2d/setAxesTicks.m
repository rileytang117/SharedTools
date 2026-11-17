function setAxesTicks(settings)
% 设置当前线性坐标轴的范围、刻度和数字显示格式
% settings 可包含以下字段，未提供或为空时采用默认处理：
%   XNumTicks             横轴自动主刻度的目标数量及上限，默认 5
%   YNumTicks             纵轴自动主刻度的目标数量及上限，默认 5
%   XLimits               横轴范围 [最小值, 最大值]，默认自动确定
%   YLimits               纵轴范围 [最小值, 最大值]，默认自动确定
%   XPaddingRatio         横轴两端的留白比例，默认 0
%   YPaddingRatio         纵轴两端的留白比例，默认 0.03
%   XTickValues           横轴主刻度位置，默认自动计算
%   YTickValues           纵轴主刻度位置，默认自动计算
%   XMinorTickValues      横轴次刻度位置，默认不修改
%   YMinorTickValues      纵轴次刻度位置，默认不修改
%   XScientificNotation   横轴科学计数法：'auto'、'on'、'off'，默认 'auto'
%   YScientificNotation   纵轴科学计数法：'auto'、'on'、'off'，默认 'auto'
%   XExponent             横轴手动指数，优先于 XScientificNotation
%   YExponent             纵轴手动指数，优先于 YScientificNotation
%   XTickFormat           横轴数字格式，例如 '%.2f'，默认自动确定
%   YTickFormat           纵轴数字格式，例如 '%.2f'，默认自动确定
%
% 手动指定范围时不增加留白；手动指定主刻度时不使用刻度数量设置。
% 留白比例相对于自动范围的跨度，两端分别增加对应比例。
% 'auto' 在刻度非零最大绝对值小于 0.1 或不小于 1000 时使用科学计数法。
% 'on' 按数值量级选择指数；指数为 0 时不显示倍率。
% 刻度位置使用原始数据单位，数字格式作用于除以科学计数法倍率后的刻度值。

axesHandle = gca;
axisNames = {'X', 'Y'};

for axisIndex = 1:2
    axisName = axisNames{axisIndex};
    axisHandle = axesHandle.([axisName, 'Axis']);

    %% 坐标范围
    axisLimits = getFieldValue(settings, [axisName, 'Limits']);

    if isempty(axisLimits)
        axesHandle.([axisName, 'LimitMethod']) = 'tight';
        axisHandle.LimitsMode = 'auto';
        axisLimits = axisHandle.Limits;

        paddingRatio = getFieldValue(settings, [axisName, 'PaddingRatio'], 0.03 * (axisIndex == 2));
        axisLimits = axisLimits + [-1, 1] * paddingRatio * diff(axisLimits);
    end

    %% 主刻度位置
    tickValues = getFieldValue(settings, [axisName, 'TickValues']);

    if isempty(tickValues)
        numTicks = getFieldValue(settings, [axisName, 'NumTicks'], 5);
        tickValues = calculateTickValues(axisLimits, numTicks);
    end

    tickValues = tickValues(:).';

    %% 科学计数法
    exponent = getFieldValue(settings, [axisName, 'Exponent']);

    if isempty(exponent)
        scientificNotation = getFieldValue(settings, [axisName, 'ScientificNotation'], 'auto');
        maximumMagnitude = max(abs(tickValues));
        useScientificNotation = strcmp(scientificNotation, 'on') || (strcmp(scientificNotation, 'auto') && (maximumMagnitude < 0.1 || maximumMagnitude >= 1000));

        exponent = 0;

        if useScientificNotation && maximumMagnitude > 0
            exponent = floor(log10(maximumMagnitude));
        end
    end

    %% 数字显示格式
    tickFormat = getFieldValue(settings, [axisName, 'TickFormat']);

    if isempty(tickFormat)
        tickFormat = getTickFormat(tickValues / 10^exponent);
    end

    %% 应用设置
    axisHandle.Limits = axisLimits;
    axisHandle.TickValues = tickValues;
    axisHandle.TickLabelsMode = 'auto';
    axisHandle.Exponent = exponent;
    axisHandle.TickLabelFormat = tickFormat;

    minorTickValues = getFieldValue(settings, [axisName, 'MinorTickValues']);

    if ~isempty(minorTickValues)
        axisHandle.MinorTickValues = minorTickValues;
    end
end

end


function tickValues = calculateTickValues(axisLimits, numTicks)
% 生成数量不超过指定值、且尽量接近它的整齐主刻度

rawStep = diff(axisLimits) / (numTicks - 1);
stepScale = 10^floor(log10(rawStep));
candidateSteps = unique([1; 2; 2.5; 3; 4; 5; 6; 8; 10] * (stepScale * [0.1, 1, 10]));

tickValues = [];
bestNumTicks = 0;
bestEdgeGap = inf;

for stepIndex = 1:numel(candidateSteps)
    tickStep = candidateSteps(stepIndex);
    indexLimits = axisLimits / tickStep;
    indexTolerance = 8 * eps(max(abs(indexLimits)));

    firstTickIndex = ceil(indexLimits(1) - indexTolerance);
    lastTickIndex = floor(indexLimits(2) + indexTolerance);

    currentTickValues = (firstTickIndex:lastTickIndex) * tickStep;
    currentTickValues = unique(min(max(currentTickValues, axisLimits(1)), axisLimits(2)));
    currentNumTicks = numel(currentTickValues);

    if currentNumTicks < 2 || currentNumTicks > numTicks
        continue;
    end

    edgeGap = (currentTickValues(1) - axisLimits(1)) + (axisLimits(2) - currentTickValues(end));

    if currentNumTicks > bestNumTicks || (currentNumTicks == bestNumTicks && edgeGap < bestEdgeGap)
        tickValues = currentTickValues;
        bestNumTicks = currentNumTicks;
        bestEdgeGap = edgeGap;
    end
end

if isempty(tickValues)
    warning('No suitable tick spacing was found. Using %d uniformly spaced ticks within the specified limits.', numTicks);
    tickValues = linspace(axisLimits(1), axisLimits(2), numTicks);
end

end


function tickFormat = getTickFormat(tickValues)
% 根据缩放后的刻度数值自动确定小数位数

if numel(tickValues) > 1
    tickStep = min(diff(tickValues));
else
    tickStep = abs(tickValues(1));
end

if tickStep == 0
    tickStep = 1;
end

numDecimalPlaces = max(0, -floor(log10(tickStep)));
tolerance = max(8 * eps(max(abs(tickValues))), tickStep * 1e-9);

for precisionIndex = 1:12
    if all(abs(tickValues - round(tickValues, numDecimalPlaces)) <= tolerance)
        break;
    end

    numDecimalPlaces = numDecimalPlaces + 1;
end

tickFormat = sprintf('%%.%df', numDecimalPlaces);

end