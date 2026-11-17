t = 1:0.01:10;

y1 = sin(t);
y2 = y1 + 0.01;
y3 = y1 + 0.02;

curves = struct();

%% 第一条曲线：黑色实线，不显示 marker
curves(1).XVector = t;
curves(1).YVector = y1;
curves(1).Color = 'black';
curves(1).LineStyle = '-';
curves(1).LineWidth = 3;
curves(1).Marker = 'none';
curves(1).LegendLabel = '$y_1$';


%% 第二条曲线：蓝色虚线，圆形 marker
curves(2) = curves(1);

curves(2).YVector = y2;
curves(2).Color = [0, 0.6, 1];
curves(2).LineStyle = '--';
curves(2).Marker = 'o';
curves(2).MarkerSize = 5;
curves(2).MarkerEdgeColor = 'auto';
curves(2).MarkerFaceColor = 'white';
curves(2).NumMarkers = 12;
curves(2).MarkerPhase = 0;
curves(2).LegendLabel = '$y_2$';


%% 第三条曲线：红色点划线，方形 marker
curves(3) = curves(2);

curves(3).YVector = y3;
curves(3).Color = [0.85, 0.15, 0.15];
curves(3).LineStyle = '-.';
curves(3).Marker = 's';
curves(3).MarkerPhase = 0.5;
curves(3).LegendLabel = '$y_3$';


%% 图形设置
settings = struct();

settings.UseDefaultSettings = true;

settings.XLabel = 'time $t$ (s)';
settings.YLabel = 'displacement $y$ (m)';

%% 绘图
plotCurves2d(curves, settings);