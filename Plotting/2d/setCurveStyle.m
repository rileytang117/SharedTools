function setCurveStyle(curveHandle, settings)
% 设置指定曲线的线条样式、marker 样式和显示位置
% settings 可包含以下字段，未提供或为空的普通样式字段保持原设置：
%   Color              曲线颜色，例如 'black' 或 [0, 0.6, 1]
%   LineStyle          线型：'-'、'--'、':'、'-.' 或 'none'
%   LineWidth          曲线线宽，单位为 point（pt）
%   Marker             marker 类型，例如 'o'、's'、'^'、'v'、'x' 或 'none'
%   MarkerSize         marker 大小，单位为 point（pt）
%   MarkerEdgeColor    marker 边缘颜色，'auto' 表示跟随曲线颜色
%   MarkerFaceColor    marker 填充颜色，'none' 表示不填充
%   NumMarkers         marker 的目标数量，取正整数
%   MarkerPhase        起始位置相对一个间隔的偏移比例，范围为 [0, 1)，默认 0

propertyNames = {'Color', 'LineStyle', 'LineWidth', 'Marker', 'MarkerSize', 'MarkerEdgeColor', 'MarkerFaceColor'};

for propertyIndex = 1:numel(propertyNames)
    propertyName = propertyNames{propertyIndex};
    propertyValue = getFieldValue(settings, propertyName);

    if ~isempty(propertyValue)
        curveHandle.(propertyName) = propertyValue;
    end
end

numMarkers = getFieldValue(settings, 'NumMarkers');

if ~isempty(numMarkers)
    markerPhase = getFieldValue(settings, 'MarkerPhase', 0);
    xVector = curveHandle.XData(:).';
    markerXStep = (max(xVector) - min(xVector)) / numMarkers;
    markerXVector = min(xVector) + ((0:numMarkers - 1) + markerPhase) * markerXStep;
    markerIndices = zeros(1, numMarkers);

    for markerIndex = 1:numMarkers
        [~, markerIndices(markerIndex)] = min(abs(xVector - markerXVector(markerIndex)));
    end

    curveHandle.MarkerIndices = unique(markerIndices);
end

end