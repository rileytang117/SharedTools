function constrainedDofs = readConstrainedDofs(dataFolder)
% 读取约束自由度
% dataFolder         提取结果的保存目录
% constrainedDofs    约束自由度矩阵，每行为 [节点编号, 自由度编号]，无约束时返回 0×2 空矩阵

constrainedDofs = readmatrix(fullfile(dataFolder, 'ConstrainedDofs.txt'));

if isempty(constrainedDofs)
    constrainedDofs = zeros(0, 2);
end

end
