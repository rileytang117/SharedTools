function dofMap = readDofMap(dataFolder)
% 读取自由度映射
% dataFolder    提取结果的保存目录
% dofMap        自由度映射矩阵，每行为 [矩阵行号, 节点编号, 自由度编号]，仅包含自由自由度

dofMap = readmatrix(fullfile(dataFolder, 'DofMap.txt'));

end
