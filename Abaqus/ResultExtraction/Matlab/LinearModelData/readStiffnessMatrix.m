function linearStiffnessMatrix = readStiffnessMatrix(dataFolder)
% 读取线性刚度矩阵并恢复为稀疏矩阵
% dataFolder               提取结果的保存目录
% linearStiffnessMatrix    已剔除约束自由度的线性刚度矩阵，行列顺序与 DofMap 中的矩阵行号一致

matrixEntries = readmatrix(fullfile(dataFolder, 'LinearStiffnessMatrix.txt'));
linearStiffnessMatrix = sparse(matrixEntries(:, 1), matrixEntries(:, 2), matrixEntries(:, 3));

end
