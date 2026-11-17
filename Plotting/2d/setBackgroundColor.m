function setBackgroundColor(figureColor, axesColor)
% 设置当前图窗和坐标区的背景颜色

axesHandle = gca;
figureHandle = ancestor(axesHandle, 'figure');

figureHandle.Color = figureColor;
axesHandle.Color = axesColor;

end