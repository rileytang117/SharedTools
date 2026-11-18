function modalMatrix = readModalMatrix(dataFolder)
% 读取模态矩阵
% dataFolder     提取结果的保存目录
% modalMatrix    每行为一个自由自由度，每列为一个模态，行顺序与 DofMap 中的矩阵行号一致
%                保留 Abaqus 导出的模态归一化方式，不进行额外归一化

modalMatrix = readmatrix(fullfile(dataFolder, 'ModeShapeMatrix.txt'));

end
