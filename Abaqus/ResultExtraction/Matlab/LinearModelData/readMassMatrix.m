function massMatrix = readMassMatrix(dataFolder)
% 读取质量矩阵并恢复为稀疏矩阵
% dataFolder    提取结果的保存目录
% massMatrix    已剔除约束自由度的质量矩阵，行列顺序与 DofMap 中的矩阵行号一致

matrixEntries = readmatrix(fullfile(dataFolder, 'MassMatrix.txt'));
massMatrix = sparse(matrixEntries(:, 1), matrixEntries(:, 2), matrixEntries(:, 3));

end
