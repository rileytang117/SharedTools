function setFigureSize(figureWidth, figureHeight)
% 设置当前图窗的宽度和高度，单位为厘米

figureHandle = gcf;

figureHandle.Units = 'centimeters';
figureHandle.Position(3:4) = [figureWidth, figureHeight];
end